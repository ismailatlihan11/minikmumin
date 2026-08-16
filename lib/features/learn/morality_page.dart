import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/lessons.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/content_repositories.dart';
import '../../data/repositories/learn_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quiz/quiz_page.dart';

class MoralityPage extends StatefulWidget {
  const MoralityPage({super.key});

  @override
  State<MoralityPage> createState() => _MoralityPageState();
}

class _MoralityPageState extends State<MoralityPage> {
  Future<MoralityCatalog>? _future;

  Future<MoralityCatalog> _load() {
    return context.read<ContentRepositories>().morality.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<MoralityCatalog>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (catalog) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Güzel Ahlak',
                subtitle: 'Güzel davranışları günlük hayatta uygulayalım.',
                image: 'assets/images/morality/morality.png',
              ),
              for (final category in catalog.categories)
                ContentTile(
                  title: category.title,
                  subtitle: '${catalog.lessonsFor(category.id).length} konu',
                  leading: const Icon(Icons.favorite_rounded, color: MinikColors.green),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoralityCategoryPage(
                        category: category,
                        lessons: catalog.lessonsFor(category.id),
                      ),
                    ),
                  ),
                ),
              if (catalog.quiz.isNotEmpty)
                ContentTile(
                  title: 'Mini sorular',
                  subtitle: '${catalog.quiz.length} soru',
                  leading: const Icon(Icons.quiz_rounded, color: MinikColors.green),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _MoralityQuizPage(questions: catalog.quiz),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoralityCategoryPage extends StatelessWidget {
  const MoralityCategoryPage({
    super.key,
    required this.category,
    required this.lessons,
  });

  final MoralityCategory category;
  final List<MoralityLesson> lessons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          for (final lesson in lessons)
            ContentTile(
              title: '${lesson.order}. ${lesson.title}',
              subtitle: lesson.shortMessage.isNotEmpty ? lesson.shortMessage : lesson.lesson,
              leading: Image.asset(
                ContentAssets.moralityImage(lesson.id, lesson.image),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.favorite_rounded,
                  color: MinikColors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoralityLessonPage(lesson: lesson),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MoralityLessonPage extends StatelessWidget {
  const MoralityLessonPage({super.key, required this.lesson});

  final MoralityLesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imagePath = ContentAssets.moralityImage(lesson.id, lesson.image);
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted('morality', lesson.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return DetailScaffold(
          title: lesson.title,
          children: [
            Image.asset(
              imagePath,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/morality/morality.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
            if (lesson.shortMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(lesson.shortMessage, style: theme.titleMedium),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              lesson.childExplanation.isNotEmpty ? lesson.childExplanation : lesson.lesson,
              style: theme.bodyLarge,
            ),
            if (lesson.dailyChallenge.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.butter,
                child: Text(lesson.dailyChallenge, style: theme.bodyLarge),
              ),
            ],
            if (lesson.quranReferences.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const SectionLabel('Kur\'an'),
              Text(lesson.quranReferences.join(' • '), style: theme.bodyLarge),
            ],
            if (lesson.hadithReference.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(lesson.hadithReference, style: theme.bodySmall),
            ] else if (lesson.source.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Kaynak: ${lesson.source}', style: theme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: done ? 'Öğrendin' : 'Öğrendim',
              onPressed: done
                  ? null
                  : () => store.markCompleted('morality', lesson.id, xp: 5),
            ),
          ],
        );
      },
    );
  }
}

class _MoralityQuizPage extends StatelessWidget {
  const _MoralityQuizPage({required this.questions});

  final List<QuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini sorular')),
      body: QuizPlayView(questions: questions),
    );
  }
}
