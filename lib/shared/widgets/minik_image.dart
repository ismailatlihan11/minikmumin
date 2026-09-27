import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// [Image.asset] that is dimmed a little in dark mode, so bright artwork and
/// white illustration backgrounds do not glare on dark surfaces.
abstract final class MinikImage {
  static const Color _darkDim = Color(0xFFD6D6D6);

  static ColorFilter? get decorationFilter => MinikColors.isDark
      ? const ColorFilter.mode(_darkDim, BlendMode.modulate)
      : null;

  static Image asset(
    String name, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageErrorWidgetBuilder? errorBuilder,
    ImageFrameBuilder? frameBuilder,
    Color? color,
    BlendMode? colorBlendMode,
    Animation<double>? opacity,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    FilterQuality filterQuality = FilterQuality.medium,
    bool gaplessPlayback = false,
    int? cacheWidth,
    int? cacheHeight,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
  }) {
    final dim = MinikColors.isDark && color == null;
    return Image.asset(
      name,
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: errorBuilder,
      frameBuilder: frameBuilder,
      color: dim ? _darkDim : color,
      colorBlendMode: dim ? BlendMode.modulate : colorBlendMode,
      opacity: opacity,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      filterQuality: filterQuality,
      gaplessPlayback: gaplessPlayback,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
    );
  }
}
