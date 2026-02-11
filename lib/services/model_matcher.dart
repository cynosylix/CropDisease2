/// Diagnostic tool to verify if app configuration matches TFLite model
class ModelMatcher {
  /// Check if preprocessing matches model expectations
  static Map<String, dynamic> checkPreprocessing({
    required List<int> inputShape,
    required String inputType,
    required List<int> outputShape,
    required String outputType,
  }) {
    final checks = <String, dynamic>{};
    
    // Check input size
    if (inputShape.length >= 4) {
      final height = inputShape[1];
      final width = inputShape[2];
      final channels = inputShape[3];
      
      checks['inputSize'] = {
        'expected': '$width x $height',
        'configured': '224 x 224',
        'matches': width == 224 && height == 224,
      };
      
      checks['inputChannels'] = {
        'expected': channels,
        'configured': 3,
        'matches': channels == 3,
      };
    }
    
    // Check input type
    checks['inputType'] = {
      'expected': inputType,
      'configured': 'float32 (ImageNet normalization)',
      'matches': inputType == 'float32',
      'preprocessing': inputType == 'float32' 
        ? 'ImageNet normalization (R=123.68, G=116.78, B=103.94, std=255.0)'
        : 'Direct uint8 values',
    };
    
    // Check output
    checks['outputClasses'] = {
      'expected': outputShape.last,
      'configured': '5 labels',
      'matches': false, // Will be set based on labels
    };
    
    return checks;
  }
  
  /// Check if labels match model output
  static Map<String, dynamic> checkLabels({
    required int modelClasses,
    required List<String> labels,
  }) {
    final checks = <String, dynamic>{};
    
    checks['count'] = {
      'model': modelClasses,
      'labels': labels.length,
      'matches': modelClasses == labels.length,
    };
    
    if (modelClasses != labels.length) {
      checks['mismatch'] = {
        'issue': modelClasses > labels.length
          ? 'Model has MORE classes than labels'
          : 'Model has FEWER classes than labels',
        'difference': (modelClasses - labels.length).abs(),
      };
    }
    
    checks['labels'] = labels;
    
    return checks;
  }
  
  /// Generate comprehensive match report
  static String generateReport({
    required Map<String, dynamic> preprocessing,
    required Map<String, dynamic> labels,
    required String modelPath,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('=' * 70);
    buffer.writeln('MODEL MATCHING REPORT');
    buffer.writeln('=' * 70);
    buffer.writeln('Model: $modelPath');
    buffer.writeln();
    
    buffer.writeln('PREPROCESSING:');
    buffer.writeln('  Input Size: ${preprocessing['inputSize']?['matches'] == true ? '✅' : '❌'}');
    if (preprocessing['inputSize'] != null) {
      buffer.writeln('    Expected: ${preprocessing['inputSize']['expected']}');
      buffer.writeln('    Configured: ${preprocessing['inputSize']['configured']}');
    }
    buffer.writeln('  Input Type: ${preprocessing['inputType']?['matches'] == true ? '✅' : '❌'}');
    if (preprocessing['inputType'] != null) {
      buffer.writeln('    Expected: ${preprocessing['inputType']['expected']}');
      buffer.writeln('    Preprocessing: ${preprocessing['inputType']['preprocessing']}');
    }
    buffer.writeln();
    
    buffer.writeln('LABELS:');
    buffer.writeln('  Count Match: ${labels['count']?['matches'] == true ? '✅' : '❌'}');
    if (labels['count'] != null) {
      buffer.writeln('    Model classes: ${labels['count']['model']}');
      buffer.writeln('    Labels file: ${labels['count']['labels']}');
      if (labels['mismatch'] != null) {
        buffer.writeln('    ⚠️  ${labels['mismatch']['issue']}');
        buffer.writeln('    ⚠️  Difference: ${labels['mismatch']['difference']} classes');
      }
    }
    buffer.writeln();
    
    final allMatch = (preprocessing['inputSize']?['matches'] == true) &&
                     (preprocessing['inputType']?['matches'] == true) &&
                     (labels['count']?['matches'] == true);
    
    buffer.writeln('OVERALL: ${allMatch ? '✅ MATCHES' : '❌ MISMATCH DETECTED'}');
    buffer.writeln('=' * 70);
    
    return buffer.toString();
  }
}
