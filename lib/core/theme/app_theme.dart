import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get elegantTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8B7355),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          letterSpacing: 4,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.5,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: 1,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.8,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.8,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: const Color(0xFF8B7355),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
