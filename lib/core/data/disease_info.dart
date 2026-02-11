/// Disease information database with symptoms, treatment, and prevention tips
class DiseaseInfo {
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
    
    return null;
  }
}
