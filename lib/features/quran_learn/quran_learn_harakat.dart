import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnHarakatPage extends StatelessWidget {
  const QuranLearnHarakatPage({super.key, required this.pack});

  final QuranLearningPack pack;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Harekeleri Öğrenelim')),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(2) ?? 0;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: pack.harakat.isEmpty ? 0 : done / pack.harakat.length,
                label: '$done / ${pack.harakat.length} hareke',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in pack.harakat)
                ContentTile(
                  title: item.name,
                  subtitle: item.readingRule,
                  color: snap?.isDone('ql_haraka', item.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: NumberBadge('${item.order}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnHarakaDetailPage(
                        pack: pack,
                        haraka: item,
                      ),
                    ),
                  ),
                ),
              QlGamesStrip(
                games: pack.gamesForLevel(2),
                title: 'Sesini Bul',
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnHarakaDetailPage extends StatefulWidget {
  const QuranLearnHarakaDetailPage({
    super.key,
    required this.pack,
    required this.haraka,
  });

  final QuranLearningPack pack;
  final QuranHaraka haraka;

  @override
  State<QuranLearnHarakaDetailPage> createState() =>
      _QuranLearnHarakaDetailPageState();
}

class _QuranLearnHarakaDetailPageState extends State<QuranLearnHarakaDetailPage> {
  final _audio = AudioPlayerService();

  QuranHaraka get haraka => widget.haraka;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_haraka',
      id: haraka.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${haraka.name} dersini tamamladın.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(haraka.name),
        actions: [
          FavoriteButton(
            kind: 'ql_haraka',
            id: haraka.id,
            title: haraka.name,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.sky,
            child: Column(
              children: [
                QlBigArabic(
                  haraka.examples.isEmpty
                      ? haraka.symbol
                      : haraka.examples.first.arabic,
                  fontSize: 72,
                ),
                Text(haraka.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(haraka.readingRule, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: haraka.audio),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Örnekler'),
          for (final example in haraka.examples)
            MinikCard(
              child: Row(
                children: [
                  QlBigArabic(example.arabic, fontSize: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      example.reading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
          QlGamesStrip(games: widget.pack.gamesForLevel(2), title: 'Sesini Bul'),
        ],
      ),
    );
  }
}
