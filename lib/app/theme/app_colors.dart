import 'package:flutter/material.dart';

/// Minik Mümin palette. Values follow the app's light/dark choice, so they are
/// getters and cannot be used in `const` expressions.
abstract final class MinikColors {
  static bool _dark = false;

  static bool get isDark => _dark;

  /// Only [ThemeController] should call this; it also rebuilds the tree.
  static void applyDark(bool dark) => _dark = dark;

  static Color _pick(int light, int dark) => Color(_dark ? dark : light);

  // Page and card surfaces.
  static Color get background => _pick(0xFFF4F7F2, 0xFF121B17);
  static Color get cream => _pick(0xFFF7F3EA, 0xFF141E19);
  static Color get creamDark => _pick(0xFFEFE8D8, 0xFF26332D);
  static Color get beige => _pick(0xFFF3E6C8, 0xFF3A3224);
  static Color get surface => _pick(0xFFFFFCF6, 0xFF1C2823);

  /// Pure white cards in light mode.
  static Color get card => _pick(0xFFFFFFFF, 0xFF1C2823);
  static Color get border => _pick(0xFFE0EAE4, 0xFF2E3D36);

  // Brand.
  static Color get green => _pick(0xFF21684E, 0xFF3D9A74);
  static Color get greenSoft => _pick(0xFF3D8B6E, 0xFF5DB08E);
  static Color get darkGreen => _pick(0xFF1E392F, 0xFFE4EFE8);
  static Color get gold => _pick(0xFFC29739, 0xFFD6AC4E);
  static Color get goldSoft => _pick(0xFFD4B36A, 0xFFDDBE78);
  static Color get teal => _pick(0xFF267D7C, 0xFF3AA3A2);

  // Pastel card tints.
  static Color get pastelBlue => _pick(0xFFD7E7E6, 0xFF1F3533);
  static Color get mint => _pick(0xFFD8EFE4, 0xFF1E3A2E);
  static Color get peach => _pick(0xFFF8E4D0, 0xFF3B2A20);
  static Color get butter => _pick(0xFFF7EBC4, 0xFF383020);
  static Color get blush => _pick(0xFFF6DDE3, 0xFF3A2329);
  static Color get sky => _pick(0xFFD5E8F6, 0xFF1C3040);
  static Color get lavender => _pick(0xFFE6E0F4, 0xFF2A2640);

  static List<Color> get pastels => [
        mint,
        peach,
        sky,
        butter,
        blush,
        lavender,
        pastelBlue,
      ];

  static Color pastelAt(int index) => pastels[index % pastels.length];

  // Text.
  static Color get text => _pick(0xFF1E392F, 0xFFECE8DE);
  static Color get textMuted => _pick(0xFF5C6F66, 0xFFA7B8AF);

  /// Text/icons placed on a [green] or other saturated fill.
  static const Color onAccent = Colors.white;

  static Color get error => _pick(0xFFB85C5C, 0xFFE08585);
  static Color get success => greenSoft;
  static Color get shadow => _pick(0x22000000, 0x66000000);

  static const Color night = Color(0xFF12241C);
  static const Color nightSurface = Color(0xFF1B3328);

  /// Picks between two literal colors for spots that are not palette-based.
  static Color of(Color light, Color dark) => _dark ? dark : light;
}

/// Alias used by the master prompt naming (`AppColors` in the child design system).
typedef AppColors = MinikColors;
