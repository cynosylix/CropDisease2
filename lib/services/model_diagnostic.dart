/// Diagnostic tool to identify and fix model-label mismatches
class ModelDiagnostic {
  /// Get diagnostic information about model-label matching
  static Map<String, dynamic> diagnose({
    required int modelClasses,
    required List<String> labels,
    required String modelPath,
  }) {
    final diagnosis = <String, dynamic>{
      'modelPath': modelPath,
      'modelClasses': modelClasses,
      'labelCount': labels.length,
      'matches': modelClasses == labels.length,
      'issues': <String>[],
      'recommendations': <String>[],
    };
    
    // Check label count mismatch
    if (modelClasses != labels.length) {
      if (modelClasses > labels.length) {
        diagnosis['issues'].add(
          'Model expects $modelClasses classes but labels.txt has only ${labels.length} labels'
        );
        diagnosis['recommendations'].add(
          'Update labels.txt to have exactly $modelClasses labels'
        );
        diagnosis['recommendations'].add(
          'Get the label list from your model\'s training dataset'
        );
        diagnosis['recommendations'].add(
          'Ensure labels are in the SAME ORDER as model training'
        );
      } else {
        diagnosis['issues'].add(
          'Model expects $modelClasses classes but labels.txt has ${labels.length} labels (too many)'
        );
        diagnosis['recommendations'].add(
          'Remove ${labels.length - modelClasses} labels from labels.txt'
        );
        diagnosis['recommendations'].add(
          'Keep only the first $modelClasses labels that match model training order'
        );
      }
    }
    
    // Check for common issues
    if (labels.isEmpty) {
      diagnosis['issues'].add('Labels file is empty');
      diagnosis['recommendations'].add('Add disease labels to labels.txt');
    }
    
    // Check for duplicates
    final seen = <String>{};
    for (var i = 0; i < labels.length; i++) {
      final lower = labels[i].toLowerCase().trim();
      if (seen.contains(lower)) {
        diagnosis['issues'].add('Duplicate label at index $i: "${labels[i]}"');
        diagnosis['recommendations'].add('Remove duplicate labels');
      }
      seen.add(lower);
    }
    
    return diagnosis;
  }
  
  /// Generate fix instructions
  static String generateFixInstructions(Map<String, dynamic> diagnosis) {
    final buffer = StringBuffer();
    buffer.writeln('=' * 70);
    buffer.writeln('FIX INSTRUCTIONS');
    buffer.writeln('=' * 70);
    buffer.writeln();
    
    if (diagnosis['issues'].isEmpty) {
      buffer.writeln('✅ No issues found! Model and labels match perfectly.');
      return buffer.toString();
    }
    
    buffer.writeln('ISSUES FOUND:');
    for (var i = 0; i < diagnosis['issues'].length; i++) {
      buffer.writeln('  ${i + 1}. ${diagnosis['issues'][i]}');
    }
    buffer.writeln();
    
    buffer.writeln('HOW TO FIX:');
    for (var i = 0; i < diagnosis['recommendations'].length; i++) {
      buffer.writeln('  ${i + 1}. ${diagnosis['recommendations'][i]}');
    }
    buffer.writeln();
    
    if (diagnosis['modelClasses'] > diagnosis['labelCount']) {
      buffer.writeln('STEP-BY-STEP:');
      buffer.writeln('  1. Find out what labels your model was trained with');
      buffer.writeln('  2. Open: assets/labels/labels.txt');
      buffer.writeln('  3. Replace with exactly ${diagnosis['modelClasses']} labels');
      buffer.writeln('  4. Ensure labels are in the SAME ORDER as training');
      buffer.writeln('  5. One label per line, no empty lines');
      buffer.writeln('  6. Save the file');
      buffer.writeln('  7. Restart the app');
      buffer.writeln();
      buffer.writeln('EXAMPLE (if model has 38 classes - PlantVillage dataset):');
      buffer.writeln('  Apple___Apple_scab');
      buffer.writeln('  Apple___Black_rot');
      buffer.writeln('  Apple___Cedar_apple_rust');
      buffer.writeln('  ... (38 labels total)');
    }
    
    buffer.writeln('=' * 70);
    return buffer.toString();
  }
}
