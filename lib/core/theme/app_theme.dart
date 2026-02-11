import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional light and dark themes for Crop Disease Detector.
/// Palette: nature greens with teal–emerald gradients, amber for alerts.
class AppTheme {
  AppTheme._();

  // —— Gradient colors (professional agriculture / nature) ——
  static const Color _gradientStartLight = Color(0xFF00695C);   // Teal
  static const Color _gradientEndLight = Color(0xFF2E7D32);     // Forest green
  static const Color _gradientStartDark = Color(0xFF004D40);
  static const Color _gradientEndDark = Color(0xFF1B5E20);

  /// Primary gradient for app bar, hero, and primary actions (light).
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_gradientStartLight, _gradientEndLight],
    stops: [0.0, 1.0],
  );

  /// Primary gradient for app bar and accents (dark).
  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00897B), Color(0xFF43A047)],
    stops: [0.0, 1.0],
  );

  /// Subtle surface gradient for scaffold (light).
  static const LinearGradient surfaceGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F5E9),
      Color(0xFFF1F8E9),
      Color(0xFFF5F9F4),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Subtle surface gradient for scaffold (dark).
  static const LinearGradient surfaceGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1F12),
      Color(0xFF111411),
      Color(0xFF0A0E0A),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // —— Light theme: fresh, vivid, nature-inspired ——
  static const Color _lightPrimary = Color(0xFF2E7D32);        // Forest green
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFC8E6C9);  // Soft mint
  static const Color _lightOnPrimaryContainer = Color(0xFF1B5E20);
  static const Color _lightSecondary = Color(0xFF00897B);       // Teal
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer = Color(0xFFB2DFDB);
  static const Color _lightOnSecondaryContainer = Color(0xFF00251A);
  static const Color _lightTertiary = Color(0xFFF9A825);     // Amber (disease/alert)
  static const Color _lightOnTertiary = Color(0xFF3E2723);
  static const Color _lightTertiaryContainer = Color(0xFFFFE0B2);
  static const Color _lightOnTertiaryContainer = Color(0xFF2B1700);
  static const Color _lightSurface = Color(0xFFF5F9F4);       // Warm off-white
  static const Color _lightSurfaceContainerLow = Color(0xFFE8F5E9);
  static const Color _lightSurfaceContainer = Color(0xFFE0EDE1);
  static const Color _lightSurfaceContainerHigh = Color(0xFFDCE3DA);
  static const Color _lightSurfaceContainerHighest = Color(0xFFC8D5CA);
  static const Color _lightOnSurface = Color(0xFF1A1D19);
  static const Color _lightOnSurfaceVariant = Color(0xFF414941);
  static const Color _lightOutline = Color(0xFF717971);
  static const Color _lightOutlineVariant = Color(0xFFC1C9C0);
  static const Color _lightError = Color(0xFFBA1A1A);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFFFDAD6);
  static const Color _lightOnErrorContainer = Color(0xFF410002);

  // —— Dark theme: deep, calm, gradient-friendly ——
  static const Color _darkPrimary = Color(0xFF81C784);      // Soft green
  static const Color _darkOnPrimary = Color(0xFF003910);
  static const Color _darkPrimaryContainer = Color(0xFF1B5E20);
  static const Color _darkOnPrimaryContainer = Color(0xFFC8E6C9);
  static const Color _darkSecondary = Color(0xFF4DB6AC);    // Teal
  static const Color _darkOnSecondary = Color(0xFF00251A);
  static const Color _darkSecondaryContainer = Color(0xFF004D40);
  static const Color _darkOnSecondaryContainer = Color(0xFFB2DFDB);
  static const Color _darkTertiary = Color(0xFFFFB74D);     // Lighter amber
  static const Color _darkOnTertiary = Color(0xFF4E2709);
  static const Color _darkTertiaryContainer = Color(0xFF6B3D00);
  static const Color _darkOnTertiaryContainer = Color(0xFFFFE0B2);
  static const Color _darkSurface = Color(0xFF111411);
  static const Color _darkSurfaceContainerLow = Color(0xFF1A1D19);
  static const Color _darkSurfaceContainer = Color(0xFF1E221D);
  static const Color _darkSurfaceContainerHigh = Color(0xFF282C27);
  static const Color _darkSurfaceContainerHighest = Color(0xFF333731);
  static const Color _darkOnSurface = Color(0xFFE3E6E1);
  static const Color _darkOnSurfaceVariant = Color(0xFFC1C9C0);
  static const Color _darkOutline = Color(0xFF8B938B);
  static const Color _darkOutlineVariant = Color(0xFF414941);
  static const Color _darkError = Color(0xFFFFB4AB);
  static const Color _darkOnError = Color(0xFF690005);
  static const Color _darkErrorContainer = Color(0xFF93000A);
  static const Color _darkOnErrorContainer = Color(0xFFFFDAD6);

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      secondaryContainer: _lightSecondaryContainer,
      onSecondaryContainer: _lightOnSecondaryContainer,
      tertiary: _lightTertiary,
      onTertiary: _lightOnTertiary,
      tertiaryContainer: _lightTertiaryContainer,
      onTertiaryContainer: _lightOnTertiaryContainer,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      surfaceContainerLowest: _lightSurface,
      surfaceContainerLow: _lightSurfaceContainerLow,
      surfaceContainer: _lightSurfaceContainer,
      surfaceContainerHigh: _lightSurfaceContainerHigh,
      surfaceContainerHighest: _lightSurfaceContainerHighest,
      onSurfaceVariant: _lightOnSurfaceVariant,
      outline: _lightOutline,
      outlineVariant: _lightOutlineVariant,
      error: _lightError,
      onError: _lightOnError,
      errorContainer: _lightErrorContainer,
      onErrorContainer: _lightOnErrorContainer,
    );
    final textTheme = _textThemeLight();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      secondaryContainer: _darkSecondaryContainer,
      onSecondaryContainer: _darkOnSecondaryContainer,
      tertiary: _darkTertiary,
      onTertiary: _darkOnTertiary,
      tertiaryContainer: _darkTertiaryContainer,
      onTertiaryContainer: _darkOnTertiaryContainer,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      surfaceContainerLowest: _darkSurface,
      surfaceContainerLow: _darkSurfaceContainerLow,
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
      onSurfaceVariant: _darkOnSurfaceVariant,
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      error: _darkError,
      onError: _darkOnError,
      errorContainer: _darkErrorContainer,
      onErrorContainer: _darkOnErrorContainer,
    );
    final textTheme = _textThemeDark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Light theme: all text must be dark on light background.
  static TextTheme _textThemeLight() {
    const onSurface = Color(0xFF1A1D19);
    const onSurfaceVariant = Color(0xFF414941);
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return TextTheme(
      displayLarge: base.displayLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
      displaySmall: base.displaySmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineLarge: base.headlineLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: onSurfaceVariant),
      bodySmall: base.bodySmall?.copyWith(color: onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: onSurfaceVariant),
      labelSmall: base.labelSmall?.copyWith(color: onSurfaceVariant),
    );
  }

  /// Dark theme: all text must be light on dark background.
  static TextTheme _textThemeDark() {
    const onSurface = Color(0xFFE3E6E1);
    const onSurfaceVariant = Color(0xFFC1C9C0);
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return TextTheme(
      displayLarge: base.displayLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
      displaySmall: base.displaySmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineLarge: base.headlineLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineMedium: base.headlineMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      headlineSmall: base.headlineSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: onSurfaceVariant),
      bodySmall: base.bodySmall?.copyWith(color: onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(color: onSurfaceVariant),
      labelSmall: base.labelSmall?.copyWith(color: onSurfaceVariant),
    );
  }
}
