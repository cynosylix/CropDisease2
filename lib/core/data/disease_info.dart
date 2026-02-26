/// Disease information database with symptoms, treatment, and prevention tips.
///
/// Matches all 13 classes from the leaf_disease_model (inference_image_based.py):
/// - Apple: Black_rot, healthy
/// - Corn (maize): Common_rust_, healthy
/// - Grape: Black_rot, healthy, Leaf_blight_(Isariopsis_Leaf_Spot)
/// - Potato: Early_blight, healthy, Late_blight
/// - Tomato: Early_blight, healthy, Late_blight
/// Mapping: healthy→Healthy, blight→Leaf Blight, rust→Rust, spot→Leaf Spot, rot→Black Rot; else fallback.
class DiseaseInfo {
  /// All 13 model class names (keep in sync with ml_server/inference_image_based.py CLASS_NAMES).
  static const List<String> modelClassNames = [
    'Apple___Black_rot',
    'Apple___healthy',
    'Corn_(maize)___Common_rust_',
    'Corn_(maize)___healthy',
    'Grape___Black_rot',
    'Grape___healthy',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Potato___Early_blight',
    'Potato___healthy',
    'Potato___Late_blight',
    'Tomato___Early_blight',
    'Tomato___healthy',
    'Tomato___Late_blight',
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

  static DiseaseInfo? getInfo(String diseaseName) {
    final name = diseaseName.toLowerCase();
    
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
