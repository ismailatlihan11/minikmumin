import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quran_learn/quran_learn_games.dart';
import '../quran_learn/quran_learn_widgets.dart';
import 'choice_round_game.dart';

class CombineWordGamePage extends StatefulWidget {
  const CombineWordGamePage({super.key});

  @override
  State<CombineWordGamePage> createState() => _CombineWordGamePageState();
}

class _CombineWordGamePageState extends State<CombineWordGamePage> {
  Future<QuranLearningPack>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= context.read<ContentRepositories>().quranLearning.load();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Kelimeyi Kur')),
      body: AsyncBody<QuranLearningPack>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(
          () => _future =
              context.read<ContentRepositories>().quranLearning.load(),
        ),
        builder: (pack) {
          final examples = [
            for (final lesson in pack.combinations)
              for (final example in lesson.examples)
                if (example.parts.length >= 2) example,
          ];
          if (examples.isEmpty) {
            return const Center(child: Text('Birleştirme örneği yok.'));
          }
          return _CombinePlay(examples: pickRounds(examples, 5));
        },
      ),
    );
  }
}

class _CombinePlay extends StatefulWidget {
  const _CombinePlay({required this.examples});

  final List<QuranCombinationExample> examples;

  @override
  State<_CombinePlay> createState() => _CombinePlayState();
}

class _CombinePlayState extends State<_CombinePlay> {
  int _index = 0;
  bool _won = false;
  int _score = 0;

  QuranCombinationExample get _example => widget.examples[_index];

  Future<void> _onCorrect() async {
    if (_won) return;
    setState(() {
      _won = true;
      _score += 1;
    });
    if (_index + 1 >= widget.examples.length) {
      await context.read<LocalProgressStore>().addXp(6);
      if (!mounted) return;
      await showQlCelebration(
        context,
        title: 'Harika!',
        subtitle: '$_score / ${widget.examples.length} doğru birleştirdin.',
        continueLabel: 'Tamam',
        onContinue: () => Navigator.pop(context),
      );
    }
  }

  void _next() {
    if (_index + 1 >= widget.examples.length) {
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
    return ListView(
      padding: AppSpacing.page,
      children: [
        LessonProgressBar(
          current: _index + (_won ? 1 : 0),
          total: widget.examples.length,
        ),
        const SizedBox(height: AppSpacing.md),
        MinikCard(
          color: MinikColors.lavender,
          child: Column(
            children: [
              const Text('Parçaları doğru sıraya koy.'),
              const SizedBox(height: 6),
              Text(
                _example.reading,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        QlCombineBoard(
          key: ValueKey('combine_$_index'),
          parts: _example.parts,
          target: _example.parts,
          result: _example.combined,
          won: _won,
          onCorrect: _onCorrect,
          onWrong: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bir daha deneyelim.')),
            );
          },
        ),
        if (_won) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: _index + 1 >= widget.examples.length ? 'Tamam' : 'Devam Et',
            onPressed: _next,
          ),
        ],
      ],
    );
  }
}
