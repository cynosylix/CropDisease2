import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth backed by Firebase Realtime Database.
/// - Users are stored under the `users` node in Realtime DB.
/// - Login state is persisted: user stays logged in until they tap Logout.
class AuthService {
  AuthService({SharedPreferences? prefs}) : _prefs = prefs;

  static const _usersPath = 'users';
  static const _prefKeyEmail = 'auth_logged_in_email';
  static const _prefKeyName = 'auth_logged_in_name';

  final SharedPreferences? _prefs;
  DatabaseReference? _usersRef;

  String? _loggedInEmail;
  String? _loggedInUserName;

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    return SharedPreferences.getInstance();
  }

  String? get loggedInEmail => _loggedInEmail;
  bool get isLoggedIn =>
      _loggedInEmail != null && _loggedInEmail!.isNotEmpty;

  /// Lazily obtain the Realtime Database users reference.
  /// Throws if Firebase is not available so we never save only locally.
  static const _firebaseInitTimeout = Duration(seconds: 10);

  Future<DatabaseReference> _getUsersRef() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp().timeout(
        _firebaseInitTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Firebase initialization timed out. Check your internet connection.',
          );
        },
      );
    }
    _usersRef ??= FirebaseDatabase.instance.ref(_usersPath);
    // ignore: avoid_print
    print('[AuthService] Realtime DB path: ${_usersRef!.path}');
    return _usersRef!;
  }

  /// Safely get first child as Map. Returns null if empty, value is not a Map, or SDK throws (e.g. String in DB).
  static Map<String, dynamic>? _firstChildAsMap(DataSnapshot querySnapshot) {
    try {
      if (!querySnapshot.exists || querySnapshot.children.isEmpty) return null;
      final firstChild = querySnapshot.children.first;
      final raw = firstChild.value;
      if (raw == null || raw is! Map) return null;
      return Map<String, dynamic>.from(raw as Map);
    } catch (_) {
      return null;
    }
  }

  /// Restores session from persistent storage (SharedPreferences).
  /// Returns true if user was previously logged in and not logged out.
  Future<bool> isLoggedInAsync() async {
    if (_loggedInEmail != null && _loggedInEmail!.isNotEmpty) {
      return true;
    }
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final prefs = await _getPrefs();
        try {
          await prefs.reload();
        } catch (_) {}
        final email = prefs.getString(_prefKeyEmail);
        if (email != null && email.trim().isNotEmpty) {
          _loggedInEmail = email.trim();
          _loggedInUserName = prefs.getString(_prefKeyName)?.trim();
          if (_loggedInUserName != null && _loggedInUserName!.isEmpty) {
            _loggedInUserName = null;
          }
          return true;
        }
        return false;
      } catch (e) {
        final err = e.toString().toLowerCase();
        final isChannelOrPrefsError = err.contains('channel') ||
            err.contains('sharedpreferences') ||
            err.contains('pigeon');
        if (attempt < 2 && isChannelOrPrefsError) {
          await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
          continue;
        }
        if (!isChannelOrPrefsError) {
          assert(() {
            // ignore: avoid_print
            print('[AuthService] isLoggedInAsync failed: $e');
            return true;
          }());
        }
        return false;
      }
    }
    return false;
  }

  /// Persist login so user stays logged in across app restarts until logout.
  Future<void> _persistLoginState() async {
    if (_loggedInEmail == null || _loggedInEmail!.isEmpty) return;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final prefs = await _getPrefs();
        await prefs.setString(_prefKeyEmail, _loggedInEmail!);
        await prefs.setString(_prefKeyName, _loggedInUserName ?? '');
        return;
      } catch (e) {
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          continue;
        }
        assert(() {
          // ignore: avoid_print
          print('[AuthService] _persistLoginState failed: $e');
          return true;
        }());
      }
    }
  }

  Future<void> _clearPersistedLoginState() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_prefKeyEmail);
      await prefs.remove(_prefKeyName);
    } catch (_) {}
  }

  Future<String?> getLoggedInEmailAsync() async {
    return _loggedInEmail;
  }

  /// Returns the display name of the currently logged-in user. Uses in-memory name from login/register first, then Firebase if needed.
  Future<String?> getLoggedInUserNameAsync() async {
    if (_loggedInUserName != null && _loggedInUserName!.isNotEmpty) {
      return _loggedInUserName;
    }
    final email = _loggedInEmail;
    if (email == null || email.isEmpty) return null;
    try {
      final usersRef = await _getUsersRef();
      final emailKey = email.toLowerCase();
      final snapshot = await usersRef
          .orderByChild('email')
          .equalTo(emailKey)
          .limitToFirst(1)
          .get();

      final data = _firstChildAsMap(snapshot);
      if (data == null) return null;
      final name = data['name'];
      if (name is String && name.isNotEmpty) {
        _loggedInUserName = name;
        return name;
      }
    } catch (_) {}
    return null;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // ignore: avoid_print
    print('[AuthService] register() called '
        'name="$name", email="$email"');

    email = email.trim().toLowerCase();

    if (name.trim().isEmpty || email.isEmpty || password.isEmpty) {
      // ignore: avoid_print
      print('[AuthService] register() validation failed: '
          'name/email/password empty');
      throw ArgumentError('Name, email and password are required');
    }
    if (password.length < 6) {
      // ignore: avoid_print
      print('[AuthService] register() validation failed: '
          'password too short (${password.length})');
      throw ArgumentError('Password must be at least 6 characters');
    }

    try {
      final usersRef = await _getUsersRef();

      // Check if a user with this email already exists in Realtime DB.
      bool existingUserFound = false;
      try {
        final existing = await usersRef
            .orderByChild('email')
            .equalTo(email)
            .limitToFirst(1)
            .get();
        final existingUser = _firstChildAsMap(existing);
        existingUserFound = existingUser != null;
      } catch (_) {
        // TypeError or other read error (e.g. bad data in DB) → treat as no existing user
      }
      if (existingUserFound) {
        // ignore: avoid_print
        print('[AuthService] register() Firebase user already exists for email=$email');
        throw ArgumentError('An account with this email already exists');
      }

      // Create new user record in Realtime DB only.
      final createdAt = DateTime.now().toIso8601String();
      final newRef = usersRef.push();
      // ignore: avoid_print
      print('[AuthService] register() writing to Firebase path: /${newRef.path}');
      await newRef.set({
        'name': name.trim(),
        'email': email,
        'password': password.trim(),
        'createdAt': createdAt,
      });
      // ignore: avoid_print
      print('[AuthService] register() completed successfully, path=/${newRef.path}');
      _loggedInEmail = email;
      _loggedInUserName = name.trim().isNotEmpty ? name.trim() : null;
      await _persistLoginState();
    } on ArgumentError {
      rethrow;
    } catch (e, stack) {
      // ignore: avoid_print
      print('[AuthService] register() FAILED: $e');
      // ignore: avoid_print
      print('[AuthService] register() stack: $stack');
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission') || msg.contains('denied') || msg.contains('rules')) {
        throw ArgumentError(
          'Registration failed. Allow write access to the "users" path in Firebase Realtime Database rules.',
        );
      }
      if (e is TimeoutException || msg.contains('timeout') || msg.contains('connection') || msg.contains('network')) {
        throw ArgumentError(
          'Registration failed. Check your internet connection and try again.',
        );
      }
      if (e is TypeError) {
        throw ArgumentError(
          'Registration failed. Please try again or check Firebase database format.',
        );
      }
      throw ArgumentError('Registration failed. Please try again.');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final emailLower = email.trim().toLowerCase();
    final passwordTrimmed = password.trim();

    final usersRef = await _getUsersRef();
    // Load entire users node and find by email in code (avoids orderByChild + index,
    // and avoids SDK String/Map errors when DB has mixed data).
    Map<String, dynamic>? data;
    try {
      final snapshot = await usersRef.get();
      if (!snapshot.exists || snapshot.children.isEmpty) {
        data = null;
      } else {
        for (final child in snapshot.children) {
          final raw = child.value;
          if (raw is! Map) continue;
          try {
            final map = Map<String, dynamic>.from(raw as Map);
            final em = map['email'];
            if (em is String && em.trim().toLowerCase() == emailLower) {
              data = map;
              break;
            }
          } catch (_) {
            continue;
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AuthService] login() failed: $e');
      final msg = e.toString().toLowerCase();
      if (e is TimeoutException ||
          msg.contains('timeout') ||
          msg.contains('connection') ||
          msg.contains('network') ||
          msg.contains('socket')) {
        throw ArgumentError('Check your internet connection and try again.');
      }
      if (msg.contains('permission') || msg.contains('denied') || msg.contains('rules')) {
        throw ArgumentError('Server access denied. Check Firebase settings.');
      }
      throw ArgumentError('Invalid email or password');
    }

    if (data == null) {
      // ignore: avoid_print
      print('[AuthService] login() no user found for email=$emailLower');
      throw ArgumentError('Invalid email or password');
    }

    final storedPassword = data['password'];
    if (storedPassword is String && storedPassword != passwordTrimmed) {
      // ignore: avoid_print
      print('[AuthService] login() password mismatch for $emailLower');
      throw ArgumentError('Invalid email or password');
    }

    _loggedInEmail = emailLower;
    final name = data['name'];
    _loggedInUserName = (name is String && name.isNotEmpty) ? name : null;
    await _persistLoginState();
  }

  Future<void> logout() async {
    _loggedInEmail = null;
    _loggedInUserName = null;
    await _clearPersistedLoginState();
  }
}
