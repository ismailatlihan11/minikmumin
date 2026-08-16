import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<List<QuizQuestion>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.quiz.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Testler')),
      body: AsyncBody<List<QuizQuestion>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.quiz.getAll()),
        builder: (items) => QuizPlayView(questions: items),
      ),
    );
  }
}

class QuizPlayView extends StatefulWidget {
  const QuizPlayView({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<QuizPlayView> createState() => _QuizPlayViewState();
}

class _QuizPlayViewState extends State<QuizPlayView> {
  int _index = 0;
  int _score = 0;
  String? _selectedId;
  final AudioPlayerService _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.questions.length) {
      return ListView(
        padding: AppSpacing.page,
        children: [
          Image.asset(
            'assets/images/home/success.png',
            height: 120,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Maşallah!', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.mint,
            child: Text('${widget.questions.length} sorudan $_score tanesini bildin.'),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Tekrar Dene',
            onPressed: () => setState(() {
              _index = 0;
              _score = 0;
              _selectedId = null;
            }),
          ),
        ],
      );
    }

    final question = widget.questions[_index];
    return ListView(
      padding: AppSpacing.page,
      children: [
        LessonProgressBar(current: _index + 1, total: widget.questions.length),
        const SizedBox(height: AppSpacing.md),
        MinikCard(
          color: MinikColors.butter,
          child: Text(question.question, style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        ...question.options.map((option) {
          final selected = _selectedId == option.id;
          Color color = MinikColors.surface;
          if (_selectedId != null && option.correct) color = MinikColors.mint;
          if (selected && !option.correct) color = MinikColors.blush;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinikCard(
              color: color,
              onTap: _selectedId == null ? () => _answer(option) : null,
              child: Text(option.text, style: Theme.of(context).textTheme.titleMedium),
            ),
          );
        }),
        if (_selectedId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: _index == widget.questions.length - 1 ? 'Bitir' : 'Devam Et',
            onPressed: () => setState(() {
              _index += 1;
              _selectedId = null;
            }),
          ),
        ],
      ],
    );
  }

  Future<void> _answer(QuizOption option) async {
    setState(() => _selectedId = option.id);
    if (option.correct) {
      _score += 1;
      await _audio.playAsset(EffectAudio.correct);
    } else {
      await _audio.playAsset(EffectAudio.retry);
    }
  }
}
