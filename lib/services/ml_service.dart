// =============================================================================
// ML service: uses only the server that runs assets/model/image-based.py
// (which uses leaf_disease_model.tflite in that folder). No on-device model.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for emulator (10.0.2.2 = host). On physical device, set "Analysis server URL" in Settings to your PC's IP.
const String _inferenceBaseUrl = 'http://10.0.2.2:8000';
/// When app auto-starts the Python server on desktop, it uses this URL.
const String _localServerUrl = 'http://127.0.0.1:8000';

const Duration _analysisTimeout = Duration(seconds: 120);
const Duration _serverStartWait = Duration(seconds: 10);

const String _prefKeyServerUrl = 'analysis_server_url';

/// mDNS service type advertised by the Python server for auto-discovery.
const String _mdnsServiceType = '_cropdisease._tcp.local';

class MlService {
  final String baseUrl;
  bool _initialized = false;
  /// When we auto-start the Python server on desktop, use this for predict.
  String? _effectiveServerUrl;
  static Process? _serverProcess;

  MlService({String? baseUrl}) : baseUrl = baseUrl ?? _inferenceBaseUrl;

  bool get isReady => _initialized;
  bool get useOnDevice => false;

  /// URL to use for requests. On physical device, use saved URL or auto-discovered server.
  Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKeyServerUrl)?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    if (Platform.isAndroid || Platform.isIOS) {
      final discovered = await _discoverServerUrl();
      if (discovered != null) {
        await prefs.setString(_prefKeyServerUrl, discovered);
        if (kDebugMode) debugPrint('[MlService] Auto-discovered server: $discovered');
        return discovered;
      }
    }
    return baseUrl;
  }

  /// Discover analysis server on local network via mDNS (when server runs with zeroconf).
  Future<String?> _discoverServerUrl() async {
    final client = MDnsClient();
    try {
      await client.start();
      await for (final PtrResourceRecord ptr
          in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(_mdnsServiceType)).timeout(const Duration(seconds: 5))) {
        await for (final SrvResourceRecord srv
            in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName)).timeout(const Duration(seconds: 3))) {
          String? ip;
          await for (final IPAddressResourceRecord addr
              in client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target)).timeout(const Duration(seconds: 2))) {
            ip = addr.address.address;
            break;
          }
          if (ip != null && ip.isNotEmpty) {
            final url = 'http://$ip:${srv.port}';
            try {
              final res = await http.get(Uri.parse('$url/health')).timeout(const Duration(seconds: 3));
              if (res.statusCode == 200) {
                client.stop();
                return url;
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[MlService] Discovery failed: $e');
    } finally {
      client.stop();
    }
    return null;
  }

  Future<void> init() async {
    final urlToTry = await _getBaseUrl();
    final serverUrl = await _ensureServerRunning(urlToTry);
    if (serverUrl != null) {
      _effectiveServerUrl = serverUrl;
      _initialized = true;
      if (kDebugMode) debugPrint('[MlService] Server ready (image-based.py): $serverUrl');
    }
  }

  /// Try health; on desktop if server not running, try to auto-start image-based server, then retry.
  Future<String?> _ensureServerRunning([String? firstUrl]) async {
    final url = _effectiveServerUrl ?? firstUrl ?? await _getBaseUrl();
    try {
      final res = await http.get(Uri.parse('$url/health')).timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw Exception('Server timeout'),
      );
      if (res.statusCode == 200) return url;
    } catch (_) {}

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      try {
        final r = await http.get(Uri.parse('$_localServerUrl/health')).timeout(const Duration(seconds: 4));
        if (r.statusCode == 200) return _localServerUrl;
      } catch (_) {}
    }

    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      if (kDebugMode) debugPrint('[MlService] Server not reached (mobile). Run server on PC or use on-device model.');
      return null;
    }

    final projectRoot = Platform.environment['CROP_DISEASE_PROJECT'];
    if (projectRoot == null || projectRoot.isEmpty) {
      if (kDebugMode) debugPrint('[MlService] Set CROP_DISEASE_PROJECT to project root to auto-start Python server.');
      return null;
    }

    if (_serverProcess != null) {
      try {
        final r = await http.get(Uri.parse('$_localServerUrl/health')).timeout(const Duration(seconds: 3));
        if (r.statusCode == 200) return _localServerUrl;
      } catch (_) {}
    }

    try {
      _serverProcess = await Process.start(
        'python',
        [
          '-m',
          'uvicorn',
          'ml_server.server_image_based:app',
          '--host',
          '127.0.0.1',
          '--port',
          '8000',
        ],
        workingDirectory: projectRoot,
        runInShell: Platform.isWindows,
        environment: Map<String, String>.from(Platform.environment),
      );
      await Future<void>.delayed(_serverStartWait);
      final res = await http.get(Uri.parse('$_localServerUrl/health')).timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw Exception('Timeout'),
      );
      if (res.statusCode == 200) {
        if (kDebugMode) debugPrint('[MlService] Auto-started image-based server at $_localServerUrl');
        return _localServerUrl;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[MlService] Auto-start server failed: $e');
    }
    return null;
  }

  /// Returns [label, confidence, isUncertain].
  Future<List<dynamic>> detect(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Image file is empty. Please choose a valid image.');
      }
      if (kDebugMode) debugPrint('[MlService] using server (image-based.py)');
      return await _runViaServer(bytes, imageFile.path.split(RegExp(r'[/\\]')).last);
    } on StateError catch (_) {
      throw Exception(
        'Analysis failed (model error). Try another image or a clearer photo of the leaf.',
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('precondition') || msg.contains('bad state')) {
        throw Exception(
          'Analysis failed. Please try another image or a clearer photo of the leaf.',
        );
      }
      rethrow;
    }
  }

  Future<List<dynamic>> _runViaServer(List<int> bytes, String fileName) async {
    final url = _effectiveServerUrl ?? await _getBaseUrl();
    final uri = Uri.parse('$url/predict');
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (kDebugMode) debugPrint('[MlService] Retrying analysis after timeout…');
      }
      try {
        return await _sendPredictRequest(uri, bytes, fileName.isEmpty ? 'image.jpg' : fileName);
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt == 1) {
          throw Exception(
            'Analysis timed out. On a physical device: run the server on your PC and set its IP in Settings → Analysis server URL (e.g. http://192.168.1.5:8000).',
          );
        }
      } on SocketException {
        throw Exception(
          'Cannot reach the server. On a physical device, set your PC\'s IP in Settings → Analysis server URL (e.g. http://192.168.1.5:8000). Phone and PC must be on the same Wi‑Fi.',
        );
      } on http.ClientException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('connection refused') || msg.contains('failed host lookup')) {
          throw Exception(
            'Server not reachable. On a physical device, set your PC\'s IP in Settings → Analysis server URL. Run server on PC: uvicorn ml_server.server_image_based:app --host 0.0.0.0 --port 8000',
          );
        }
        throw Exception('Network error: ${e.message}');
      } on FormatException {
        throw Exception('Invalid response from server. Restart the server and try again.');
      } on Exception {
        rethrow;
      }
    }
    throw lastError is Exception ? lastError : Exception('Analysis failed. Please try again.');
  }

  Future<List<dynamic>> _sendPredictRequest(Uri uri, List<int> bytes, String fileName) async {
    final multipart = http.MultipartRequest('POST', uri);
    multipart.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
    final streamed = await multipart.send().timeout(
      _analysisTimeout,
      onTimeout: () => throw TimeoutException('Analysis timed out'),
    );
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      final body = response.body;
      String msg = body.isNotEmpty ? body : 'Server error ${response.statusCode}';
      if (response.statusCode == 400) msg = 'Invalid image. Please choose a clear photo of a crop leaf.';
      if (response.statusCode >= 500) msg = 'Analysis server error. Try again or restart the server.';
      throw Exception(msg);
    }
    final json = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final label = json['label'] as String? ?? 'Unknown';
    final confidence = (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.0;
    if (label == 'Model not found' || label.contains('Model not found')) {
      throw Exception(
        'Model file missing. Add leaf_disease_model.tflite to the folder: assets/model/ (same folder as image-based.py), then restart the server.',
      );
    }
    final isUncertain = confidence < 0.5 || confidence < 0.15;
    if (kDebugMode) {
      debugPrint('========== MODEL OUTPUT (server) ==========');
      debugPrint('label: $label');
      debugPrint('confidence: $confidence');
      debugPrint('===========================================');
    }
    return [label, confidence, isUncertain];
  }
}

/// Result of inference (for compatibility if anything used runInference).
class InferenceResult {
  final int predictedIndex;
  final double confidence;
  final List<double> rawOutput;

  const InferenceResult({
    required this.predictedIndex,
    required this.confidence,
    required this.rawOutput,
  });
}
