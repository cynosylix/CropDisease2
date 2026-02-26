import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations_delegate.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/disease_detection/presentation/screens/home_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }
  SharedPreferences? prefs;
  for (var i = 0; i < 3; i++) {
    try {
      prefs = await SharedPreferences.getInstance();
      break;
    } catch (_) {
      if (i < 2) await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }
  runApp(CropDiseaseApp(prefs: prefs));
}

class CropDiseaseApp extends StatefulWidget {
  const CropDiseaseApp({super.key, this.prefs});

  final SharedPreferences? prefs;

  @override
  State<CropDiseaseApp> createState() => _CropDiseaseAppState();
}

class _CropDiseaseAppState extends State<CropDiseaseApp> {
  Locale _locale = const Locale('en');
  bool _isLoggedIn = false;
  bool _authChecked = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(prefs: widget.prefs);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  /// Restore session from storage; show LoginScreen only if user logged out previously.
  /// Timeout ensures we never stay stuck on the loading spinner.
  Future<void> _checkAuth() async {
    try {
      final loggedIn = await _authService.isLoggedInAsync().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
      if (mounted) {
        setState(() {
          _isLoggedIn = loggedIn;
          _authChecked = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _authChecked = true;
        });
      }
    } finally {
      // Ensure we never stay on loading forever
      if (mounted && !_authChecked) {
        setState(() {
          _authChecked = true;
          _isLoggedIn = false;
        });
      }
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Disease Detector',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ml'),
        Locale('hi'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _isLoggedIn
          ? (_authService.isAdmin
              ? AdminDashboardScreen(
                  authService: _authService,
                  onLogout: _onLogout,
                  currentLocale: _locale,
                  onLocaleChanged: _setLocale,
                  getAnalyzeScreen: () => HomeScreen(
                    authService: _authService,
                    currentLocale: _locale,
                    onLocaleChanged: _setLocale,
                    onLogout: _onLogout,
                  ),
                )
              : HomeScreen(
                  authService: _authService,
                  currentLocale: _locale,
                  onLocaleChanged: _setLocale,
                  onLogout: _onLogout,
                ))
          : LoginScreen(
              authService: _authService,
              currentLocale: _locale,
              onLocaleChanged: _setLocale,
              onLoginSuccess: _onLoginSuccess,
            ),
    );
  }
}
