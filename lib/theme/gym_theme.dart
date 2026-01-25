import 'package:flutter/material.dart';

class GymTheme {
  // Colors
  static const colors = _AppColors();

  // Spacing (8px grid)
  static const spacing = _AppSpacing();

  // Radius
  static const radius = _AppRadius();

  // Text Styles
  static const text = _AppTextStyles();

  // ThemeData
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        primary: colors.accent,
        onPrimary: Colors.white,
        onSurface: colors.textPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.card),
        ),
      ),
      // Add other theme defaults here
    );
  }
}

class _AppColors {
  const _AppColors();

  final background = const Color(0xFF0E0E0E);
  final surface = const Color(
      0xFF1E1E1E); // Adjusted to match recent usages (was 1A1A1A in main, but 1E1E1E in widgets)
  final surfaceElevated =
      const Color(0xFF2C2C2E); // Lighter surface for interaction/elevation
  final divider = const Color(0xFF2A2A2A);

  final textPrimary = const Color(0xFFFFFFFF);
  final textSecondary = const Color(0xFFB3B3B3); // ~70%
  final textMuted = const Color(0xFF6B6B6B); // ~40%

  final accent = const Color(0xFFFC4C02); // Strava orange
  final accentDim = const Color(0x33FC4C02); // 20% opacity
}

class _AppSpacing {
  const _AppSpacing();

  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 16.0;
  final double lg = 24.0;
  final double xl = 32.0;
  final double xxl = 48.0;
}

class _AppRadius {
  const _AppRadius();

  final double sm = 8.0;
  final double md = 12.0; // Standard card
  final double lg = 16.0; // Large containers
  final double xl = 24.0;

  double get card => md;
}

class _AppTextStyles {
  const _AppTextStyles();

  TextStyle get screenTitle => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get sectionTitle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get cardTitle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get body => TextStyle(
        fontSize: 14,
        color: GymTheme.colors.textSecondary,
        height: 1.4,
      );

  TextStyle get secondary => TextStyle(
        fontSize: 12,
        color: GymTheme.colors.textMuted,
      );

  TextStyle get headline => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: GymTheme.colors.textPrimary,
      );
}
