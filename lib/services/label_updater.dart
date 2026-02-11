/// Helper tool to update labels.txt based on model requirements
class LabelUpdater {
  /// Generate a template labels.txt based on model class count
  static String generateTemplate(int numClasses, {List<String>? knownLabels}) {
    final buffer = StringBuffer();
    buffer.writeln('# Labels for plant_disease_mobilenet.tflite');
    buffer.writeln('# Model expects: $numClasses classes');
    buffer.writeln('# IMPORTANT: Labels must be in the EXACT ORDER as model training');
    buffer.writeln('#');
    buffer.writeln('# Replace the lines below with your actual labels');
    buffer.writeln('# One label per line, no empty lines');
    buffer.writeln('#');
    
    if (knownLabels != null && knownLabels.length == numClasses) {
      buffer.writeln('# Using provided labels:');
      for (var label in knownLabels) {
        buffer.writeln(label);
      }
    } else {
      buffer.writeln('# Example labels (REPLACE with your actual labels):');
      for (var i = 0; i < numClasses; i++) {
        buffer.writeln('Class_$i  # TODO: Replace with actual label name');
      }
    }
    
    return buffer.toString();
  }
  
  /// Validate labels file format
  static List<String> validateLabelsFile(String content) {
    final issues = <String>[];
    final lines = content.split('\n');
    final labels = <String>[];
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;
      
      // Remove inline comments
      final label = line.split('#').first.trim();
      if (label.isEmpty) continue;
      
      labels.add(label);
    }
    
    // Check for duplicates
    final seen = <String>{};
    for (var i = 0; i < labels.length; i++) {
      final lower = labels[i].toLowerCase();
      if (seen.contains(lower)) {
        issues.add('Duplicate label at line ${i + 1}: "${labels[i]}"');
      }
      seen.add(lower);
    }
    
    return issues;
  }
}
