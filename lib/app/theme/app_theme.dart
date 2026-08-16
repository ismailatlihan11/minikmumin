import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Child-app ThemeData. Existing adult screens keep using `lib/theme/app_theme.dart`.
abstract final class MinikTheme {
  static const String _font = 'NotoSans';

  static ThemeData light({double textScale = 1}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _font,
      scaffoldBackgroundColor: MinikColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MinikColors.green,
        primary: MinikColors.green,
        secondary: MinikColors.gold,
        surface: MinikColors.surface,
        error: MinikColors.error,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MinikColors.cream,
        foregroundColor: MinikColors.darkGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          color: MinikColors.darkGreen,
          fontSize: 18 * textScale,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: MinikColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MinikColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 52),
          textStyle: TextStyle(
            fontFamily: _font,
            fontSize: 16 * textScale,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MinikColors.green,
          minimumSize: const Size(44, 52),
          side: const BorderSide(color: MinikColors.green, width: 1.6),
          textStyle: TextStyle(
            fontFamily: _font,
            fontSize: 16 * textScale,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MinikColors.surface,
        hintStyle: const TextStyle(color: MinikColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: MinikColors.green, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 58,
        backgroundColor: MinikColors.surface,
        indicatorColor: MinikColors.mint,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _font,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? MinikColors.green : MinikColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? MinikColors.green : MinikColors.textMuted,
          );
        }),
      ),
      textTheme: _textTheme(textScale, Brightness.light),
    );
  }

  static ThemeData dark({double textScale = 1}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _font,
      scaffoldBackgroundColor: MinikColors.night,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MinikColors.green,
        primary: MinikColors.greenSoft,
        secondary: MinikColors.goldSoft,
        surface: MinikColors.nightSurface,
        error: MinikColors.error,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MinikColors.night,
        foregroundColor: MinikColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          color: MinikColors.cream,
          fontSize: 18 * textScale,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: MinikColors.nightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: MinikColors.nightSurface,
        indicatorColor: Color(0xFF2C4A3C),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: _textTheme(textScale, Brightness.dark),
    );
  }

  static TextTheme _textTheme(double scale, Brightness brightness) {
    final Color main =
        brightness == Brightness.dark ? MinikColors.cream : MinikColors.text;
    final Color muted = brightness == Brightness.dark
        ? const Color(0xFFB7CDBE)
        : MinikColors.textMuted;
    return TextTheme(
      displayMedium: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 28 * scale,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 20 * scale,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 16 * scale,
        height: 1.55,
      ),
      bodyMedium: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 14 * scale,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: _font,
        color: muted,
        fontSize: 12 * scale,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
