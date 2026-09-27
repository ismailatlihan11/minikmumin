import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Child-app ThemeData built from the current [MinikColors] palette, so it
/// follows the light/dark choice in Settings.
abstract final class MinikTheme {
  static const String _font = 'NotoSans';

  static ThemeData current({double textScale = 1}) {
    final dark = MinikColors.isDark;
    final brightness = dark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _font,
      scaffoldBackgroundColor: MinikColors.cream,
      canvasColor: MinikColors.cream,
      dividerColor: MinikColors.border,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MinikColors.green,
        primary: MinikColors.green,
        onPrimary: MinikColors.onAccent,
        secondary: MinikColors.gold,
        surface: MinikColors.surface,
        onSurface: MinikColors.text,
        onSurfaceVariant: MinikColors.textMuted,
        error: MinikColors.error,
        brightness: brightness,
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
      dialogTheme: DialogThemeData(backgroundColor: MinikColors.surface),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: MinikColors.surface,
        modalBackgroundColor: MinikColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? MinikColors.creamDark : null,
        contentTextStyle: dark
            ? TextStyle(fontFamily: _font, color: MinikColors.text)
            : null,
      ),
      iconTheme: IconThemeData(color: MinikColors.darkGreen),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MinikColors.green,
          foregroundColor: MinikColors.onAccent,
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
          side: BorderSide(color: MinikColors.green, width: 1.6),
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: MinikColors.green),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MinikColors.surface,
        hintStyle: TextStyle(color: MinikColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: dark
              ? BorderSide(color: MinikColors.border)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: MinikColors.green, width: 1.4),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: MinikColors.darkGreen,
        textColor: MinikColors.text,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? MinikColors.onAccent
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? MinikColors.green : null,
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
      textTheme: _textTheme(textScale),
    );
  }

  /// Re-applies the app theme below widgets that override it locally.
  static Widget themed(Widget child) {
    return Theme(
      data: current(),
      child: child,
    );
  }

  static MaterialPageRoute<T> route<T extends Object?>(Widget page) {
    return MaterialPageRoute<T>(
      builder: (_) => themed(page),
    );
  }

  static TextTheme _textTheme(double scale) {
    final main = MinikColors.text;
    final muted = MinikColors.textMuted;
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
      titleLarge: TextStyle(fontFamily: _font, color: main),
      titleMedium: TextStyle(
        fontFamily: _font,
        color: main,
        fontSize: 16 * scale,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(fontFamily: _font, color: main),
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
      labelLarge: TextStyle(fontFamily: _font, color: main),
    );
  }
}
