import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/home_catalog.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

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
                          fontSize: 13,
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
    return Material(
      color: module.color,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  module.image,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              Text(
                module.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeMiniCard extends StatelessWidget {
  const HomeMiniCard({super.key, required this.item, required this.onTap});

  final HomeMiniAction item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(item.image, height: 18, fit: BoxFit.contain),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                  height: 1.1,
                ),
              ),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: MinikColors.textMuted,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4E40),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/home/continue_book.png', width: 34, height: 34),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD5E8DC),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: progress.clamp(0, 1),
                    backgroundColor: const Color(0xFF326857),
                    color: const Color(0xFF7DDB6A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          FittedBox(
            child: FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3D8B6E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 40),
                tapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Devam Et'),
            ),
          ),
        ],
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
          Image.asset(item.image, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 2),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 8,
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
