import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnTajweedPage extends StatelessWidget {
  const QuranLearnTajweedPage({super.key, required this.pack});

  final QuranLearningPack pack;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Temel Tecvid')),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(6) ?? 0;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: pack.tajweed.isEmpty ? 0 : done / pack.tajweed.length,
                label: '$done / ${pack.tajweed.length} ders',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final lesson in pack.tajweed)
                ContentTile(
                  title: lesson.title,
                  subtitle: lesson.shortDescription,
                  color: snap?.isDone('ql_tajweed', lesson.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: NumberBadge('${lesson.order}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnTajweedDetailPage(
                        pack: pack,
                        lesson: lesson,
                      ),
                    ),
                  ),
                ),
              QlGamesStrip(
                games: pack.gamesForLevel(6),
                title: 'Kuralı Bul',
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnTajweedDetailPage extends StatefulWidget {
  const QuranLearnTajweedDetailPage({
    super.key,
    required this.pack,
    required this.lesson,
  });

  final QuranLearningPack pack;
  final QuranTajweedLesson lesson;

  @override
  State<QuranLearnTajweedDetailPage> createState() =>
      _QuranLearnTajweedDetailPageState();
}

class _QuranLearnTajweedDetailPageState
    extends State<QuranLearnTajweedDetailPage> {
  final _audio = AudioPlayerService();

  QuranTajweedLesson get lesson => widget.lesson;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_tajweed',
      id: lesson.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${lesson.title} dersini tamamladın.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          FavoriteButton(
            kind: 'ql_tajweed',
            id: lesson.id,
            title: lesson.title,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.peach,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SoftBadge(label: 'Nedir?'),
                const SizedBox(height: 8),
                Text(lesson.shortDescription),
                const SizedBox(height: 12),
                const SoftBadge(label: 'Nasıl okunur?'),
                const SizedBox(height: 8),
                Text(lesson.explanation),
                if (lesson.qalqalaLetters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final letter in lesson.qalqalaLetters)
                        SoftBadge(label: letter, color: MinikColors.mint),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: lesson.audio),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Örnek'),
          for (final example in lesson.examples)
            MinikCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QlBigArabic(example.arabic, fontSize: 32),
                  const SizedBox(height: 6),
                  Text('Odak: ${example.focus}'),
                  Text(example.reference),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: QlColorButton(
                      arabic: example.arabic,
                      title: lesson.title,
                      prompt: 'Bu örneği boya.',
                      audio: lesson.audio,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}
