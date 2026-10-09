import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Locale-aware typography.
///
/// Latin uses an editorial serif (Cormorant Garamond) with a script accent
/// (Great Vibes) and a clean sans for UI (Jost). Arabic uses the calligraphic
/// Aref Ruqaa for display and Amiri for body text.
class AppTypography {
  AppTypography._();

  static const String latinDisplay = 'CormorantGaramond';
  static const String latinScript = 'GreatVibes';
  static const String latinSans = 'Jost';
  static const String arabicDisplay = 'ArefRuqaa';
  static const String arabicBody = 'Amiri';

  static bool isArabic(Locale locale) => locale.languageCode == 'ar';

  static TextTheme themeFor(Locale locale) =>
      isArabic(locale) ? arabicTextTheme : latinTextTheme;

  static TextStyle _latin(
    double size, {
    double weight = 400,
    double? letterSpacing,
    double height = 1.25,
    Color color = AppColors.espresso,
  }) {
    return TextStyle(
      fontFamily: latinDisplay,
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight)],
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _sans(
    double size, {
    double weight = 400,
    double? letterSpacing,
    double height = 1.7,
    Color color = AppColors.taupe,
  }) {
    return TextStyle(
      fontFamily: latinSans,
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight)],
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _arabic(
    double size, {
    String family = arabicBody,
    FontWeight weight = FontWeight.w400,
    double height = 1.7,
    Color color = AppColors.espresso,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  static final TextTheme latinTextTheme = TextTheme(
    displayLarge: _latin(64, weight: 500, letterSpacing: 2, height: 1.08),
    displayMedium: _latin(52, weight: 500, letterSpacing: 1.5, height: 1.12),
    displaySmall: _latin(42, weight: 500, letterSpacing: 1.2, height: 1.15),
    headlineLarge: _latin(40, weight: 400, letterSpacing: 1.5, height: 1.2),
    headlineMedium: _latin(32, weight: 400, letterSpacing: 1.2, height: 1.2),
    headlineSmall: _latin(26, weight: 500, letterSpacing: 1, height: 1.25),
    titleLarge: _latin(24, weight: 500, letterSpacing: 0.5, height: 1.3),
    titleMedium: _latin(20, weight: 500, letterSpacing: 0.3, height: 1.35),
    titleSmall: _latin(17, weight: 500, height: 1.35),
    bodyLarge: _sans(17),
    bodyMedium: _sans(15),
    bodySmall: _sans(13, height: 1.6, color: AppColors.taupeLight),
    labelLarge: _sans(
      13,
      weight: 500,
      letterSpacing: 4,
      height: 1.2,
      color: AppColors.goldDeep,
    ),
    labelMedium: _sans(
      12,
      weight: 500,
      letterSpacing: 2.5,
      height: 1.2,
      color: AppColors.goldDeep,
    ),
    labelSmall: _sans(
      11,
      weight: 500,
      letterSpacing: 2,
      height: 1.2,
      color: AppColors.taupeLight,
    ),
  );

  static final TextTheme arabicTextTheme = TextTheme(
    displayLarge: _arabic(
      58,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.25,
    ),
    displayMedium: _arabic(
      46,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.3,
    ),
    displaySmall: _arabic(
      38,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.3,
    ),
    headlineLarge: _arabic(
      36,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.35,
    ),
    headlineMedium: _arabic(
      30,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.35,
    ),
    headlineSmall: _arabic(
      25,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.4,
    ),
    titleLarge: _arabic(
      23,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.4,
    ),
    titleMedium: _arabic(
      19,
      family: arabicDisplay,
      weight: FontWeight.w400,
      height: 1.45,
    ),
    titleSmall: _arabic(17, weight: FontWeight.w700, height: 1.5),
    bodyLarge: _arabic(17),
    bodyMedium: _arabic(15),
    bodySmall: _arabic(13, height: 1.6, color: AppColors.taupeLight),
    labelLarge: _arabic(
      14,
      weight: FontWeight.w700,
      height: 1.4,
      color: AppColors.goldDeep,
    ),
    labelMedium: _arabic(
      13,
      weight: FontWeight.w700,
      height: 1.4,
      color: AppColors.goldDeep,
    ),
    labelSmall: _arabic(
      12,
      weight: FontWeight.w400,
      height: 1.4,
      color: AppColors.taupeLight,
    ),
  );
}
