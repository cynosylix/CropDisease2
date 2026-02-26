import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Saves and fetches user analysis records (image, label, confidence, timestamp) in Firebase.
/// Image: try Storage first; always store a small base64 thumbnail in Realtime DB so History works without Storage.
/// Realtime DB: users/{userId}/analyses/{pushId} -> { imageUrl?, imageBase64?, label, confidence, timestamp }
class AnalysisRepository {
  static const _usersPath = 'users';
  static const _analysesKey = 'analyses';
  static const _storageAnalysesPath = 'users';

  /// Storage bucket from Firebase config (must match google-services.json / GoogleService-Info.plist).
  static String? _storageBucket;

  static FirebaseStorage get _storage {
    if (Firebase.apps.isEmpty) return FirebaseStorage.instance;
    final bucket = Firebase.app().options.storageBucket ?? _storageBucket;
    if (bucket != null && bucket.isNotEmpty) {
      _storageBucket ??= bucket;
      return FirebaseStorage.instanceFor(bucket: bucket);
    }
    return FirebaseStorage.instance;
  }

  DatabaseReference? _usersRef;

  Future<DatabaseReference> _getUsersRef() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    _usersRef ??= FirebaseDatabase.instance.ref(_usersPath);
    return _usersRef!;
  }

  /// Builds a small JPEG thumbnail (max 200px) as base64 for storing in Realtime DB (no Storage needed).
  static String? thumbnailBase64(List<int> imageBytes) {
    try {
      final decoded = img.decodeImage(Uint8List.fromList(imageBytes));
      if (decoded == null) return null;
      const int maxSize = 200;
      final resized = decoded.width > maxSize || decoded.height > maxSize
          ? img.copyResize(decoded, width: maxSize, height: maxSize, interpolation: img.Interpolation.linear)
          : decoded;
      final jpeg = img.encodeJpg(resized, quality: 72);
      if (jpeg.length > 500000) return null; // ~500KB cap
      return base64Encode(jpeg);
    } catch (_) {
      return null;
    }
  }

  /// Saves one analysis for the given user. Uploads image to Storage if [imageBytes] provided.
  /// No-op if userKey is null.
  Future<void> saveAnalysis({
    required String? userKey,
    required String label,
    required double confidence,
    List<int>? imageBytes,
  }) async {
    if (userKey == null || userKey.isEmpty) return;
    try {
      final usersRef = await _getUsersRef();
      final analysesRef = usersRef.child(userKey).child(_analysesKey);
      final pushRef = analysesRef.push();
      final pushKey = pushRef.key;
      if (pushKey == null) return;

      String? imageUrl;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        try {
          final ref = _storage
              .ref()
              .child(_storageAnalysesPath)
              .child(userKey)
              .child(_analysesKey)
              .child('$pushKey.jpg');
          await ref.putData(
            Uint8List.fromList(imageBytes),
            SettableMetadata(contentType: 'image/jpeg'),
          );
          imageUrl = await ref.getDownloadURL();
          if (kDebugMode) {
            // ignore: avoid_print
            print('[AnalysisRepository] Image uploaded: $imageUrl');
          }
        } catch (e) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[AnalysisRepository] Image upload skipped: $e');
            // ignore: avoid_print
            print('[AnalysisRepository] Storage may require Blaze plan. Analysis saved without image; History will show label/date only.');
          }
        }
      }

      final data = <String, dynamic>{
        'label': label,
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
      };
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      // Always store a small base64 thumbnail so History shows image without Firebase Storage
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final thumb = thumbnailBase64(imageBytes);
        if (thumb != null) data['imageBase64'] = thumb;
      }
      await pushRef.set(data);
    } catch (_) {
      // Fail silently so app still works offline / without Firebase
    }
  }

  /// Fetches all analyses for one user.
  /// Returns list of maps: id, imageUrl?, label, confidence, timestamp.
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
        final timestamp = map['timestamp'];
        if (label is String && timestamp is String) {
          list.add({
            'id': entry.key,
            'imageUrl': map['imageUrl'] is String ? map['imageUrl'] as String? : null,
            'imageBase64': map['imageBase64'] is String ? map['imageBase64'] as String? : null,
            'label': label,
            'confidence': map['confidence'] is num ? (map['confidence'] as num).toDouble() : 0.0,
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
