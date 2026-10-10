import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  /// Legacy accessor kept for backwards compatibility.
  static ThemeData get elegantTheme => build(const Locale('en'));

  static ThemeData build(Locale locale) {
    final textTheme = AppTypography.themeFor(locale);
    final isArabic = AppTypography.isArabic(locale);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.champagne,
      primary: AppColors.goldDeep,
      onPrimary: Colors.white,
      secondary: AppColors.rose,
      onSecondary: Colors.white,
      surface: AppColors.cream,
      onSurface: AppColors.espresso,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      fontFamily: isArabic
          ? AppTypography.arabicBody
          : AppTypography.latinSans,
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.goldDeep),
      splashFactory: InkRipple.splashFactory,
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.goldDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
          textStyle: textTheme.labelMedium?.copyWith(
            color: Colors.white,
            letterSpacing: isArabic ? 0 : 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldDeep,
          textStyle: textTheme.labelMedium?.copyWith(
            color: AppColors.goldDeep,
            letterSpacing: isArabic ? 0 : 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldDeep,
          side: const BorderSide(color: AppColors.champagne),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.taupe),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.taupeLight),
        prefixIconColor: AppColors.champagne,
        suffixIconColor: AppColors.champagne,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.champagne, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.espresso,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.espresso,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
