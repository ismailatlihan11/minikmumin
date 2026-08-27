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
              const SizedBox(height: 8),
              QlLessonIntro(
                title: pack.titleForLevel(levelId, fallback: 'Harekeler'),
                cue: 'Dersi aç, kareye dokun, dinleyerek öğren',
                rule: pack.levelById(levelId)?.description,
                note: 'Bütün dersler seslendirildi.',
              ),
              const SizedBox(height: 10),
              for (final item in items)
                ContentTile(
                  title: 'Ders ${item.order}: ${item.name} (${item.symbol})',
                  subtitle: quranLearnHarakatTeachLine(item),
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
    final teachLine = quranLearnHarakatTeachLine(haraka);
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
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
        children: [
          QlLessonIntro(
            title: 'Ders ${haraka.order}: ${haraka.name} (${haraka.symbol})',
            cue: 'Harfin üzerine tıkla / dinleyerek öğren',
            rule: teachLine,
            note: 'Kırmızı olanlar kalın harflerdir.',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: QlDashTile(
                  arabic: teachGlyph.isEmpty ? haraka.symbol : teachGlyph,
                  fontSize: 32,
                  onTap: QuranLearnAudio.resolve(teachAudio) == null
                      ? null
                      : () => QuranLearnAudio.play(
                            _audio,
                            context.read<LocalProgressStore>(),
                            teachAudio,
                          ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QlPlayListen(
                      audio: _audio,
                      path: teachAudio ?? haraka.audio,
                    ),
                    if (haraka.id == 'shadda') ...[
                      const SizedBox(height: 6),
                      Text(
                        quranLearnShaddaUnfold('ب'),
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          QlPracticeSection(
            audio: _audio,
            letters: widget.pack.letters,
            harakaId: haraka.id,
            examples: haraka.id == 'shadda' ? haraka.examples : const [],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: QlColorButton(
              arabic: teachGlyph.isEmpty ? haraka.symbol : teachGlyph,
              title: '${haraka.name} boya',
              prompt: '${haraka.name} işaretini boya.',
              audio: teachAudio ?? haraka.audio,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}
