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
  static const Color goldDeep = Color(0xFFA8863F);
  static const Color goldSoft = Color(0xFFD8C199);

  static const Color blush = Color(0xFFF3DAD6);
  static const Color blushDeep = Color(0xFFE8C4C0);
  static const Color rose = Color(0xFFC98B8B);

  static const Color espresso = Color(0xFF4A3F35);
  static const Color taupe = Color(0xFF6B5B4F);
  static const Color taupeLight = Color(0xFF9A8B7C);

  static const Color line = Color(0xFFE7DED1);

  /// A subtle radial sheen used behind hero / section content.
  static const List<Color> goldGradient = [goldSoft, champagne, goldDeep];

  static const List<Color> ivoryGradient = [
    Color(0xFFFFFDF9),
    Color(0xFFFAF7F2),
    Color(0xFFF3ECE1),
  ];
}
