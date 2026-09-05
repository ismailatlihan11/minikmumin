import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(this.text, {super.key, this.fontSize = 22, this.color});

  final String text;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return SelectableText(
      text,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: AssetPaths.arabicFontFamily,
        fontSize: fontSize,
        height: 1.8,
        color: color ?? MinikColors.darkGreen,
      ),
    );
  }
}
