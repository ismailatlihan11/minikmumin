import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_combine.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';
import 'quran_learn_words.dart';

class QuranLearnSyllablesPage extends StatefulWidget {
  const QuranLearnSyllablesPage({
    super.key,
    required this.pack,
    required this.levelId,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  State<QuranLearnSyllablesPage> createState() => _QuranLearnSyllablesPageState();
}

class _QuranLearnSyllablesPageState extends State<QuranLearnSyllablesPage> {
  final _audio = AudioPlayerService();
  String? _selectedWordId;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final pack = widget.pack;
    final levelId = widget.levelId;
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
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total ders',
              ),
              const SizedBox(height: 8),
              QlLessonIntro(
                title: pack.titleForLevel(levelId, fallback: 'Heceleme'),
                cue: 'Kelimenin üzerine tıkla / dinleyerek öğren',
                rule: pack.levelById(levelId)?.description,
                hint: 'Uzun basınca anlamı görürsün.',
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
              Directionality(
                textDirection: TextDirection.ltr,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pack.words.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final word = pack.words[index];
                    return QlDashTile(
                      arabic: word.arabic,
                      learned: snap?.isDone('ql_word', word.id) ?? false,
                      selected: _selectedWordId == word.id,
                      fontSize: 22,
                      fillColor: index.isOdd
                          ? const Color(0xFFEAF4F8)
                          : Colors.white,
                      onTap: () {
                        setState(() => _selectedWordId = word.id);
                        QuranLearnAudio.play(_audio, store, word.audio);
                      },
                      onLongPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranLearnWordDetailPage(
                            pack: pack,
                            word: word,
                          ),
                        ),
                      ),
                    );
                  },
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
