import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure 'google_fonts' is added to pubspec.yaml under dependencies

class YogAITheme {
  static const Color primaryOrange = Color(0xFFFFB74D);
  static const Color lightYellow = Color(0xFFFFF9E6);
  static const Color lightOrange = Color(0xFFFFF2E6);
  static const Color darkText = Color(0xFF2D2D2D);

  // Onboarding Gradient as BoxDecoration (use with Container in flexibleSpace or body)
  static final BoxDecoration onboardingGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lightYellow, lightOrange, Colors.white],
      stops: const [0.0, 0.45, 1.0],
    ),
  );

  // === Text Theme using Poppins ===
  static final TextTheme poppinsTextTheme = TextTheme(
    headlineLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: Color(0xFF2D2D2D),
      height: 1.2,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.grey[700],
    ),
    labelLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF2D2D2D),
    ),
  );

  // === Progress Indicator Color ===
  static const Color progressColor = Color(0xFFFFB74D); // Warm orange
  static const Color progressBackground = Color(0x33FFFFFF);

  static const Color nextButtonColor = Color(0xFFFFB74D);
  static const Color nextButtonDisabled = Color(0xFFBDBDBD);

  // === Light Theme ===
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',

    colorScheme: ColorScheme.light(
      primary: primaryOrange,
      secondary: primaryOrange,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSurface: darkText,
      onBackground: darkText,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryOrange,
      linearTrackColor: Color(0x33FFFFFF),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        disabledBackgroundColor: const Color(0xFFBDBDBD),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // Optional: Dark theme variant (highly recommended now)
  static final ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryOrange,
      secondary: primaryOrange,
      surface: const Color(0xFF121212),
    ),
  );
}
