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
    this.onTap,
  });

  final String text;
  final double fontSize;
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
        color: MinikColors.darkGreen,
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
        final playing = snapshot.data ?? false;
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
    default:
      return Icons.emoji_events_rounded;
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
