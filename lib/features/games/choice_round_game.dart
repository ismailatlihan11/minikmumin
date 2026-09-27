import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quran_learn/quran_learn_games.dart';
import '../quran_learn/quran_learn_widgets.dart';

class ChoiceQuestion {
  const ChoiceQuestion({
    required this.prompt,
    required this.options,
    required this.correct,
    this.arabicPrompt = '',
    this.arabicOptions = false,
  });

  final String prompt;
  final String arabicPrompt;
  final List<String> options;
  final String correct;
  final bool arabicOptions;
}

class ChoiceRoundPage extends StatefulWidget {
  const ChoiceRoundPage({
    super.key,
    required this.title,
    required this.load,
    this.accent,
  });

  final String title;
  final Future<List<ChoiceQuestion>> Function(BuildContext context) load;
  final Color? accent;

  @override
  State<ChoiceRoundPage> createState() => _ChoiceRoundPageState();
}

class _ChoiceRoundPageState extends State<ChoiceRoundPage> {
  Future<List<ChoiceQuestion>>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= widget.load(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(widget.title)),
      body: AsyncBody<List<ChoiceQuestion>>(
        future: _future!,
        errorMessage: 'Oyun yüklenemedi.',
        onRetry: () => setState(() => _future = widget.load(context)),
        builder: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Bu oyun için henüz içerik yok.'));
          }
          return _ChoicePlay(
            title: widget.title,
            questions: questions,
            accent: widget.accent ?? MinikColors.mint,
          );
        },
      ),
    );
  }
}

class _ChoicePlay extends StatefulWidget {
  const _ChoicePlay({
    required this.title,
    required this.questions,
    required this.accent,
  });

  final String title;
  final List<ChoiceQuestion> questions;
  final Color accent;

  @override
  State<_ChoicePlay> createState() => _ChoicePlayState();
}

class _ChoicePlayState extends State<_ChoicePlay> {
  int _index = 0;
  int _score = 0;
  String? _picked;
  bool _done = false;

  ChoiceQuestion get _q => widget.questions[_index];

  Future<void> _pick(String option) async {
    if (_done) return;
    setState(() => _picked = option);
    if (!qlSameAnswer(option, _q.correct)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir daha deneyelim.')),
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) setState(() => _picked = null);
      return;
    }
    _score += 1;
    if (_index + 1 >= widget.questions.length) {
      setState(() => _done = true);
      await context.read<LocalProgressStore>().addXp(6);
      if (!mounted) return;
      await showQlCelebration(
        context,
        title: 'Maşallah!',
        subtitle: '$_score / ${widget.questions.length} doğru.',
        continueLabel: 'Tamam',
      );
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _index += 1;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        LessonProgressBar(
          current: _done ? widget.questions.length : _index,
          total: widget.questions.length,
        ),
        const SizedBox(height: AppSpacing.md),
        MinikCard(
          color: widget.accent,
          child: Column(
            children: [
              Text(
                _q.prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_q.arabicPrompt.isNotEmpty) ...[
                const SizedBox(height: 10),
                QlBigArabic(_q.arabicPrompt, fontSize: 32),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final option in _q.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinikCard(
              color: _picked != null && qlSameAnswer(option, _q.correct)
                  ? MinikColors.mint
                  : _picked != null &&
                          qlSameAnswer(option, _picked!) &&
                          !qlSameAnswer(option, _q.correct)
                      ? MinikColors.blush
                      : Colors.white,
              onTap: _done ? null : () => _pick(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: _q.arabicOptions
                      ? QlBigArabic(option, fontSize: 28)
                      : Text(
                          option,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
          ),
        if (_done) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Tamam',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ],
    );
  }
}

List<String> pickOptions(String correct, List<String> pool, {int count = 3}) {
  final unique = <String>{};
  for (final item in pool) {
    final trimmed = item.trim();
    if (trimmed.isNotEmpty) unique.add(trimmed);
  }
  unique.remove(correct);
  final others = unique.toList()..shuffle(Random());
  final options = <String>[correct, ...others.take(count - 1)];
  options.shuffle(Random());
  return options;
}

List<T> pickRounds<T>(List<T> items, int n) {
  if (items.isEmpty) return const [];
  final copy = List<T>.from(items)..shuffle(Random());
  return copy.take(n.clamp(1, copy.length)).toList();
}
