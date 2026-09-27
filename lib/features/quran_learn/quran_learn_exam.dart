import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnExamPage extends StatefulWidget {
  const QuranLearnExamPage({
    super.key,
    required this.pack,
    required this.levelId,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  State<QuranLearnExamPage> createState() => _QuranLearnExamPageState();
}

class _QuranLearnExamPageState extends State<QuranLearnExamPage> {
  int _index = 0;
  int _correct = 0;
  String? _picked;
  bool _locked = false;
  bool _finished = false;
  bool _started = false;
  int _last = 0;
  int _best = 0;

  QuranLearnExam? get exam => widget.pack.exam;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final store = context.read<LocalProgressStore>();
    final last = await store.getCounter(quranLearnExamLast);
    final best = await store.getCounter(quranLearnExamBest);
    if (!mounted) return;
    setState(() {
      _last = last;
      _best = best;
    });
  }

  void _start() {
    setState(() {
      _started = true;
      _finished = false;
      _index = 0;
      _correct = 0;
      _picked = null;
      _locked = false;
    });
  }

  void _pick(String option) {
    if (_locked || exam == null) return;
    final question = exam!.questions[_index];
    final right = qlSameAnswer(option, question.correctAnswer);
    setState(() {
      _picked = option;
      _locked = true;
      if (right) _correct += 1;
    });
  }

  Future<void> _next() async {
    final current = exam;
    if (current == null) return;
    if (_index + 1 < current.questions.length) {
      setState(() {
        _index += 1;
        _picked = null;
        _locked = false;
      });
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    final current = exam;
    if (current == null) return;
    final score = _correct * current.pointsCorrect;
    final percent = current.questions.isEmpty
        ? 0
        : ((_correct / current.questions.length) * 100).round();
    final passed = percent >= current.passPercent;
    final store = context.read<LocalProgressStore>();
    await store.setCounter(quranLearnExamLast, score);
    if (score > _best) {
      await store.setCounter(quranLearnExamBest, score);
      _best = score;
    }
    if (_correct > 0) {
      await store.addCounter(quranLearnCorrectAnswers, _correct);
    }
    if (passed) {
      await QuranLearnProgress.complete(
        store,
        pack: widget.pack,
        kind: 'ql_exam',
        id: current.id,
        xp: 12,
      );
    }
    if (!mounted) return;
    setState(() {
      _finished = true;
      _last = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = exam;
    return Scaffold(
      backgroundColor: MinikColors.background,
      appBar: AppBar(
        title: Text(
          widget.pack.titleForLevel(widget.levelId, fallback: 'Bitirme sınavı'),
        ),
      ),
      body: current == null
          ? const Center(child: Text('Sınav soruları henüz yüklenmedi.'))
          : ListView(
              padding: AppSpacing.page,
              children: [
                if (!_started || _finished)
                  _ExamIntro(
                    exam: current,
                    last: _last,
                    best: _best,
                    finished: _finished,
                    score: _last,
                    correct: _correct,
                    onStart: _start,
                  )
                else
                  _ExamQuestion(
                    exam: current,
                    index: _index,
                    picked: _picked,
                    locked: _locked,
                    onPick: _pick,
                    onNext: _next,
                  ),
              ],
            ),
    );
  }
}

class _ExamIntro extends StatelessWidget {
  const _ExamIntro({
    required this.exam,
    required this.last,
    required this.best,
    required this.finished,
    required this.score,
    required this.correct,
    required this.onStart,
  });

  final QuranLearnExam exam;
  final int last;
  final int best;
  final bool finished;
  final int score;
  final int correct;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final percent = exam.questions.isEmpty
        ? 0
        : ((correct / exam.questions.length) * 100).round();
    final passed = percent >= exam.passPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MinikCard(
          color: MinikColors.sky,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exam.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(exam.intro),
              const SizedBox(height: 8),
              Text(
                '${exam.questions.length} soru · doğru ${exam.pointsCorrect} puan · geçme %${exam.passPercent}',
              ),
              if (best > 0 || last > 0) ...[
                const SizedBox(height: 8),
                Text('Son puan: $last · En iyi: $best / ${exam.maxScore}'),
              ],
            ],
          ),
        ),
        if (finished) ...[
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: passed ? MinikColors.mint : MinikColors.peach,
            child: Column(
              children: [
                Text(
                  passed ? 'Geçtin!' : 'Bir daha deneyelim',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$correct / ${exam.questions.length} doğru · $score puan · %$percent',
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        QlPrimaryBar(
          label: finished ? 'Yeniden dene' : 'Sınava başla',
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _ExamQuestion extends StatelessWidget {
  const _ExamQuestion({
    required this.exam,
    required this.index,
    required this.picked,
    required this.locked,
    required this.onPick,
    required this.onNext,
  });

  final QuranLearnExam exam;
  final int index;
  final String? picked;
  final bool locked;
  final ValueChanged<String> onPick;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final question = exam.questions[index];
    final last = index + 1 >= exam.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonProgressBar(
          current: index + (locked ? 1 : 0),
          total: exam.questions.length,
        ),
        const SizedBox(height: AppSpacing.md),
        MinikCard(
          color: MinikColors.mint,
          child: Text(
            question.question,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinikCard(
              color: _color(option, question.correctAnswer),
              onTap: locked ? null : () => onPick(option),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w700,
                  color: MinikColors.darkGreen,
                ),
              ),
            ),
          ),
        if (locked) ...[
          const SizedBox(height: 8),
          Text(
            qlSameAnswer(picked ?? '', question.correctAnswer)
                ? question.feedbackCorrect
                : question.feedbackWrong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(
            label: last ? 'Sonucu gör' : 'Sonraki',
            onPressed: onNext,
          ),
        ],
      ],
    );
  }

  Color? _color(String option, String correct) {
    if (!locked) return null;
    if (qlSameAnswer(option, correct)) return MinikColors.mint;
    if (qlSameAnswer(option, picked ?? '')) return MinikColors.peach;
    return null;
  }
}
