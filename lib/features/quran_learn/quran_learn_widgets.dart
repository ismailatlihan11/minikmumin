import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../shared/widgets/buttons.dart';
import 'quran_learn_audio.dart';

class QlBigArabic extends StatelessWidget {
  const QlBigArabic(
    this.text, {
    super.key,
    this.fontSize = 72,
    this.color,
    this.onTap,
  });

  final String text;
  final double fontSize;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}

class QlPlayListen extends StatelessWidget {
  const QlPlayListen({
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
    final playable = QuranLearnAudio.resolve(path);
    if (playable == null) return const SizedBox.shrink();
    return StreamBuilder<bool>(
      stream: audio.playingStream,
      initialData: audio.isPlaying,
      builder: (context, snapshot) {
        final playing =
            (snapshot.data ?? false) && audio.currentAsset == playable;
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () async {
              final store = context.read<LocalProgressStore>();
              if (playing) {
                await audio.stop();
                return;
              }
              await QuranLearnAudio.play(audio, store, playable);
            },
            style: FilledButton.styleFrom(
              backgroundColor: MinikColors.greenSoft,
              foregroundColor: Colors.white,
            ),
            icon: Icon(playing ? Icons.stop_rounded : Icons.volume_up_rounded),
            label: Text(playing ? 'Durdur' : label),
          ),
        );
      },
    );
  }
}

class QlListenIcon extends StatelessWidget {
  const QlListenIcon({
    super.key,
    required this.audio,
    required this.path,
  });

  final AudioPlayerService audio;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final playable = QuranLearnAudio.resolve(path);
    if (playable == null) return const SizedBox.shrink();
    return IconButton(
      tooltip: 'Dinle',
      onPressed: () {
        QuranLearnAudio.play(
          audio,
          context.read<LocalProgressStore>(),
          playable,
        );
      },
      icon: const Icon(Icons.volume_up_rounded, color: MinikColors.green),
    );
  }
}

class QlSoftProgress extends StatelessWidget {
  const QlSoftProgress({
    super.key,
    required this.value,
    required this.label,
  });

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: MinikColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value.clamp(0, 1),
            backgroundColor: Colors.white.withValues(alpha: 0.75),
            color: MinikColors.green,
          ),
        ),
      ],
    );
  }
}

class QlFormChip extends StatelessWidget {
  const QlFormChip({
    required this.label,
    required this.arabic,
    this.onTap,
    super.key,
  });

  final String label;
  final String arabic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: MinikColors.mint.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          QlBigArabic(arabic, fontSize: 28),
          if (onTap != null) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.palette_outlined,
              size: 14,
              color: MinikColors.green,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return Expanded(child: body);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: body,
        ),
      ),
    );
  }
}

Future<void> showQlCelebration(
  BuildContext context, {
  required String title,
  String subtitle = 'Bu dersi tamamladın.',
  VoidCallback? onContinue,
  VoidCallback? onRetry,
  String continueLabel = 'Devam Et',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: const Text('⭐', style: TextStyle(fontSize: 42)),
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onRetry();
              },
              child: const Text('Tekrar Et'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onContinue?.call();
            },
            child: Text(continueLabel),
          ),
        ],
      );
    },
  );
}

IconData qlLevelIcon(int id, [String screen = '']) {
  switch (screen) {
    case 'letters':
      return Icons.abc_rounded;
    case 'letter_forms':
      return Icons.grid_view_rounded;
    case 'letter_review':
      return Icons.playlist_play_rounded;
    case 'harakat':
      return Icons.edit_rounded;
    case 'mahraj':
      return Icons.record_voice_over_rounded;
    case 'heavy_light':
      return Icons.tonality_rounded;
    case 'tajweed':
      return Icons.music_note_rounded;
    case 'syllables':
      return Icons.extension_rounded;
    case 'games':
      return Icons.sports_esports_rounded;
    case 'surahs':
      return Icons.menu_book_rounded;
    case 'tajweed_read':
      return Icons.auto_stories_rounded;
    case 'exam':
      return Icons.emoji_events_rounded;
  }
  switch (id) {
    case 1:
      return Icons.abc_rounded;
    case 2:
      return Icons.edit_rounded;
    case 3:
      return Icons.extension_rounded;
    case 4:
      return Icons.menu_book_rounded;
    case 5:
      return Icons.nights_stay_rounded;
    case 6:
      return Icons.music_note_rounded;
    case 7:
      return Icons.auto_stories_rounded;
    case 9:
      return Icons.grid_view_rounded;
    case 10:
      return Icons.playlist_play_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}

/// Elifba-style square tile: white, dashed border, tap to listen.
class QlDashTile extends StatelessWidget {
  const QlDashTile({
    super.key,
    required this.arabic,
    this.caption,
    this.heavy = false,
    this.learned = false,
    this.selected = false,
    this.fillColor,
    this.fontSize = 28,
    this.onTap,
    this.onLongPress,
  });

  final String arabic;
  final String? caption;
  final bool heavy;
  final bool learned;
  final bool selected;
  final Color? fillColor;
  final double fontSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static const Color heavyLetter = Color(0xFFC62828);
  static const Color selectedBorder = Color(0xFFD46A3A);

  @override
  Widget build(BuildContext context) {
    final fill = learned
        ? MinikColors.mint.withValues(alpha: 0.7)
        : (fillColor ?? Colors.white);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: QlDashedBorderPainter(
            color: selected ? selectedBorder : const Color(0xFFB7C0BB),
            strokeWidth: selected ? 2.2 : 1.3,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: caption == null
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: QlBigArabic(
                        arabic,
                        fontSize: fontSize,
                        color: heavy ? heavyLetter : MinikColors.darkGreen,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: QlBigArabic(
                              arabic,
                              fontSize: fontSize,
                              color: heavy ? heavyLetter : MinikColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 8, thickness: 0.8),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          caption!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: MinikColors.darkGreen,
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

class QlDashedBorderPainter extends CustomPainter {
  const QlDashedBorderPainter({
    this.color = const Color(0xFFB7C0BB),
    this.radius = 10,
    this.strokeWidth = 1.3,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(QlDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class QlLessonIntro extends StatelessWidget {
  const QlLessonIntro({
    super.key,
    required this.title,
    required this.cue,
    this.rule,
    this.note,
    this.hint,
  });

  final String title;
  final String cue;
  final String? rule;
  final String? note;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
              height: 1.25,
            ),
          ),
          if (rule != null && rule!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              rule!,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: MinikColors.text,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            cue,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: MinikColors.green,
              height: 1.3,
            ),
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MinikColors.textMuted,
              ),
            ),
          ],
          if (hint != null && hint!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 11,
                color: MinikColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class QlPrimaryBar extends StatelessWidget {
  const QlPrimaryBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      onPressed: enabled ? onPressed : null,
    );
  }
}
