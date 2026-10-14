import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/quran_font.dart';
import '../../core/utils/quran_highlight.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.color,
    this.quran = false,
    this.sure = 0,
    this.ayah = 0,
  });

  final String text;
  final double fontSize;
  final Color? color;

  /// Kur'an ayetleri mushaf fontuyla (Abay) çizilir; Allah lafzı ve Rab
  /// kırmızıdır.
  final bool quran;

  /// Ayetin yeri; Rab'bin siyah kaldığı istisnalar için.
  final int sure;
  final int ayah;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final style = TextStyle(
      fontFamily: quran ? QuranFont.family : AssetPaths.arabicFontFamily,
      fontFamilyFallback: quran ? QuranFont.fallback : null,
      fontSize: quran ? fontSize + 4 : fontSize,
      height: 1.8,
      color: color ?? MinikColors.darkGreen,
    );
    if (!quran) {
      return SelectableText(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: style,
      );
    }
    return SelectableText.rich(
      TextSpan(
        children: quranHighlightSpans(QuranFont.format(text), kQuranRed,
            sure: sure, ayah: ayah),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: style,
    );
  }
}
