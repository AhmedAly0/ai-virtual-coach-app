import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color accentRed = Color(0xFFFF3B30); // Vibrant red for actions
  static const Color accentGreen = Color(0xFF34C759); // Success green
  static const Color accentBlue = Color(0xFF007AFF); // Tech blue
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color darkGrey = Color(0xFF1C1C1E); // Surface color
  static const Color mediumGrey = Color(0xFF2C2C2E); // Secondary surface

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.roboto(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: primaryWhite,
    letterSpacing: 1.5,
    height: 1.0,
  );

  static TextStyle get titleMedium => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryWhite,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyLarge => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: primaryWhite,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: const Color(0xFFE5E5E5), // Higher contrast than white70
  );

  static TextStyle get labelButton => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryWhite,
    letterSpacing: 1.0,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBlack,
      primaryColor: accentRed,
      colorScheme: const ColorScheme.dark(
        primary: accentRed,
        secondary: accentGreen,
        surface: primaryBlack,
        surfaceContainer: darkGrey,
        onPrimary: primaryWhite,
        onSecondary: primaryWhite,
        onSurface: primaryWhite,
        error: accentRed,
        onError: primaryWhite,
      ),
      textTheme: TextTheme(
        displayLarge: titleLarge,
        headlineMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: labelButton,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: primaryWhite,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ), // Boxy athletic feel
          textStyle: labelButton,
          elevation: 0,
        ),
      ),
    );
  }
}
