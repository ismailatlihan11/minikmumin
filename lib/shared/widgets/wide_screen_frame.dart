import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Tablette içeriği telefon düzenine yakın, ortalanmış bir sütunda gösterir.
class WideScreenFrame extends StatelessWidget {
  const WideScreenFrame({super.key, required this.child});

  static const maxContentWidth = 720.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= maxContentWidth) return child;

    return ColoredBox(
      color: Color.alphaBlend(const Color(0x0F000000), MinikColors.background),
      child: Center(
        child: Container(
          width: maxContentWidth,
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 24)],
          ),
          child: ClipRect(
            child: MediaQuery(
              data: media.copyWith(
                size: Size(maxContentWidth, media.size.height),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Sayfayı [WideScreenFrame] içine alır. Çerçeve geçişin içinde kaldığı için
/// sayfa tam ekran olur ve iOS'ta kenardan kaydırarak geri dönme ekranın
/// kenarından çalışır.
class WideScreenPageTransitionsBuilder extends PageTransitionsBuilder {
  const WideScreenPageTransitionsBuilder(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Duration get transitionDuration => inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => inner.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      inner.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      WideScreenFrame(child: child),
    );
  }
}

PageTransitionsTheme wideScreenPageTransitionsTheme() {
  const defaults = PageTransitionsTheme();
  return PageTransitionsTheme(
    builders: {
      for (final platform in TargetPlatform.values)
        platform: WideScreenPageTransitionsBuilder(
          defaults.builders[platform] ?? const ZoomPageTransitionsBuilder(),
        ),
    },
  );
}
