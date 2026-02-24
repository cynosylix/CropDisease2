// =============================================================================
// ML service: on-device ONNX (no server) or fallback to HTTP inference server.
// Run ml_server/export_onnx.py once to create assets/model/best.onnx and
// assets/data/class_names.json; then the app runs inference locally.
// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// Base URL of the inference server (used only when on-device ONNX is not available).
const String _inferenceBaseUrl = 'http://10.0.2.2:8000';

const Duration _analysisTimeout = Duration(seconds: 90);

/// Default input size for ONNX model (must match export_onnx.py imgsz).
/// Detection models use 640; classification use 224.
const int _onnxInputSize = 640;

class MlService {
  final String baseUrl;
  bool _initialized = false;
  bool _useOnDevice = false;
  OrtSession? _onnxSession;
  Map<int, String> _classNames = {};
  String _onnxInputName = 'images';
  String _onnxOutputName = 'output0';

  MlService({String? baseUrl}) : baseUrl = baseUrl ?? _inferenceBaseUrl;

  bool get isReady => _initialized;
  bool get useOnDevice => _useOnDevice;

  Future<void> init() async {
    try {
      await _loadOnDeviceModel();
      if (_useOnDevice) {
        _initialized = true;
        if (kDebugMode) debugPrint('[MlService] On-device ONNX model ready (no server needed).');
        return;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[MlService] On-device model not used: $e');
    }

    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Server timeout'),
      );
      if (res.statusCode == 200) {
        _initialized = true;
        if (kDebugMode) debugPrint('[MlService] best.pt server ready: $baseUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MlService] Server not reached. Run ml_server or export ONNX: $e');
      }
    }
  }

  Future<void> _loadOnDeviceModel() async {
    final ort = OnnxRuntime();
    final session = await ort.createSessionFromAsset('assets/model/best.onnx');
    final namesData = await rootBundle.load('assets/data/class_names.json');
    final namesJson = utf8.decode(namesData.buffer.asUint8List());
    final map = jsonDecode(namesJson) as Map<dynamic, dynamic>;
    final classNames = <int, String>{};
    for (final e in map.entries) {
      classNames[int.parse(e.key.toString())] = e.value.toString();
    }
    _onnxSession = session;
    _classNames = classNames;
    _useOnDevice = true;
    try {
      final inNames = session.inputNames;
      if (inNames.isNotEmpty) _onnxInputName = inNames.first;
      final outNames = session.outputNames;
      if (outNames.isNotEmpty) _onnxOutputName = outNames.first;
    } catch (_) {}
  }

  /// Returns [label, confidence, isUncertain].
  Future<List<dynamic>> detect(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      throw Exception('Image file is empty. Please choose a valid image.');
    }
    if (_useOnDevice && _onnxSession != null) {
      return _runOnDevice(bytes);
    }
    return _runViaServer(bytes, imageFile.path.split(RegExp(r'[/\\]')).last);
  }

  Future<List<dynamic>> _runOnDevice(List<int> bytes) async {
    final session = _onnxSession!;
    final decoded = img.decodeImage(Uint8List.fromList(bytes));
    if (decoded == null) {
      throw Exception('Could not decode image. Please choose another image.');
    }
    final resized = img.copyResize(decoded, width: _onnxInputSize, height: _onnxInputSize);
    // NCHW, float32, 0..1
    final floats = <double>[];
    for (var c = 0; c < 3; c++) {
      for (var y = 0; y < _onnxInputSize; y++) {
        for (var x = 0; x < _onnxInputSize; x++) {
          final pixel = resized.getPixel(x, y);
          final v = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
          floats.add(v / 255.0);
        }
      }
    }
    OrtValue? inputTensor;
    try {
      inputTensor = await OrtValue.fromList(floats, [1, 3, _onnxInputSize, _onnxInputSize]);
      final inputs = {_onnxInputName: inputTensor};
      final outputs = await session.run(inputs);
      inputTensor.dispose();
      final outputTensor = outputs[_onnxOutputName];
      if (outputTensor == null) {
        throw Exception('On-device model returned no output.');
      }
      final outputList = await outputTensor.asList();
      outputTensor.dispose();
      if (outputList.isEmpty) {
        throw Exception('On-device model output empty.');
      }
      final raw = outputList is List<double> ? outputList : List<double>.from(outputList as List<num>);
      final numClasses = _classNames.length;
      int topIdx;
      double maxVal;
      // YOLO detection: shape (1, 4+numClasses, 8400) -> take max over class scores
      if (raw.length > 1000 && numClasses > 0) {
        const int numBoxes = 8400;
        final numRows = 4 + numClasses; // 4 box + class scores
        if (raw.length >= numRows * numBoxes) {
          topIdx = 0;
          maxVal = 0.0;
          for (var c = 0; c < numClasses; c++) {
            final base = (4 + c) * numBoxes;
            for (var b = 0; b < numBoxes; b++) {
              final v = raw[base + b];
              if (v > maxVal) {
                maxVal = v;
                topIdx = c;
              }
            }
          }
        } else {
          topIdx = 0;
          maxVal = raw.isNotEmpty ? raw[0] : 0.0;
          for (var i = 1; i < raw.length && i < numClasses; i++) {
            if (raw[i] > maxVal) {
              maxVal = raw[i];
              topIdx = i;
            }
          }
        }
      } else {
        // Classification: output [1, num_classes]
        topIdx = 0;
        maxVal = raw.isNotEmpty ? raw[0] : 0.0;
        for (var i = 1; i < raw.length; i++) {
          if (raw[i] > maxVal) {
            maxVal = raw[i];
            topIdx = i;
          }
        }
      }
      final label = _classNames[topIdx] ?? 'Class_$topIdx';
      final confidence = maxVal.clamp(0.0, 1.0);
      final isUncertain = confidence < 0.5 || confidence < 0.15;
      return [label, confidence, isUncertain];
    } catch (e) {
      inputTensor?.dispose();
      rethrow;
    }
  }

  Future<List<dynamic>> _runViaServer(List<int> bytes, String fileName) async {
    final uri = Uri.parse('$baseUrl/predict');
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
            'Analysis timed out. Start the server (ml_server) or use on-device model (run export_onnx.py).',
          );
        }
      } on SocketException {
        throw Exception(
          'Cannot reach the analysis server. Start it (uvicorn in ml_server) or export ONNX for on-device inference.',
        );
      } on http.ClientException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('connection refused') || msg.contains('failed host lookup')) {
          throw Exception(
            'Analysis server is not running. Start it in ml_server or use on-device model (export_onnx.py).',
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
    final isUncertain = confidence < 0.5 || confidence < 0.15;
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
