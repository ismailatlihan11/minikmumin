import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<QuizBank>? _future;

  Future<QuizBank> _load() {
    return context.read<ContentRepositories>().quiz.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<QuizBank>(
          future: _future!,
          onRetry: () => setState(() {
            _future = _load();
          }),
          builder: (bank) => ListView(
            padding: AppSpacing.page,
            children: [
              PageHeader(
                title: 'Öğrendiklerini Dene!',
                subtitle: 'Bakalım kaç soruyu doğru yapabileceksin?',
              ),
              ContentTile(
                title: 'Karışık sorular',
                subtitle: '${bank.questionsPerSession} soruluk oturum',
                leading: Icon(Icons.shuffle_rounded, color: MinikColors.green),
                onTap: () => _openSession(
                    context, bank, bank.questions, 'Karışık sorular'),
              ),
              for (final category in bank.categories)
                ContentTile(
                  title: category,
                  subtitle: '${bank.forCategory(category).length} soru',
                  leading: Icon(Icons.quiz_rounded, color: MinikColors.green),
                  onTap: () => _openSession(
                    context,
                    bank,
                    bank.forCategory(category),
                    category,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSession(
    BuildContext context,
    QuizBank bank,
    List<QuizQuestion> pool,
    String title,
  ) {
    if (pool.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: QuizPlayView(
            questions: pool,
            shuffle: true,
            limit: bank.questionsPerSession,
            correctFeedback: bank.correctFeedback,
            wrongFeedback: bank.wrongFeedback,
          ),
        ),
      ),
    );
  }
}

class QuizPlayView extends StatefulWidget {
  const QuizPlayView({
    super.key,
    required this.questions,
    this.shuffle = false,
    this.limit,
    this.correctFeedback = const [],
    this.wrongFeedback = const [],
  });

  final List<QuizQuestion> questions;
  final bool shuffle;
  final int? limit;
  final List<String> correctFeedback;
  final List<String> wrongFeedback;

  @override
  State<QuizPlayView> createState() => _QuizPlayViewState();
}

class _QuizPlayViewState extends State<QuizPlayView> {
  late List<QuizQuestion> _session;
  int _index = 0;
  int _score = 0;
  String? _selectedId;
  final AudioPlayerService _audio = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    _session = _buildSession();
  }

  List<QuizQuestion> _buildSession() {
    final pool = List<QuizQuestion>.from(widget.questions);
    if (widget.shuffle) pool.shuffle();
    final limit = widget.limit;
    final sliced = limit == null || pool.length <= limit
        ? pool
        : pool.take(limit).toList();
    if (!widget.shuffle) return sliced;
    return sliced.map((question) => question.shuffledOptions()).toList();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isEmpty) {
      return const Center(child: Text('Soru bulunamadı.'));
    }
    if (_index >= _session.length) {
      final total = _session.length;
      final stars = total == 0 ? 0 : ((_score / total) * 5).round().clamp(0, 5);
      final perfect = _score == total && total > 0;
      return ListView(
        padding: AppSpacing.page,
        children: [
          MinikImage.asset(
            'assets/images/home/success.png',
            height: 120,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            perfect ? 'Harika! Çok güzel öğrendin!' : 'Maşallah!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.mint,
            child: Column(
              children: [
                Text(
                  '$_score / $total',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⭐' * (stars == 0 ? 1 : stars),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  perfect
                      ? 'Bütün soruları bildin. Aferin!'
                      : '$total sorudan $_score tanesini bildin.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Tekrar dene',
            onPressed: () => setState(() {
              _session = _buildSession();
              _index = 0;
              _score = 0;
              _selectedId = null;
            }),
          ),
        ],
      );
    }

    final question = _session[_index];
    final selected =
        question.options.where((option) => option.id == _selectedId);
    final answeredCorrect = selected.isNotEmpty && selected.first.correct;
    return ListView(
      padding: AppSpacing.page,
      children: [
        LessonProgressBar(current: _index + 1, total: _session.length),
        const SizedBox(height: AppSpacing.md),
        MinikCard(
          color: MinikColors.butter,
          child: Text(question.question,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.md),
        ...question.options.map((option) {
          final isSelected = _selectedId == option.id;
          Color color = MinikColors.surface;
          if (_selectedId != null && option.correct) color = MinikColors.mint;
          if (isSelected && !option.correct) color = MinikColors.blush;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinikCard(
              color: color,
              onTap: _selectedId == null ? () => _answer(option) : null,
              child: Text(option.text,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          );
        }),
        if (_selectedId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          if (_feedback(answeredCorrect
                  ? widget.correctFeedback
                  : widget.wrongFeedback)
              .isNotEmpty)
            Text(
              _feedback(answeredCorrect
                  ? widget.correctFeedback
                  : widget.wrongFeedback),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(question.explanation,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: _index == _session.length - 1 ? 'Bitir' : 'Devam et',
            onPressed: () async {
              if (_index == _session.length - 1) {
                final store = context.read<LocalProgressStore>();
                await store.addXp((_score * 2).clamp(2, 20));
                await store.markCompleted('quiz', 'session');
              }
              if (!mounted) return;
              setState(() {
                _index += 1;
                _selectedId = null;
              });
            },
          ),
        ],
      ],
    );
  }

  String _feedback(List<String> messages) {
    if (messages.isEmpty) return '';
    return messages[_index % messages.length];
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
