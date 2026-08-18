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

class QuranLearnWordsPage extends StatelessWidget {
  const QuranLearnWordsPage({super.key, required this.pack});

  final QuranLearningPack pack;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Kelimeleri Okuyalım')),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(4) ?? 0;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: pack.words.isEmpty ? 0 : done / pack.words.length,
                label: '$done / ${pack.words.length} kelime',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final word in pack.words)
                ContentTile(
                  title: word.reading,
                  subtitle: '${word.meaningTr} · ${word.quranReference}',
                  color: snap?.isDone('ql_word', word.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: SizedBox(
                    width: 52,
                    child: QlBigArabic(word.arabic, fontSize: 22),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuranLearnWordDetailPage(pack: pack, word: word),
                    ),
                  ),
                ),
              QlGamesStrip(
                games: pack.gamesForLevel(4),
                title: 'Okunuşu Seç',
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnWordDetailPage extends StatefulWidget {
  const QuranLearnWordDetailPage({
    super.key,
    required this.pack,
    required this.word,
  });

  final QuranLearningPack pack;
  final QuranWord word;

  @override
  State<QuranLearnWordDetailPage> createState() =>
      _QuranLearnWordDetailPageState();
}

class _QuranLearnWordDetailPageState extends State<QuranLearnWordDetailPage> {
  final _audio = AudioPlayerService();

  QuranWord get word => widget.word;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_word',
      id: word.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: 'Bu kelimeyi öğrendin.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(word.reading),
        actions: [
          FavoriteButton(
            kind: 'ql_word',
            id: word.id,
            title: '${word.reading} · ${word.arabic}',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.lavender,
            child: Column(
              children: [
                QlBigArabic(word.arabic, fontSize: 56),
                Text(word.reading, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('“${word.meaningTr}”'),
                const SizedBox(height: 6),
                SoftBadge(label: word.quranReference),
                if (word.teachingNote.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(word.teachingNote, textAlign: TextAlign.center),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: word.audio),
                const SizedBox(height: 8),
                QlColorButton(
                  arabic: word.arabic,
                  title: word.reading,
                  prompt: 'Bu kelimeyi boya.',
                  audio: word.audio,
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
