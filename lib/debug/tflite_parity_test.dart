// Isolated TFLite parity test. Run with: flutter run -t lib/debug/tflite_parity_test.dart
// Matches Python: load_img(224,224), img_to_array/255.0, expand_dims, set_tensor, invoke, get_tensor[0], argmax, max.

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

const _modelPath = 'assets/model/plant_disease_mobilenet.tflite';
const _testImagePath = 'assets/test/tflite_test_image.jpg';
const _size = 224;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final interpreter = await Interpreter.fromAsset(_modelPath);
  final inputTensor = interpreter.getInputTensor(0);
  final outputTensor = interpreter.getOutputTensor(0);
  final inputShape = inputTensor.shape;
  final outputShape = outputTensor.shape;

  final imageData = await rootBundle.load(_testImagePath);
  final bytes = imageData.buffer.asUint8List();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    print('ERROR: Could not decode image from $_testImagePath');
    return;
  }

  final resized = img.copyResize(decoded, width: _size, height: _size);
  final x = List.generate(
    1,
    (_) => List.generate(
      _size,
      (y) => List.generate(
        _size,
        (x) {
          final pixel = resized.getPixel(x, y);
          return <double>[
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        },
      ),
    ),
  );

  final numClasses = outputShape.length == 2 ? outputShape[1] : outputShape[0];
  final output = List.generate(1, (_) => List.filled(numClasses, 0.0));
  interpreter.run(x, output);
  final predictions = output[0];

  int idx = 0;
  double best = predictions[0];
  for (int i = 1; i < predictions.length; i++) {
    if (predictions[i] > best) {
      best = predictions[i];
      idx = i;
    }
  }
  final confidence = best;

  print('INPUT SHAPE: [1, $_size, $_size, 3]');
  print('OUTPUT SHAPE: $outputShape');
  print('RAW OUTPUT: $predictions');
  print('PREDICTED INDEX: $idx');
  print('CONFIDENCE: $confidence');

  interpreter.close();
}
