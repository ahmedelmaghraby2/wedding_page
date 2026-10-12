import 'package:flutter/material.dart';

/// Central color palette for the premium wedding invitation.
///
/// Warm ivory, cream, beige, blush and champagne-gold tones with a deep
/// espresso for text to guarantee readable contrast.
class AppColors {
  AppColors._();

  static const Color ivory = Color(0xFFFAF7F2);
  static const Color cream = Color(0xFFFFFDF9);
  static const Color beige = Color(0xFFEDE4D8);

  static const Color champagne = Color(0xFFC6A96B);

  /// Accent gold used for headings, labels and buttons. Kept dark enough to
  /// meet WCAG AA (>= 4.5:1) as text on the ivory/cream surfaces and as a
  /// button background under white text. See `test/a11y_test.dart`.
  static const Color goldDeep = Color(0xFF8A6C2B);
  static const Color goldSoft = Color(0xFFD8C199);

  static const Color blush = Color(0xFFF3DAD6);
  static const Color blushDeep = Color(0xFFE8C4C0);

  /// Error/destructive accent; meets WCAG 1.4.11 (>= 3:1) as an icon on cream.
  static const Color rose = Color(0xFFBC7A7A);

  static const Color espresso = Color(0xFF4A3F35);
  static const Color taupe = Color(0xFF6B5B4F);

  /// Muted secondary text; kept at WCAG AA (>= 4.5:1) on ivory/cream.
  static const Color taupeLight = Color(0xFF7C6E60);

  static const Color line = Color(0xFFE7DED1);

  /// A subtle radial sheen used behind hero / section content.
  static const List<Color> goldGradient = [goldSoft, champagne, goldDeep];

  static const List<Color> ivoryGradient = [
    Color(0xFFFFFDF9),
    Color(0xFFFAF7F2),
    Color(0xFFF3ECE1),
  ];
}
