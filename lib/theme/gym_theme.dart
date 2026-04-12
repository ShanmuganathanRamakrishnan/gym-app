import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        surface: colors.background,
        primary: colors.accent,
        onPrimary: colors.textPrimary,
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
        color: colors.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
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

  // Kinetic Onyx Base
  final background = const Color(0xFF0E0E0E);
  final surface = const Color(0xFF0E0E0E); // Ink layer
  
  // Tonal Layering
  final surfaceContainerLow = const Color(0xFF131313);
  final surfaceContainerHigh = const Color(0xFF20201F);
  final surfaceContainerHighest = const Color(0xFF262626);
  
  // Legacy aliases to not break existing usage
  final surfaceElevated = const Color(0xFF20201F); // Maps to high
  final divider = const Color(0xFF131313); // Subtle separator
  final border = const Color(0xFF131313);

  // Typography Colors
  final textPrimary = const Color(0xFFFFFFFF);
  final textSecondary = const Color(0xFFB3B3B3); // Approx 70% white
  final textMuted = const Color(0xFFADAAAA); // on_surface_variant

  // Orange Accent Colors
  final accent = const Color(0xFFFF8F6F); // primary
  final accentContainer = const Color(0xFFFF7851); 
  final accentDim = const Color(0xFFFF734A); 
  
  // Brand Supplements
  final tertiary = const Color(0xFFEEACFF);
  final errorDim = const Color(0xFFD7383B);
  final outlineVariant = const Color(0xFF484847);
}

class _AppSpacing {
  const _AppSpacing();

  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 16.0;
  final double lg = 24.0;
  final double xl = 32.0;
  final double xxl = 48.0;
  
  // The system's standard generosity for cards
  final double cardInternal = 24.0; // 1.5rem
}

class _AppRadius {
  const _AppRadius();

  final double sm = 8.0;
  final double md = 12.0; 
  final double lg = 16.0;
  final double xl = 24.0;

  double get card => lg; // Slightly more rounded cards
  double get button => md; // 0.75rem roundedness for buttons
}

class _AppTextStyles {
  const _AppTextStyles();

  TextStyle get screenTitle => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get sectionTitle => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get cardTitle => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: GymTheme.colors.textPrimary,
      );

  TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        color: GymTheme.colors.textSecondary,
        height: 1.4,
      );

  TextStyle get secondary => GoogleFonts.inter(
        fontSize: 12,
        color: GymTheme.colors.textMuted,
      );

  TextStyle get headline => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: GymTheme.colors.textPrimary,
      );
      
  // New specific design system requirements
  TextStyle get displayLg => GoogleFonts.manrope(
        fontSize: 56, 
        fontWeight: FontWeight.w800,
        color: GymTheme.colors.textPrimary,
        height: 1.1,
      );
      
  TextStyle get metric => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: GymTheme.colors.textPrimary,
      );
}
