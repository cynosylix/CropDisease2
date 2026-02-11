import 'package:flutter/material.dart';

/// Simple in-app localization without relying on generated ARB files.
///
/// Supports: English (en), Malayalam (ml), Hindi (hi), Tamil (ta).
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    // Fallback to English if the delegate hasn't loaded yet for some reason.
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _values = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Crop Disease Detector',
      'homeSubtitle':
          'Take or select a leaf photo to detect disease using the offline model.',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'noImage': 'No image selected',
      'tapToAddPhoto': 'Tap to add photo',
      'analyzing': 'Analyzing image...',
      'error': 'Something went wrong while analyzing. Please try again.',
      'disease': 'Disease',
      'confidence': 'Confidence',
      'settings': 'Settings',
      'language': 'Language',
      'langEnglish': 'English',
      'langMalayalam': 'Malayalam / മലയാളം',
      'langHindi': 'Hindi / हिन्दी',
      'langTamil': 'Tamil / தமிழ்',
      'clearImage': 'Clear image',
      'reAnalyze': 'Analyze again',
      'retry': 'Retry',
      'about': 'About',
      'aboutTitle': 'About Crop Disease Detector',
      'aboutDescription':
          'This app uses an on-device AI model to detect common plant leaf diseases. Works fully offline. Take or pick a photo of a leaf to get started.',
      'healthy': 'Healthy',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'confirmPassword': 'Confirm password',
      'loginTitle': 'Welcome back',
      'registerTitle': 'Create account',
      'noAccount': "Don't have an account? Register",
      'haveAccount': 'Already have an account? Login',
      'invalidEmailPassword': 'Invalid email or password',
      'passwordTooShort': 'Password must be at least 6 characters',
      'emailExists': 'An account with this email already exists',
      'fieldRequired': 'This field is required',
      'passwordsDoNotMatch': 'Passwords do not match',
      'hello': 'Hello',
      'loggedInAs': 'Logged in as',
    },
    'ml': {
      'appTitle': 'വിള രോഗനിർണയം',
      'homeSubtitle': 'ഇലയുടെ ഫോട്ടോ എടുത്ത്‌ രോഗം കണ്ടെത്തുക (ഓഫ്‌ലൈൻ മോഡൽ).',
      'camera': 'ക്യാമറ',
      'gallery': 'ഗാലറി',
      'noImage': 'ചിത്രം തിരഞ്ഞെടുക്കാത്തതാണ്',
      'tapToAddPhoto': 'ഫോട്ടോ ചേർക്കാൻ ടാപ്പ് ചെയ്യുക',
      'analyzing': 'ചിത്രം വിശകലനം ചെയ്യുന്നു...',
      'error': 'ഏതോ പിഴവ് സംഭവിച്ചു. ദയവായി വീണ്ടും ശ്രമിക്കുക.',
      'disease': 'രോഗം',
      'confidence': 'വിശ്വാസനില',
      'settings': 'സെറ്റിംഗ്സ്',
      'language': 'ഭാഷ',
      'langEnglish': 'ഇംഗ്ലീഷ്',
      'langMalayalam': 'മലയാളം',
      'langHindi': 'ഹിന്ദി',
      'langTamil': 'തമിഴ്',
      'clearImage': 'ചിത്രം നീക്കം ചെയ്യുക',
      'reAnalyze': 'വീണ്ടും വിശകലനം',
      'retry': 'വീണ്ടും ശ്രമിക്കുക',
      'about': 'അബൗട്ട്',
      'aboutTitle': 'വിള രോഗനിർണയം',
      'aboutDescription':
          'ഇല രോഗങ്ങൾ കണ്ടെത്താൻ ഓഫ്‌ലൈൻ AI മോഡൽ ഉപയോഗിക്കുന്നു. ഒരു ഇലയുടെ ഫോട്ടോ എടുക്കുക അല്ലെങ്കിൽ തിരഞ്ഞെടുക്കുക.',
      'healthy': 'ആരോഗ്യമുള്ള',
      'login': 'ലോഗിൻ',
      'register': 'രജിസ്റ്റർ',
      'logout': 'ലോഗൗട്ട്',
      'email': 'ഇമെയിൽ',
      'password': 'പാസ്‌വേഡ്',
      'name': 'പേര്',
      'confirmPassword': 'പാസ്‌വേഡ് ഉറപ്പിക്കുക',
      'loginTitle': 'വീണ്ടും സ്വാഗതം',
      'registerTitle': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'noAccount': 'അക്കൗണ്ട് ഇല്ലേ? രജിസ്റ്റർ ചെയ്യുക',
      'haveAccount': 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ? ലോഗിൻ',
      'invalidEmailPassword': 'ഇമെയിൽ അല്ലെങ്കിൽ പാസ്‌വേഡ് തെറ്റാണ്',
      'passwordTooShort': 'പാസ്‌വേഡ് 6 അക്ഷരമെങ്കിലും ആയിരിക്കണം',
      'emailExists': 'ഈ ഇമെയിൽ ഉപയോഗിച്ച് ഇതിനകം അക്കൗണ്ട് ഉണ്ട്',
      'fieldRequired': 'ഈ ഫീൽഡ് ആവശ്യമാണ്',
      'passwordsDoNotMatch': 'പാസ്‌വേഡുകൾ യോജിക്കുന്നില്ല',
      'hello': 'നമസ്കാരം',
      'loggedInAs': 'ലോഗിൻ ചെയ്തത്',
    },
    'hi': {
      'appTitle': 'फसल रोग पहचान',
      'homeSubtitle': 'पत्ते की फोटो लेकर रोग पहचानें (ऑफ़लाइन मॉडल).',
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'noImage': 'कोई फोटो चुनी नहीं गई',
      'tapToAddPhoto': 'फोटो जोड़ने के लिए टैप करें',
      'analyzing': 'तस्वीर की जाँच हो रही है...',
      'error': 'कुछ गलत हो गया। कृपया फिर से कोशिश करें।',
      'disease': 'रोग',
      'confidence': 'विश्वास स्तर',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'langEnglish': 'English',
      'langMalayalam': 'Malayalam',
      'langHindi': 'हिन्दी',
      'langTamil': 'तमिल',
      'clearImage': 'फोटो हटाएं',
      'reAnalyze': 'फिर से जाँचें',
      'retry': 'पुनः प्रयास करें',
      'about': 'के बारे में',
      'aboutTitle': 'फसल रोग पहचान के बारे में',
      'aboutDescription':
          'यह ऐप पत्तों की बीमारियाँ पहचानने के लिए ऑफ़लाइन AI मॉडल इस्तेमाल करता है। शुरू करने के लिए पत्ते की फोटो लें या चुनें।',
      'healthy': 'स्वस्थ',
      'login': 'लॉग इन',
      'register': 'रजिस्टर',
      'logout': 'लॉग आउट',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'loginTitle': 'वापस स्वागत है',
      'registerTitle': 'खाता बनाएं',
      'noAccount': 'खाता नहीं है? रजिस्टर करें',
      'haveAccount': 'पहले से खाता है? लॉग इन',
      'invalidEmailPassword': 'गलत ईमेल या पासवर्ड',
      'passwordTooShort': 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए',
      'emailExists': 'इस ईमेल से पहले से खाता मौजूद है',
      'fieldRequired': 'यह फ़ील्ड आवश्यक है',
      'passwordsDoNotMatch': 'पासवर्ड मेल नहीं खाते',
      'hello': 'नमस्ते',
      'loggedInAs': 'लॉग इन',
    },
    'ta': {
      'appTitle': 'பயிர் நோய் கண்டறிதல்',
      'homeSubtitle':
          'இலை புகைப்படத்தை எடுத்து அல்லது தேர்வு செய்து நோயை கண்டறியுங்கள் (ஆஃப்லைன் மாடல்).',
      'camera': 'கேமராக்',
      'gallery': 'கேலரி',
      'noImage': 'படம் எதுவும் தேர்வு செய்யப்படவில்லை',
      'tapToAddPhoto': 'படம் சேர்க்க தட்டவும்',
      'analyzing': 'படம் பகுப்பாய்வு செய்யப்படுகிறது...',
      'error': 'ஏதோ பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.',
      'disease': 'நோய்',
      'confidence': 'நம்பகத்தன்மை',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி',
      'langEnglish': 'ஆங்கிலம்',
      'langMalayalam': 'மலையாளம்',
      'langHindi': 'ஹிந்தி',
      'langTamil': 'தமிழ்',
      'clearImage': 'படத்தை அழி',
      'reAnalyze': 'மீண்டும் பகுப்பாய்வு',
      'retry': 'மீண்டும் முயற்சி',
      'about': 'பற்றி',
      'aboutTitle': 'பயிர் நோய் கண்டறிதல் பற்றி',
      'aboutDescription':
          'இலை நோய்களை கண்டறிய இந்த பயன்பாடு ஆஃப்லைன் AI மாடலைப் பயன்படுத்துகிறது. தொடங்க ஒரு இலையின் படத்தை எடுக்கவும் அல்லது தேர்ந்தெடுக்கவும்.',
      'healthy': 'ஆரோக்கியமான',
      'login': 'உள்நுழை',
      'register': 'பதிவு',
      'logout': 'வெளியேறு',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'name': 'பெயர்',
      'confirmPassword': 'கடவுச்சொல்லை உறுதிசெய்',
      'loginTitle': 'மீண்டும் வரவேற்கிறோம்',
      'registerTitle': 'கணக்கு உருவாக்கு',
      'noAccount': 'கணக்கு இல்லையா? பதிவு செய்யுங்கள்',
      'haveAccount': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையுங்கள்',
      'invalidEmailPassword': 'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல்',
      'passwordTooShort': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்',
      'emailExists': 'இந்த மின்னஞ்சலுடன் ஏற்கனவே கணக்கு உள்ளது',
      'fieldRequired': 'இந்த புலம் தேவை',
      'passwordsDoNotMatch': 'கடவுச்சொற்கள் பொருந்தவில்லை',
      'hello': 'வணக்கம்',
      'loggedInAs': 'உள்நுழைந்துள்ளார்',
    },
  };

  String _t(String key) {
    final code = locale.languageCode;
    return _values[code]?[key] ?? _values['en']![key] ?? key;
  }

  String get appTitle => _t('appTitle');
  String get homeSubtitle => _t('homeSubtitle');
  String get camera => _t('camera');
  String get gallery => _t('gallery');
  String get noImage => _t('noImage');
  String get tapToAddPhoto => _t('tapToAddPhoto');
  String get analyzing => _t('analyzing');
  String get error => _t('error');
  String get disease => _t('disease');
  String get confidence => _t('confidence');
  String get settings => _t('settings');
  String get language => _t('language');
  String get langEnglish => _t('langEnglish');
  String get langMalayalam => _t('langMalayalam');
  String get langHindi => _t('langHindi');
  String get langTamil => _t('langTamil');
  String get clearImage => _t('clearImage');
  String get reAnalyze => _t('reAnalyze');
  String get retry => _t('retry');
  String get about => _t('about');
  String get aboutTitle => _t('aboutTitle');
  String get aboutDescription => _t('aboutDescription');
  String get healthy => _t('healthy');
  String get login => _t('login');
  String get register => _t('register');
  String get logout => _t('logout');
  String get email => _t('email');
  String get password => _t('password');
  String get name => _t('name');
  String get confirmPassword => _t('confirmPassword');
  String get loginTitle => _t('loginTitle');
  String get registerTitle => _t('registerTitle');
  String get noAccount => _t('noAccount');
  String get haveAccount => _t('haveAccount');
  String get invalidEmailPassword => _t('invalidEmailPassword');
  String get passwordTooShort => _t('passwordTooShort');
  String get emailExists => _t('emailExists');
  String get fieldRequired => _t('fieldRequired');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get hello => _t('hello');
  String get loggedInAs => _t('loggedInAs');
}

