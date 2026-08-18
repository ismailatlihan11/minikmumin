import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/home_catalog.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../shared/widgets/lesson_motion_image.dart';

class HomeRoundButton extends StatelessWidget {
  const HomeRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: MinikColors.darkGreen),
        ),
      ),
    );
  }
}

class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    super.key,
    required this.onMenu,
    required this.onSettings,
  });

  final VoidCallback onMenu;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/home/home_hero.png',
          fit: BoxFit.cover,
          alignment: const Alignment(0.35, 0.15),
        ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x00000000),
                ],
                stops: [0, 0.28, 1],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xCCEAF6FF),
                  Color(0x66EAF6FF),
                  Color(0x00EAF6FF),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, top + 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HomeRoundButton(icon: Icons.menu_rounded, onTap: onMenu),
                    const Expanded(
                      child: Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: AssetPaths.arabicFontFamily,
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(color: Color(0x66000000), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                    HomeRoundButton(
                      icon: Icons.settings_rounded,
                      onTap: onSettings,
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
              padding: EdgeInsets.fromLTRB(20, top + 52, 20, 0),
              child: Material(
                color: const Color(0xF2FFFFFF),
                elevation: 6,
                shadowColor: const Color(0x33000000),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 18,
                        color: Colors.pink.shade400,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E392F),
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
              border: Border.all(color: module.accent.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Row(
              children: [
                Image.asset(module.image, width: 64, height: 64, fit: BoxFit.contain),
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
                        style: const TextStyle(
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
                        style: const TextStyle(
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
                        semanticLabel: module.title,
                      )
                    : Image.asset(
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
                style: const TextStyle(
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
    return Material(
      color: const Color(0xFFE7F4EC),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF21684E).withValues(alpha: 0.28),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 96, child: _BasicsFeaturedArt()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
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
                      const Text(
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
                        style: const TextStyle(
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
                                    Colors.white.withValues(alpha: 0.8),
                                color: MinikColors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
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
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD8EFE4), Color(0xFFEAF6FF), Color(0xFFE7F4EC)],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: -6,
          child: Icon(
            Icons.mosque_rounded,
            size: 56,
            color: const Color(0xFF21684E).withValues(alpha: 0.10),
          ),
        ),
        const Positioned(
          left: 16,
          top: 12,
          child: Icon(Icons.nightlight_round, size: 18, color: Color(0xFFC29739)),
        ),
        Positioned(
          left: 40,
          top: 10,
          child: Icon(Icons.star_rounded, size: 11, color: const Color(0xFFE0A21A).withValues(alpha: 0.85)),
        ),
        Positioned(
          left: 28,
          top: 28,
          child: Icon(Icons.star_rounded, size: 8, color: const Color(0xFFE0A21A).withValues(alpha: 0.7)),
        ),
        Positioned(
          right: 88,
          top: 16,
          child: Icon(Icons.star_rounded, size: 10, color: const Color(0xFFE0A21A).withValues(alpha: 0.75)),
        ),
        Align(
          alignment: const Alignment(-0.55, 0.4),
          child: Image.asset(
            'assets/images/home/card_quran.png',
            height: 62,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: const Alignment(0.85, 0.5),
          child: Image.asset(
            'assets/images/prayer/prayer_intro_boy.png',
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/home/card_ilmihal.png',
              height: 58,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeAdventureCard extends StatelessWidget {
  const HomeAdventureCard({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünkü Maceram',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '🎯 1 görev tamamla\n📖 1 yeni şey öğren\n🎮 1 mini test çöz',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A6B5C),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: MinikColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: const Size(0, 40),
              textStyle: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }
}

class HomeContinueCard extends StatelessWidget {
  const HomeContinueCard({
    super.key,
    required this.subtitle,
    required this.progress,
    required this.onContinue,
    this.title = 'Öğrenmeye Devam Et',
  });

  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4E40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/home/continue_book.png', width: 42, height: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD5E8DC),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress.clamp(0, 1),
                    backgroundColor: const Color(0xFF326857),
                    color: const Color(0xFF7DDB6A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            child: FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3D8B6E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 44),
                tapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Devam Et'),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeQuranResumeBar extends StatelessWidget {
  const HomeQuranResumeBar({
    super.key,
    required this.subtitle,
    required this.onTap,
  });

  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD8F0E4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
          child: Row(
            children: [
              const Icon(Icons.bookmark_rounded, color: MinikColors.green, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Kaldığın yerden oku',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A6B5C),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_arrow_rounded, color: MinikColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeQuickCircle extends StatelessWidget {
  const HomeQuickCircle({super.key, required this.item, required this.onTap});

  final HomeQuickItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(item.image, width: 48, height: 48, fit: BoxFit.contain),
          const SizedBox(height: 5),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MinikColors.darkGreen,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFirstLaunchHint extends StatelessWidget {
  const HomeFirstLaunchHint({
    super.key,
    required this.visible,
    required this.title,
    required this.lines,
    required this.buttonLabel,
    required this.onDismiss,
  });

  final bool visible;
  final String title;
  final List<String> lines;
  final String buttonLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: Colors.white,
          elevation: 10,
          shadowColor: const Color(0x33000000),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E392F),
                  ),
                ),
                const SizedBox(height: 8),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MinikColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: MinikColors.green,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(buttonLabel),
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
