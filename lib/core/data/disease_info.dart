/// Disease information database with symptoms, treatment, and prevention tips.
///
/// Matches YOLO model (best.pt) classes from ml_server/inference_yolo.py.
/// Keyword mapping: healthy→Healthy, blight→Leaf Blight, rust→Rust, spot→Leaf Spot,
/// rot→Black Rot, mold→Mold, virus→Virus, mites→Spider Mites; else fallback.
class DiseaseInfo {
  /// All YOLO model class names (keep in sync with ml_server/inference_yolo.py).
  static const List<String> modelClassNames = [
    'Apple leaf',
    'Apple rust leaf',
    'Corn Gray leaf spot',
    'Corn leaf blight',
    'Corn rust leaf',
    'Potato leaf early blight',
    'Potato leaf late blight',
    'Tomato Septoria leaf spot',
    'Tomato leaf',
    'Tomato leaf bacterial spot',
    'Tomato leaf late blight',
    'Tomato leaf mosaic virus',
    'Tomato leaf yellow virus',
    'Tomato mold leaf',
    'Tomato two spotted spider mites leaf',
    'grape leaf',
    'grape leaf black rot',
  ];

  final String name;
  final String symptoms;
  final List<String> treatment;
  final List<String> prevention;
  final String severity;

  const DiseaseInfo({
    required this.name,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.severity,
  });

  /// Healthy leaf classes (no disease in name). Model predicts these for healthy leaves.
  static const List<String> _healthyLeafClasses = [
    'apple leaf',
    'tomato leaf',
    'grape leaf',
  ];

