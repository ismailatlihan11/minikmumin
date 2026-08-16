import 'package:flutter/material.dart';

/// Minik Mümin palette. Existing adult-app colors stay in `lib/theme/app_theme.dart`.
abstract final class MinikColors {
  static const Color cream = Color(0xFFF7F3EA);
  static const Color creamDark = Color(0xFFEFE8D8);
  static const Color beige = Color(0xFFF3E6C8);
  static const Color green = Color(0xFF21684E);
  static const Color greenSoft = Color(0xFF3D8B6E);
  static const Color darkGreen = Color(0xFF1E392F);
  static const Color gold = Color(0xFFC29739);
  static const Color goldSoft = Color(0xFFD4B36A);
  static const Color pastelBlue = Color(0xFFD7E7E6);
  static const Color mint = Color(0xFFD8EFE4);
  static const Color peach = Color(0xFFF8E4D0);
  static const Color butter = Color(0xFFF7EBC4);
  static const Color blush = Color(0xFFF6DDE3);
  static const Color sky = Color(0xFFD5E8F6);
  static const Color lavender = Color(0xFFE6E0F4);
  static const Color teal = Color(0xFF267D7C);

  static const List<Color> pastels = [
    mint,
    peach,
    sky,
    butter,
    blush,
    lavender,
    pastelBlue,
  ];

  static Color pastelAt(int index) => pastels[index % pastels.length];
  static const Color text = Color(0xFF1E392F);
  static const Color textMuted = Color(0xFF5C6F66);
  static const Color surface = Color(0xFFFFFCF6);
  static const Color error = Color(0xFFB85C5C);
  static const Color success = Color(0xFF3D8B6E);
  static const Color night = Color(0xFF12241C);
  static const Color nightSurface = Color(0xFF1B3328);
}

/// Alias used by the master prompt naming (`AppColors` in the child design system).
typedef AppColors = MinikColors;
