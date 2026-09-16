import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_theme.dart';
import '../../core/audio/audio_player_service.dart';
import '../../shared/widgets/buttons.dart';
import 'elifba_audio.dart';

const elifbaMascotAsset = 'assets/images/elifba/characters/elif.png';

class ElifbaMascot extends StatelessWidget {
  const ElifbaMascot({
    super.key,
    required this.line,
    this.size = 72,
  });

  final String line;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Elif: $line',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              elifbaMascotAsset,
              width: size,
              height: size,
              fit: BoxFit.cover,
              semanticLabel: 'Elif maskotu',
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MinikColors.peach,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('🐰', style: TextStyle(fontSize: 32)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: MinikColors.mint),
              ),
              child: Text(
                line,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElifbaListenButton extends StatelessWidget {
  const ElifbaListenButton({
    super.key,
    required this.audio,
    required this.path,
    this.label = 'Dinle',
  });

  final AudioPlayerService audio;
  final String? path;
  final String label;

  @override
  Widget build(BuildContext context) {
    final playable = ElifbaAudio.resolve(path);
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: playable == null
            ? null
            : () => ElifbaAudio.play(audio, playable),
        style: FilledButton.styleFrom(
          backgroundColor: MinikColors.greenSoft,
          disabledBackgroundColor: MinikColors.creamDark,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.volume_up_rounded),
        label: Text(playable == null ? 'Ses yakında' : label),
      ),
    );
  }
}

class ElifbaArabicTap extends StatelessWidget {
  const ElifbaArabicTap({
    super.key,
    required this.text,
    this.fontSize = 64,
    this.onTap,
    this.color,
  });

  final String text;
  final double fontSize;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final child = Text(
      text,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: AssetPaths.arabicFontFamily,
        fontSize: fontSize,
        height: 1.2,
        color: color ?? MinikColors.darkGreen,
      ),
    );
    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: text,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: reduce
            ? child
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                builder: (context, value, inner) =>
                    Transform.scale(scale: value, child: inner),
                child: child,
              ),
      ),
    );
  }
}

class ElifbaStarsRow extends StatelessWidget {
  const ElifbaStarsRow({super.key, required this.count, this.total = 3});

  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              i < count ? Icons.star_rounded : Icons.star_outline_rounded,
              color: MinikColors.gold,
              size: 36,
            ),
          ),
      ],
    );
  }
}

class ElifbaSoftCard extends StatelessWidget {
  const ElifbaSoftCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: MinikTheme.lightSurfaces(
        DefaultTextStyle.merge(
          style: const TextStyle(color: MinikColors.text),
          child: child,
        ),
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: body,
      ),
    );
  }
}

class ElifbaPrimary extends StatelessWidget {
  const ElifbaPrimary({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(label: label, onPressed: onPressed);
  }
}
