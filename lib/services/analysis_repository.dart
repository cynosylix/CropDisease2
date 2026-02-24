import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Saves and fetches user analysis records (label, confidence, timestamp) in Firebase.
/// Path: users/{userId}/analyses/{pushId}
class AnalysisRepository {
  static const _usersPath = 'users';
  static const _analysesKey = 'analyses';

  DatabaseReference? _usersRef;

  Future<DatabaseReference> _getUsersRef() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    _usersRef ??= FirebaseDatabase.instance.ref(_usersPath);
    return _usersRef!;
  }

  /// Saves one analysis for the given user. No-op if userKey is null.
  Future<void> saveAnalysis({
    required String? userKey,
    required String label,
    required double confidence,
  }) async {
    if (userKey == null || userKey.isEmpty) return;
    try {
      final usersRef = await _getUsersRef();
      await usersRef.child(userKey).child(_analysesKey).push().set({
        'label': label,
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Fail silently so app still works offline / without Firebase
    }
  }

  /// Fetches all analyses for one user. Returns list of maps: label, confidence, timestamp.
  Future<List<Map<String, dynamic>>> getAnalysesForUser(String userKey) async {
    try {
      final usersRef = await _getUsersRef();
      final snapshot = await usersRef.child(userKey).child(_analysesKey).get();
      if (!snapshot.exists || snapshot.value == null) return [];
      final raw = snapshot.value;
      if (raw is! Map) return [];
      final list = <Map<String, dynamic>>[];
      for (final entry in raw.entries) {
        final val = entry.value;
        if (val is! Map) continue;
        final map = Map<String, dynamic>.from(val);
        final label = map['label'];
        final confidence = map['confidence'];
        final timestamp = map['timestamp'];
        if (label is String && timestamp is String) {
          list.add({
            'label': label,
            'confidence': confidence is num ? confidence.toDouble() : 0.0,
            'timestamp': timestamp,
          });
        }
      }
      list.sort((a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Fetches all users (for admin). Returns list of { key, name, email }.
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersRef = await _getUsersRef();
      final snapshot = await usersRef.get();
      if (!snapshot.exists || snapshot.children.isEmpty) return [];
      final list = <Map<String, dynamic>>[];
      for (final child in snapshot.children) {
        final raw = child.value;
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        list.add({
          'key': child.key,
          'name': map['name'] is String ? map['name'] : '',
          'email': map['email'] is String ? map['email'] : '',
        });
      }
      list.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
      return list;
    } catch (_) {
      return [];
    }
  }
}
