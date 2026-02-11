import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/data/disease_info.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ml_service.dart';
import 'about_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.currentLocale,
    required this.onLocaleChanged,
    this.onLogout,
  });

  final AuthService authService;
  final Locale currentLocale;
  final void Function(Locale) onLocaleChanged;
  final VoidCallback? onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _mlService = MlService();
  late final Future<String?> _userNameFuture;

  File? _image;
  String? _label;
  double? _confidence;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userNameFuture = widget.authService.getLoggedInUserNameAsync();
    // Load ML model in background so UI stays responsive
    _mlService.init();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      setState(() {
        _image = File(picked.path);
        _label = null;
        _confidence = null;
      });
      await _runDetection();
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? AppLocalizations.of(context).error);
      }
    }
  }

  Future<void> _runDetection() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _mlService.detect(_image!);
      if (result.length < 2) {
        throw Exception('Invalid result from ML service');
      }
      
      var label = result[0] as String;
      final conf = result[1] as double;
      final isUncertain = result.length > 2 ? (result[2] as bool) : false;
      
      // Safety check: Never display "Class_X" labels
      if (label.startsWith('Class_')) {
        print('⚠️  UI Safety: Filtered out Class_X label: $label');
        label = 'Unknown'; // Fallback to Unknown if we somehow get Class_X
      }
      
      // Validate result
      if (label.isEmpty) {
        throw Exception('Model returned invalid label. Please try another image.');
      }
      
      if (conf.isNaN || conf < 0 || conf > 1) {
        throw Exception('Model returned invalid confidence value.');
      }
      
      // If confidence is extremely low, treat as "Unknown"
      String displayLabel = label;
      if (conf < 0.15) {
        print('⚠️  Very low confidence (${(conf * 100).toStringAsFixed(1)}%) - treating as uncertain/unknown');
        displayLabel = 'Unknown';
      }
      
      if (mounted) {
        setState(() {
          _label = displayLabel;
          _confidence = conf;
          // Show warning for low confidence but still display the result
          if (conf < 0.15) {
            _error = 'Very low confidence (${(conf * 100).toStringAsFixed(0)}%). The image may not be recognized. Please try a clearer image of a crop leaf.';
          } else if (isUncertain && conf < 0.5) {
            _error = 'Low confidence prediction (${(conf * 100).toStringAsFixed(0)}%). Result may be uncertain - please verify or try another image.';
          } else if (conf < 0.3) {
            _error = 'Low confidence (${(conf * 100).toStringAsFixed(0)}%). Result may be inaccurate.';
          } else {
            _error = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppLocalizations.of(context).error}\n${e.toString()}';
          _label = null;
          _confidence = null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _label = null;
      _confidence = null;
      _error = null;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          authService: widget.authService,
          currentLocale: widget.currentLocale,
          onLocaleChanged: widget.onLocaleChanged,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 400;
    final horizontalPadding = isCompact ? 20.0 : 28.0;

    final isDark = theme.brightness == Brightness.dark;
    final appBarGradient = isDark ? AppTheme.primaryGradientDark : AppTheme.primaryGradientLight;
    final surfaceGradient = isDark ? AppTheme.surfaceGradientDark : AppTheme.surfaceGradientLight;

    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: surfaceGradient),
        child: Column(
          children: [
            // Gradient app bar
            Container(
              padding: EdgeInsets.only(top: topPadding),
              decoration: BoxDecoration(gradient: appBarGradient),
              child: AppBar(
                  title: Text(
                    loc.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_outlined, size: 22),
                      tooltip: loc.settings,
                    ),
                    IconButton(
                      onPressed: _openAbout,
                      icon: const Icon(Icons.info_outline, size: 22),
                      tooltip: loc.about,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final useWideLayout = maxWidth > 520;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                padding.left + horizontalPadding,
                8,
                padding.right + horizontalPadding,
                padding.bottom + 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: useWideLayout ? 480 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero / header
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  theme.colorScheme.primary.withOpacity(0.25),
                                  theme.colorScheme.secondary.withOpacity(0.15),
                                ]
                              : [
                                  theme.colorScheme.primary.withOpacity(0.18),
                                  theme.colorScheme.secondary.withOpacity(0.08),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.eco_rounded,
                              size: 32,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FutureBuilder<String?>(
                              future: _userNameFuture,
                              builder: (context, snapshot) {
                                final name = snapshot.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (name != null && name.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          '${loc.hello}, $name',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      loc.homeSubtitle,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Image preview card
                    Material(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 0,
                      shadowColor: theme.colorScheme.shadow.withOpacity(0.08),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: _image != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(_image!, fit: BoxFit.cover),
                                      if (!_loading)
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Material(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(12),
                                            child: InkWell(
                                              onTap: _clearImage,
                                              borderRadius: BorderRadius.circular(12),
                                              child: const Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : InkWell(
                                    onTap: () => _pick(ImageSource.gallery),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.08),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_photo_alternate_rounded,
                                              size: 40,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            loc.noImage,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            loc.tapToAddPhoto,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_loading) ...[
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primaryContainer.withOpacity(0.3),
                              theme.colorScheme.secondaryContainer.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.psychology_rounded,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              loc.analyzing,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Analyzing image with AI model...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Processing...',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (!_loading) ...[
                      if (_image == null) ...[
                        _GradientButton(
                          onPressed: () => _pick(ImageSource.camera),
                          icon: Icons.camera_alt_rounded,
                          label: loc.camera,
                          gradient: appBarGradient,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded, size: 22),
                          label: Text(loc.gallery),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearImage,
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                label: Text(loc.clearImage),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _runDetection,
                                icon: const Icon(Icons.refresh_rounded, size: 20),
                                label: Text(loc.reAnalyze),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Show warning if there's an error, but still show result
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Always show result if available, even with low confidence
                      if (_label != null && _confidence != null) ...[
                        _EnhancedResultCard(
                          label: _label!,
                          confidence: _confidence!,
                          loc: loc,
                          theme: theme,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      ),
            ],
          ),
        ),
    );
  }
}

class _EnhancedResultCard extends StatelessWidget {
  const _EnhancedResultCard({
    required this.label,
    required this.confidence,
    required this.loc,
    required this.theme,
  });

  final String label;
  final double confidence;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isHealthy = label.toLowerCase().contains('healthy');
    final diseaseInfo = DiseaseInfo.getInfo(label);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: isHealthy
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.tertiaryContainer,
                  theme.colorScheme.errorContainer.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isHealthy
                  ? theme.colorScheme.primary
                  : theme.colorScheme.tertiary)
              .withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isHealthy
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isHealthy
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.tertiary)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isHealthy 
                            ? Icons.check_circle_rounded 
                            : Icons.warning_amber_rounded,
                        size: 32,
                        color: isHealthy
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isHealthy
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onTertiaryContainer,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (diseaseInfo != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isHealthy
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.tertiary)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Severity: ${diseaseInfo.severity}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isHealthy
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Confidence Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence Level',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isHealthy
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(confidence * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isHealthy
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: confidence,
                        minHeight: 14,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHealthy
                              ? theme.colorScheme.primary
                              : theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Disease Information Section
          if (diseaseInfo != null) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            if (!isHealthy) ...[
              _InfoSection(
                title: 'Symptoms',
                content: diseaseInfo.symptoms,
                icon: Icons.visibility_rounded,
                theme: theme,
                isHealthy: isHealthy,
              ),
              _InfoSection(
                title: 'Treatment Steps',
                content: diseaseInfo.treatment,
                icon: Icons.medical_services_rounded,
                theme: theme,
                isHealthy: isHealthy,
                isList: true,
              ),
              _InfoSection(
                title: 'Prevention Tips',
                content: diseaseInfo.prevention,
                icon: Icons.shield_rounded,
                theme: theme,
                isHealthy: isHealthy,
                isList: true,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.eco_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Plant Status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      diseaseInfo.symptoms,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Maintenance Tips:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...diseaseInfo.prevention.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.theme,
    required this.isHealthy,
    this.isList = false,
  });

  final String title;
  final dynamic content; // String or List<String>
  final IconData icon;
  final ThemeData theme;
  final bool isHealthy;
  final bool isList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isHealthy
                    ? theme.colorScheme.primary
                    : theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isHealthy
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isList && content is List<String>)
            ...content.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: (isHealthy
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isHealthy
                                ? theme.colorScheme.primary
                                : theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isHealthy
                              ? theme.colorScheme.onPrimaryContainer.withOpacity(0.85)
                              : theme.colorScheme.onTertiaryContainer.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            Text(
              content as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isHealthy
                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.85)
                    : theme.colorScheme.onTertiaryContainer.withOpacity(0.85),
                height: 1.6,
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