  static DiseaseInfo? getInfo(String diseaseName) {
    final name = diseaseName.toLowerCase().trim();

    // Healthy leaf classes: Apple leaf, Tomato leaf, grape leaf
    if (_healthyLeafClasses.contains(name)) {
      return const DiseaseInfo(
        name: 'Healthy',
        symptoms: 'No visible disease symptoms. Plant appears normal and healthy.',
        treatment: ['Continue regular care and monitoring'],
        prevention: [
          'Maintain proper watering schedule',
          'Ensure adequate sunlight',
          'Use balanced fertilizers',
          'Regular inspection for early signs',
        ],
        severity: 'None',
      );
    }

    if (name.contains('healthy')) {
      return const DiseaseInfo(
        name: 'Healthy',
        symptoms: 'No visible disease symptoms. Plant appears normal and healthy.',
        treatment: ['Continue regular care and monitoring'],
        prevention: [
          'Maintain proper watering schedule',
          'Ensure adequate sunlight',
          'Use balanced fertilizers',
          'Regular inspection for early signs',
        ],
        severity: 'None',
      );
    }
    
    if (name.contains('blight')) {
      return const DiseaseInfo(
        name: 'Leaf Blight',
        symptoms: 'Brown or black spots on leaves, yellowing, wilting, and premature leaf drop.',
        treatment: [
          'Remove and destroy infected leaves immediately',
          'Apply copper-based fungicides',
          'Improve air circulation around plants',
          'Water at the base, avoid wetting leaves',
          'Apply treatment every 7-10 days until symptoms clear',
        ],
        prevention: [
          'Plant disease-resistant varieties',
          'Maintain proper spacing between plants',
          'Avoid overhead watering',
          'Clean garden tools regularly',
          'Remove plant debris from garden',
        ],
        severity: 'High',
      );
    }
    
    if (name.contains('powdery') || name.contains('mildew')) {
      return const DiseaseInfo(
        name: 'Powdery Mildew',
        symptoms: 'White or gray powdery spots on leaves, stems, and sometimes flowers. Leaves may curl or turn yellow.',
        treatment: [
          'Remove severely infected leaves',
          'Apply neem oil or baking soda solution',
          'Use sulfur-based fungicides',
          'Increase air circulation',
          'Apply treatment weekly until resolved',
        ],
        prevention: [
          'Plant in areas with good air circulation',
          'Avoid overcrowding plants',
          'Water early in the day',
          'Choose resistant plant varieties',
          'Maintain proper humidity levels',
        ],
        severity: 'Medium',
      );
    }
    
    if (name.contains('rust')) {
      return const DiseaseInfo(
        name: 'Rust',
        symptoms: 'Orange, yellow, or brown pustules on leaf undersides. Leaves may turn yellow and drop prematurely.',
        treatment: [
          'Remove and destroy infected leaves',
          'Apply fungicides containing myclobutanil or propiconazole',
          'Improve air circulation',
          'Avoid overhead watering',
          'Treat every 10-14 days during growing season',
        ],
        prevention: [
          'Water plants at the base',
          'Ensure good air circulation',
          'Remove plant debris regularly',
          'Use resistant varieties when available',
          'Avoid working with wet plants',
        ],
        severity: 'Medium',
      );
    }
    
    if (name.contains('spot')) {
      return const DiseaseInfo(
        name: 'Leaf Spot',
        symptoms: 'Circular or irregular brown, black, or tan spots on leaves. Spots may have yellow halos.',
        treatment: [
          'Remove infected leaves promptly',
          'Apply copper-based fungicides',
          'Use chlorothalonil for severe cases',
          'Improve plant spacing',
          'Apply treatment every 7-10 days',
        ],
        prevention: [
          'Water at soil level, not on leaves',
          'Maintain proper plant spacing',
          'Remove fallen leaves and debris',
          'Use drip irrigation when possible',
          'Choose disease-resistant varieties',
        ],
        severity: 'Low to Medium',
      );
    }

    if (name.contains('mold') || name.contains('mildew')) {
      return const DiseaseInfo(
        name: 'Leaf Mold',
        symptoms: 'Gray or brown fuzzy mold on leaf undersides. Leaves may yellow and curl.',
        treatment: [
          'Remove infected leaves',
          'Apply fungicides (chlorothalonil or copper)',
          'Improve air circulation',
          'Reduce humidity',
        ],
        prevention: [
          'Water at soil level',
          'Ensure good air flow',
          'Avoid overhead watering',
          'Use resistant varieties',
        ],
        severity: 'Medium',
      );
    }

    if (name.contains('virus') || name.contains('mosaic')) {
      return const DiseaseInfo(
        name: 'Viral Disease',
        symptoms: 'Mottled, mosaic, or yellow patterns on leaves. Stunted growth, distorted leaves.',
        treatment: [
          'Remove and destroy infected plants',
          'Control aphids and other vectors',
          'No cure for viral infections',
        ],
        prevention: [
          'Use virus-free seed or transplants',
          'Control insect vectors',
          'Remove weeds that host viruses',
          'Sanitize tools between plants',
        ],
        severity: 'High',
      );
    }

    if (name.contains('mites') || name.contains('spider')) {
      return const DiseaseInfo(
        name: 'Spider Mites',
        symptoms: 'Stippling, yellowing, webbing on leaves. Tiny mites on undersides.',
        treatment: [
          'Spray with water to dislodge mites',
          'Apply insecticidal soap or neem oil',
          'Use miticides if severe',
        ],
        prevention: [
          'Maintain adequate humidity',
          'Avoid dusty conditions',
          'Inspect regularly',
          'Remove infested leaves early',
        ],
        severity: 'Low to Medium',
      );
    }

    if (name.contains('rot')) {
      return const DiseaseInfo(
        name: 'Black Rot / Rot',
        symptoms: 'Dark brown or black lesions on leaves, fruit, or stems. Leaves may yellow around affected areas and drop.',
        treatment: [
          'Remove and destroy all infected plant parts',
          'Apply copper-based fungicides early in season',
          'Improve air circulation and reduce humidity',
          'Avoid overhead watering',
          'Apply fungicide every 7-10 days during wet periods',
        ],
        prevention: [
          'Plant resistant varieties when available',
          'Ensure good drainage and air flow',
          'Water at base, keep foliage dry',
          'Remove and destroy crop debris at season end',
          'Rotate crops and avoid planting in same area',
        ],
        severity: 'High',
      );
    }

    // Fallback for any other detected disease so suggestions are always visible
    return DiseaseInfo(
      name: diseaseName,
      symptoms: 'Leaf or plant shows signs of disease. Early action can help save the crop.',
      treatment: [
        'Remove visibly infected leaves or parts',
        'Apply a broad-spectrum fungicide as per label',
        'Improve air circulation and avoid wetting leaves',
        'Ensure proper spacing and nutrition',
        'Monitor and repeat treatment if needed',
      ],
      prevention: [
        'Use disease-resistant varieties',
        'Water at soil level, not on foliage',
        'Keep garden clean; remove dead leaves and debris',
        'Ensure good drainage and sunlight',
        'Inspect plants regularly for early signs',
      ],
      severity: 'Medium',
    );
  }
}
