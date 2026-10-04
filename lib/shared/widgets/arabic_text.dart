import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/quran_font.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.color,
    this.quran = false,
  });

  final String text;
  final double fontSize;
  final Color? color;

  /// Kur'an ayetleri Diyanet'in Hamdullah mushaf fontuyla çizilir.
  final bool quran;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return SelectableText(
      quran ? QuranFont.encode(text) : text,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: quran ? QuranFont.family : AssetPaths.arabicFontFamily,
        fontFamilyFallback: quran ? QuranFont.fallback : null,
        fontSize: quran ? fontSize + 4 : fontSize,
        height: 1.8,
        color: color ?? MinikColors.darkGreen,
      ),
    );
  }
}
