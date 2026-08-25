import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_combine.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';
import 'quran_learn_words.dart';

class QuranLearnSyllablesPage extends StatelessWidget {
  const QuranLearnSyllablesPage({
    super.key,
    required this.pack,
    required this.levelId,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final games = pack.gamesForLevel(levelId);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          pack.titleForLevel(levelId, fallback: 'Heceleme ve kelime okuma'),
        ),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          final total = pack.realLessonCount(levelId);
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total ders',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Text(
                  pack.levelById(levelId)?.description ??
                      'Harfleri birleştirip gerçek Kur’an kelimelerini okuyalım.',
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const SectionLabel('Heceleme'),
              for (final lesson in pack.combinations)
                ContentTile(
                  title: lesson.title,
                  subtitle: '${lesson.examples.length} örnek',
                  color: snap?.isDone('ql_comb', lesson.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: NumberBadge('${lesson.order}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnCombineDetailPage(
                        pack: pack,
                        lesson: lesson,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              const SectionLabel('Kelime okuma'),
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
              if (games.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                QlGamesStrip(games: games, title: 'Heceleme oyunları'),
              ],
            ],
          );
        },
      ),
    );
  }
}
