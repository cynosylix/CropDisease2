import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Automatically fixes labels.txt by detecting model class count
/// and generating appropriate labels
class AutoLabelFixer {
  static const String modelPath = 'assets/model/plant_disease_mobilenet.tflite';
  static const String labelsPath = 'assets/labels/labels.txt';
  
  /// Detect model class count and generate labels.txt
  static Future<void> autoFix() async {
    try {
      print('\n' + '=' * 70);
      print('🔧 AUTO-FIXING labels.txt');
      print('=' * 70);
      
      // Load model to get class count
      final interpreter = await Interpreter.fromAsset(modelPath);
      final outputTensor = interpreter.getOutputTensor(0);
      final numClasses = outputTensor.shape.last;
      
      print('✅ Detected model class count: $numClasses');
      
      // Load current labels
      final currentLabels = await _loadCurrentLabels();
      print('📋 Current labels count: ${currentLabels.length}');
      
      if (currentLabels.length == numClasses) {
        print('✅ Labels already match! No fix needed.');
        interpreter.close();
        return;
      }
      
      // Generate new labels
      final newLabels = _generateLabels(numClasses, currentLabels);
      
      // Write to file
      await _writeLabels(newLabels);
      
      print('\n✅ AUTO-FIX COMPLETE!');
      print('📝 Updated labels.txt with $numClasses labels');
      print('⚠️  NOTE: Some labels may be placeholders (Class_X)');
      print('⚠️  You should replace them with actual disease names');
      print('⚠️  Get real labels from your model\'s training dataset');
      print('=' * 70);
      
      interpreter.close();
    } catch (e) {
      print('❌ Error auto-fixing labels: $e');
    }
  }
  
  static Future<List<String>> _loadCurrentLabels() async {
    try {
      final raw = await rootBundle.loadString(labelsPath);
      return raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !e.startsWith('#'))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  static List<String> _generateLabels(int numClasses, List<String> currentLabels) {
    final labels = <String>[];
    
    // Common plant disease labels (if model has 5 classes)
    final common5Labels = [
      'Healthy',
      'Leaf Blight',
      'Powdery Mildew',
      'Rust',
      'Leaf Spot',
    ];
    
    // PlantVillage 38 classes (common dataset)
    final plantVillage38Labels = [
      'Apple___Apple_scab',
      'Apple___Black_rot',
      'Apple___Cedar_apple_rust',
      'Apple___Healthy',
      'Blueberry___Healthy',
      'Cherry___Powdery_mildew',
      'Cherry___Healthy',
      'Corn___Cercospora_leaf_spot',
      'Corn___Common_rust',
      'Corn___Northern_Leaf_Blight',
      'Corn___Healthy',
      'Grape___Black_rot',
      'Grape___Esca',
      'Grape___Leaf_blight',
      'Grape___Healthy',
      'Orange___Haunglongbing',
      'Peach___Bacterial_spot',
      'Peach___Healthy',
      'Pepper_bell___Bacterial_spot',
      'Pepper_bell___Healthy',
      'Potato___Early_blight',
      'Potato___Late_blight',
      'Potato___Healthy',
      'Raspberry___Healthy',
      'Soybean___Healthy',
      'Squash___Powdery_mildew',
      'Strawberry___Leaf_scorch',
      'Strawberry___Healthy',
      'Tomato___Bacterial_spot',
      'Tomato___Early_blight',
      'Tomato___Late_blight',
      'Tomato___Leaf_Mold',
      'Tomato___Septoria_leaf_spot',
      'Tomato___Spider_mites',
      'Tomato___Target_Spot',
      'Tomato___Yellow_Leaf_Curl_Virus',
      'Tomato___Mosaic_virus',
      'Tomato___Healthy',
    ];
    
    // Try to use existing labels if they match count
    if (currentLabels.length == numClasses) {
      return currentLabels;
    }
    
    // Try common patterns
    if (numClasses == 5 && currentLabels.length <= 5) {
      // Use common 5-class labels, preserving existing ones
      for (var i = 0; i < numClasses; i++) {
        if (i < currentLabels.length && !currentLabels[i].startsWith('Class_')) {
          labels.add(currentLabels[i]);
        } else if (i < common5Labels.length) {
          labels.add(common5Labels[i]);
        } else {
          labels.add('Class_$i');
        }
      }
      return labels;
    }
    
    if (numClasses == 38 && plantVillage38Labels.length == 38) {
      return plantVillage38Labels;
    }
    
    // Generic: preserve existing labels, add placeholders for missing
    for (var i = 0; i < numClasses; i++) {
      if (i < currentLabels.length && !currentLabels[i].startsWith('Class_')) {
        labels.add(currentLabels[i]);
      } else {
        labels.add('Class_$i');
      }
    }
    
    return labels;
  }
  
  static Future<void> _writeLabels(List<String> labels) async {
    final file = File('assets/labels/labels.txt');
    final content = labels.join('\n');
    await file.writeAsString(content);
  }
}
