import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_games.dart';
import 'quran_learn_practice.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnHarakatPage extends StatelessWidget {
  const QuranLearnHarakatPage({
    super.key,
    required this.pack,
    this.levelId = 2,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final items = pack.harakatForLevel(levelId);
    final games = pack.gamesForLevel(levelId);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(pack.titleForLevel(levelId, fallback: 'Harekeler')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: items.isEmpty ? 0 : done / items.length,
                label: '$done / ${items.length} hareke',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.levelById(levelId)?.description ??
                          'Fetha, kesra, damme, uzatma, tenvin, cezm ve şedde.',
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w700,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('· Temel: işaret ve ses'),
                    const Text('· Uygulama: bütün harfler'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in items)
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
                        levelId: levelId,
                      ),
                    ),
                  ),
                ),
              if (games.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                QlGamesStrip(games: games, title: 'Hareke oyunları'),
              ],
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
    this.levelId,
  });

  final QuranLearningPack pack;
  final QuranHaraka haraka;
  final int? levelId;

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
      onContinue: () {
        final items = widget.levelId == null
            ? widget.pack.harakat
            : widget.pack.harakatForLevel(widget.levelId!);
        final index = items.indexWhere((item) => item.id == haraka.id);
        if (index >= 0 && index + 1 < items.length) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuranLearnHarakaDetailPage(
                pack: widget.pack,
                haraka: items[index + 1],
                levelId: widget.levelId,
              ),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachGlyph = quranLearnTeachingGlyph(haraka.id);
    final teachAudio = quranLearnTeachingAudio(widget.pack.letters, haraka.id);
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
          const SectionLabel('Temel'),
          MinikCard(
            color: MinikColors.sky,
            child: Column(
              children: [
                QlBigArabic(
                  teachGlyph.isEmpty ? haraka.symbol : teachGlyph,
                  fontSize: 72,
                  onTap: QuranLearnAudio.resolve(teachAudio) == null
                      ? null
                      : () => QuranLearnAudio.play(
                            _audio,
                            context.read<LocalProgressStore>(),
                            teachAudio,
                          ),
                ),
                Text(haraka.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(haraka.readingRule, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: teachAudio ?? haraka.audio),
                const SizedBox(height: 8),
                QlColorButton(
                  arabic: teachGlyph.isEmpty ? haraka.symbol : teachGlyph,
                  title: '${haraka.name} boya',
                  prompt: '${haraka.name} işaretini boya.',
                  audio: teachAudio ?? haraka.audio,
                ),
              ],
            ),
          ),
          if (haraka.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Temel örnekler'),
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
                    QlListenIcon(
                      audio: _audio,
                      path: example.audio ?? haraka.audio,
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          QlPracticeSection(
            audio: _audio,
            letters: widget.pack.letters,
            harakaId: haraka.id,
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}
