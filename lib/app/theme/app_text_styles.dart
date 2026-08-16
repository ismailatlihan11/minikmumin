import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle display(double scale) => TextStyle(
        color: MinikColors.text,
        fontSize: 28 * scale,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle title(double scale) => TextStyle(
        color: MinikColors.darkGreen,
        fontSize: 20 * scale,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle body(double scale) => TextStyle(
        color: MinikColors.text,
        fontSize: 16 * scale,
        height: 1.55,
      );

  static TextStyle caption(double scale) => TextStyle(
        color: MinikColors.textMuted,
        fontSize: 13 * scale,
        height: 1.4,
      );

  static TextStyle arabic(double scale) => TextStyle(
        color: MinikColors.darkGreen,
        fontSize: 22 * scale,
        fontFamily: AssetPaths.arabicFontFamily,
        height: 1.8,
      );
}
