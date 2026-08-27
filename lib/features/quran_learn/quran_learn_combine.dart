import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_games.dart';
import 'quran_learn_practice.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnCombinePage extends StatefulWidget {
  const QuranLearnCombinePage({
    super.key,
    required this.pack,
    this.levelId = 3,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  State<QuranLearnCombinePage> createState() => _QuranLearnCombinePageState();
}

class _QuranLearnCombinePageState extends State<QuranLearnCombinePage> {
  final _audio = AudioPlayerService();

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          pack.titleForLevel(levelId, fallback: 'Cezm (Harflerin Birleştirilmesi)'),
        ),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          final sukun = pack.harakaById('sukun');
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            children: [
              QlSoftProgress(
                value: pack.combinations.isEmpty
                    ? 0
                    : done / pack.combinations.length,
                label: '$done / ${pack.combinations.length} ders',
              ),
              const SizedBox(height: 8),
              QlLessonIntro(
                title: 'Ders: Cezm (${sukun?.symbol ?? 'ْ'})',
                cue: 'Kareye dokun, dinleyerek öğren',
                rule: sukun?.readingRule ??
                    pack.levelById(levelId)?.description,
              ),
              const SizedBox(height: 10),
              QlSukunTripletGrid(audio: _audio, letters: pack.letters),
              const SizedBox(height: AppSpacing.md),
              const SectionLabel('Birleştirme'),
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
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnCombineDetailPage extends StatefulWidget {
  const QuranLearnCombineDetailPage({
    super.key,
    required this.pack,
    required this.lesson,
  });

  final QuranLearningPack pack;
  final QuranCombination lesson;

  @override
  State<QuranLearnCombineDetailPage> createState() =>
      _QuranLearnCombineDetailPageState();
}

class _QuranLearnCombineDetailPageState extends State<QuranLearnCombineDetailPage> {
  final _audio = AudioPlayerService();
  int _index = 0;
  bool _won = false;

  QuranCombinationExample get example => widget.lesson.examples[_index];

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _onCorrect() async {
    setState(() => _won = true);
    final store = context.read<LocalProgressStore>();
    await store.addCounter(quranLearnCombinations);
    await store.addCounter(quranLearnCorrectAnswers);
    if (_index >= widget.lesson.examples.length - 1) {
      await QuranLearnProgress.complete(
        store,
        pack: widget.pack,
        kind: 'ql_comb',
        id: widget.lesson.id,
      );
      if (!mounted) return;
      await showQlCelebration(
        context,
        title: 'Harika!',
        subtitle: 'Harfleri doğru birleştirdin.',
        onContinue: () => Navigator.pop(context),
      );
    }
  }

  void _onWrong() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bir daha deneyelim.')),
    );
  }

  void _next() {
    if (_index + 1 >= widget.lesson.examples.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _won = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          LessonProgressBar(
            current: _index + (_won ? 1 : 0),
            total: widget.lesson.examples.length,
          ),
          const SizedBox(height: 8),
          QlLessonIntro(
            title: widget.lesson.title,
            cue: 'Kareye dokun, dinle; sonra harfleri sıraya koy',
            rule: example.note,
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.lesson.examples.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final item = widget.lesson.examples[index];
                return QlDashTile(
                  arabic: item.combined,
                  caption: item.reading,
                  selected: index == _index,
                  fontSize: 20,
                  fillColor: index.isOdd
                      ? const Color(0xFFF7EBC4)
                      : Colors.white,
                  onTap: () {
                    setState(() {
                      _index = index;
                      _won = false;
                    });
                    QuranLearnAudio.play(
                      _audio,
                      context.read<LocalProgressStore>(),
                      item.audio,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            child: Column(
              children: [
                const Text('Harfleri cezm ile doğru sıraya koy.'),
                const SizedBox(height: 8),
                Text(
                  example.reading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (example.note != null && example.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(example.note!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: example.audio),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          QlCombineBoard(
            key: ValueKey('${widget.lesson.id}_$_index'),
            parts: example.parts,
            target: example.parts,
            result: example.combined,
            won: _won,
            onCorrect: _onCorrect,
            onWrong: _onWrong,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: QlColorButton(
              arabic: example.combined,
              title: widget.lesson.title,
              prompt: 'Bu birleşimi boya.',
              audio: example.audio,
            ),
          ),
          if (_won) ...[
            const SizedBox(height: AppSpacing.lg),
            QlPrimaryBar(
              label: _index + 1 >= widget.lesson.examples.length
                  ? 'Tamam'
                  : 'Devam Et',
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }
}
