import 'package:flutter/material.dart';

class AppTheme {
  // Color constants from Figma design
  static const Color primaryBlack = Color(0xFF1A1A1A);
  static const Color secondaryGray = Color(0xFF6B7280);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color accentLightGreen = Color(0xFF34D399);

  // Glow colors for modern UI effects
  static const Color glowBlue = Color(0xFF3B82F6);
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color glowGreen = Color(0xFF10B981);
  static const Color glowOrange = Color(0xFFF59E0B);
  static const Color glowRed = Color(0xFFEF4444);

  // Gradient colors for "Simplified" text - exact Figma colors
  static const List<Color> simplifiedGradientColors = [
    Color(0xFF4285F4), // S - Blue
    Color(0xFF8B5CF6), // i - Purple
    Color(0xFFEF4444), // m - Red
    Color(0xFFF59E0B), // p - Orange
    Color(0xFF10B981), // l - Green
    Color(0xFF34D399), // i - Light Green
    Color(0xFFEAB308), // f - Yellow
    Color(0xFFF97316), // i - Orange
    Color(0xFFDC2626), // e - Red
    Color(0xFF7C3AED), // d - Purple
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlack,
        secondary: secondaryGray,
        surface: backgroundWhite,
        onPrimary: backgroundWhite,
        onSecondary: primaryBlack,
        onSurface: primaryBlack,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.02,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.02,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: -0.01,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: secondaryGray,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: secondaryGray,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryGray,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryBlack,
          fontFamily: 'Inter',
          letterSpacing: 0.01,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundWhite,
          foregroundColor: primaryBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
