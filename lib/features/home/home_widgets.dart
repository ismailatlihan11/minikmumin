import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/home_catalog.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../shared/widgets/lesson_motion_image.dart';
import '../../shared/widgets/minik_image.dart';

class HomeRoundButton extends StatelessWidget {
  const HomeRoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: MinikColors.card,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: const Color(0x22000000),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 22, color: MinikColors.darkGreen),
          ),
        ),
      ),
    );
  }
}

class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    super.key,
    required this.onSettings,
    required this.onSearch,
  });

  final VoidCallback onSettings;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        // Mirror art so kids sit on the left, clear sky on the right.
        Transform.flip(
          flipX: true,
          child: MinikImage.asset(
            'assets/images/home/home_hero.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.2, 0.15),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x33000000),
                Color(0x00000000),
                Color(0x00000000),
              ],
              stops: [0, 0.22, 1],
            ),
          ),
        ),
        // Soft wash over the sky (now on the right) for Arabic contrast.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                MinikColors.of(
                    const Color(0xCCEAF6FF), const Color(0xCC152938)),
                MinikColors.of(
                    const Color(0x66EAF6FF), const Color(0x66152938)),
                MinikColors.of(
                    const Color(0x00EAF6FF), const Color(0x00152938)),
              ],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12, top + 4, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Arabic sits in the right sky, left of settings — clear of kids.
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 8),
                child: SizedBox(
                  width: 196,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: AssetPaths.arabicFontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B0B0B),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'الْحَمْدُ لِلَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: AssetPaths.arabicFontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B0B0B),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeRoundButton(
                    icon: Icons.settings_rounded,
                    tooltip: 'Ayarlar',
                    onTap: onSettings,
                  ),
                  const SizedBox(height: 8),
                  HomeRoundButton(
                    icon: Icons.search_rounded,
                    tooltip: 'Ara',
                    onTap: onSearch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({
    super.key,
    required this.visible,
    this.nickname,
  });

  final bool visible;
  final String? nickname;

  String get _text {
    final name = nickname?.trim();
    if (name == null || name.isEmpty) return 'Hoş geldin';
    return 'Hoş geldin, $name';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: visible ? Curves.easeOut : Curves.easeIn,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, -0.12),
          duration: const Duration(milliseconds: 420),
          curve: visible ? Curves.easeOutCubic : Curves.easeIn,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              // Sit in the mid band under the top chrome, clear of Arabic on the right.
              padding: EdgeInsets.fromLTRB(72, top + 78, 72, 0),
              child: Material(
                color: MinikColors.of(
                    const Color(0xF2FFFFFF), const Color(0xF2212121)),
                elevation: 6,
                shadowColor: const Color(0x33000000),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: Colors.pink.shade400,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: MinikColors.darkGreen,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeModuleCard extends StatelessWidget {
  const HomeModuleCard({super.key, required this.module, required this.onTap});

  final HomeModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${module.title}. ${module.subtitle}',
      excludeSemantics: true,
      child: _card(),
    );
  }

  Widget _card() {
    if (module.featured) {
      return Material(
        color: module.color,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: module.accent.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(
              children: [
                MinikImage.asset(module.image,
                    width: 64, height: 64, fit: BoxFit.contain),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        module.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MinikColors.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      color: module.color,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
          child: Column(
            children: [
              Expanded(
                child: module.idleMotion
                    ? LessonMotionImage(
                        image: module.image,
                        fit: BoxFit.contain,
                      )
                    : MinikImage.asset(
                        module.image,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                module.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                  height: 1.12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeBasicsFeaturedCard extends StatelessWidget {
  const HomeBasicsFeaturedCard({
    super.key,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  final int completed;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : completed / total;
    return Semantics(
      button: true,
      label: 'Temel Dini Bilgiler. $completed / $total konu tamamlandı',
      excludeSemantics: true,
      child: _card(value),
    );
  }

  Widget _card(double value) {
    return Material(
      color: MinikColors.of(const Color(0xFFE7F4EC), const Color(0xFF233128)),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 108),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: MinikColors.green.withValues(alpha: 0.28),
              width: 1.4,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: 96, child: _BasicsFeaturedArt()),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temel Dini Bilgiler',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: MinikColors.darkGreen,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'İslam\'ın temel bilgilerini birlikte öğrenelim.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: MinikColors.textMuted,
                            height: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$completed / $total konu tamamlandı',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: MinikColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  minHeight: 7,
                                  value: value.clamp(0, 1),
                                  backgroundColor:
                                      MinikColors.card.withValues(alpha: 0.8),
                                  color: MinikColors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Başla →',
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: MinikColors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BasicsFeaturedArt extends StatelessWidget {
  const _BasicsFeaturedArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MinikColors.mint,
                MinikColors.of(
                    const Color(0xFFEAF6FF), const Color(0xFF152938)),
                MinikColors.of(const Color(0xFFE7F4EC), const Color(0xFF233128))
              ],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: -6,
          child: Icon(
            Icons.mosque_rounded,
            size: 56,
            color: MinikColors.green.withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          left: 16,
          top: 12,
          child:
              Icon(Icons.nightlight_round, size: 18, color: MinikColors.gold),
        ),
        Positioned(
          left: 40,
          top: 10,
          child: Icon(Icons.star_rounded,
              size: 11, color: const Color(0xFFE0A21A).withValues(alpha: 0.85)),
        ),
        Positioned(
          left: 28,
          top: 28,
          child: Icon(Icons.star_rounded,
              size: 8, color: const Color(0xFFE0A21A).withValues(alpha: 0.7)),
        ),
        Positioned(
          right: 88,
          top: 16,
          child: Icon(Icons.star_rounded,
              size: 10, color: const Color(0xFFE0A21A).withValues(alpha: 0.75)),
        ),
        Align(
          alignment: const Alignment(-0.55, 0.4),
          child: MinikImage.asset(
            'assets/images/home/card_quran.jpg',
            height: 62,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: const Alignment(0.85, 0.5),
          child: MinikImage.asset(
            'assets/images/prayer/prayer_intro_boy.jpg',
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => MinikImage.asset(
              'assets/images/home/card_ilmihal.jpg',
              height: 58,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
