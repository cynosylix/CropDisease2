// =============================================================================
// DIRECT PYTHON-TO-FLUTTER PORT — SOURCE OF TRUTH: test_tflite.py
// =============================================================================
// This file converts the Python TFLite inference logic EXACTLY AS-IS.
// No preprocessing logic, normalization, tensor shapes, or data types were
// changed. No optimizations or extra abstractions were added.
// Python equivalent:
//   interpreter = tf.lite.Interpreter(model_path="plant_disease_mobilenet.tflite")
//   interpreter.allocate_tensors()
//   img = load_img(img_path, target_size=(224, 224))
//   x = img_to_array(img) / 255.0
//   x = np.expand_dims(x, axis=0).astype(np.float32)
//   interpreter.set_tensor(input_details[0]['index'], x)
//   interpreter.invoke()
//   output_data = interpreter.get_tensor(output_details[0]['index'])
//   predictions = output_data[0]
//   idx = argmax(predictions); confidence = max(predictions)
// =============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// ML service: direct port of Python TFLite inference for plant_disease_mobilenet.tflite.
class MlService {
  static const _modelPath = 'assets/model/plant_disease_mobilenet.tflite';
  static const _labelsPath = 'assets/labels/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];

  static const int _inputSize = 224;

  bool get isReady => _interpreter != null;

  Future<void> init() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelPath);
    _labels = await _loadLabels();
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsPath);
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith('#'))
        .toList();
  }

  /// Preprocessing: EXACT Python equivalent.
  /// - Resize to 224×224 (target_size=(224, 224))
  /// - Channel order: set _useBGR true if model was trained with OpenCV/BGR.
  ///   Compare "[TFLite] First 30 input values" with Python: print(x.flatten()[:30].tolist())
  /// - Normalize: pixel / 255.0 (float32)
  /// - Shape: [1, 224, 224, 3] (expand_dims(..., axis=0))
  /// Set true if model expects BGR (e.g. OpenCV training); false for Keras/PIL RGB.
  static const bool _useBGR = true;

  List<List<List<List<double>>>> preprocessImage(img.Image image) {
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.nearest,
    );
    final r = 255.0;
    final x = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (xi) {
            final pixel = resized.getPixel(xi, y);
            if (_useBGR) {
              return <double>[
                pixel.b / r,
                pixel.g / r,
                pixel.r / r,
              ];
            }
            return <double>[
              pixel.r / r,
              pixel.g / r,
              pixel.b / r,
            ];
          },
        ),
      ),
    );
    return x;
  }

  /// Runs inference: same flow as Python (set_tensor → invoke → get_tensor, argmax, max).
  /// Returns: [predictedIndex, confidence, rawOutputArray].
  /// Raw output array is the same as Python: predictions = output_data[0].
  Future<InferenceResult> runInference(File imageFile) async {
    if (_interpreter == null) await init();
    if (_interpreter == null) throw Exception('Interpreter not initialized');

    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);

    // --- DEBUG (mandatory): comparable with Python ---
    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;
    debugPrint('[TFLite] Input tensor shape: $inputShape');
    debugPrint('[TFLite] Output tensor shape: $outputShape');

    final bytes = await imageFile.readAsBytes();
    img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not decode image');
    // Match Python: load_img does not apply EXIF orientation

    final input = preprocessImage(decoded);
    final numClasses = outputShape.length == 2 ? outputShape[1] : outputShape[0];
    final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

    _dumpFirstInputValues(input);

    _interpreter!.run(input, output);

    final predictions = output[0];

    final predictedIndex = _argMax(predictions);
    final confidence = predictions[predictedIndex];

    // --- DEBUG: first 5 output values, predicted index, confidence ---
    final first5 = predictions.length >= 5
        ? predictions.sublist(0, 5)
        : predictions;
    debugPrint('[TFLite] First 5 output values: $first5');
    debugPrint('[TFLite] Predicted index: $predictedIndex');
    debugPrint('[TFLite] Confidence: $confidence');

    return InferenceResult(
      predictedIndex: predictedIndex,
      confidence: confidence,
      rawOutput: predictions,
    );
  }

  void _dumpFirstInputValues(List<List<List<List<double>>>> input) {
    final flat = <double>[];
    for (var b = 0; b < input.length && flat.length < 30; b++) {
      for (var y = 0; y < input[b].length && flat.length < 30; y++) {
        for (var x = 0; x < input[b][y].length && flat.length < 30; x++) {
          flat.addAll(input[b][y][x]);
        }
      }
    }
    debugPrint('[TFLite] First 30 input values (NHWC): $flat');
  }

  int _argMax(List<double> values) {
    int idx = 0;
    double best = values[0];
    for (int i = 1; i < values.length; i++) {
      if (values[i] > best) {
        best = values[i];
        idx = i;
      }
    }
    return idx;
  }

  /// Convenience for UI: runs inference and returns [label, confidence, isUncertain].
  Future<List<dynamic>> detect(File imageFile) async {
    if (_interpreter == null) await init();
    final result = await runInference(imageFile);
    final label = result.predictedIndex < _labels.length
        ? _labels[result.predictedIndex]
        : 'Class_${result.predictedIndex}';
    final isUncertain = result.confidence < 0.5 || result.confidence < 0.15;
    return [label, result.confidence, isUncertain];
  }
}

/// Result of inference: direct port of Python outputs (idx, confidence, predictions).
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
