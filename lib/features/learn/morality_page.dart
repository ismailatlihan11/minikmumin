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
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import '../../shared/widgets/topic_footer.dart';
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
          onRetry: () => setState(() {
            _future = _load();
          }),
          builder: (catalog) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Güzel Ahlak',
                subtitle: 'Güzel davranışları günlük hayatta uygulayalım.',
              ),
              for (final (index, category) in catalog.categories.indexed)
                ContentTile(
                  title: category.title,
                  subtitle: '${catalog.lessonsFor(category.id).length} konu',
                  leading:
                      Icon(Icons.favorite_rounded, color: MinikColors.green),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MoralityCategoryPage(
                        category: category,
                        lessons: catalog.lessonsFor(category.id),
                        later: [
                          for (final next in catalog.categories.skip(index + 1))
                            for (final lesson in catalog.lessonsFor(next.id))
                              (item: lesson, group: next.title),
                        ],
                      ),
                    ),
                  ),
                ),
              if (catalog.quiz.isNotEmpty)
                ContentTile(
                  title: 'Mini sorular',
                  subtitle: '${catalog.quiz.length} soru',
                  leading: Icon(Icons.quiz_rounded, color: MinikColors.green),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _MoralityQuizPage(questions: catalog.quiz),
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
    this.later = const [],
  });

  final MoralityCategory category;
  final List<MoralityLesson> lessons;

  /// Sonraki kategorilerin konuları; son konudan sonra bunlara geçilir.
  final List<UpcomingTopic<MoralityLesson>> later;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          for (final (index, lesson) in lessons.indexed)
            ContentTile(
              title: '${lesson.order}. ${lesson.title}',
              subtitle: lesson.shortMessage.isNotEmpty
                  ? lesson.shortMessage
                  : lesson.lesson,
              leading: MinikImage.asset(
                ContentAssets.moralityImage(lesson.id, lesson.image),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.favorite_rounded,
                  color: MinikColors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoralityLessonPage(
                    lesson: lesson,
                    categoryTitle: category.title,
                    upcoming: [
                      for (final next in lessons.skip(index + 1))
                        (item: next, group: category.title),
                      ...later,
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MoralityLessonPage extends StatelessWidget {
  const MoralityLessonPage({
    super.key,
    required this.lesson,
    this.categoryTitle,
    this.upcoming = const [],
  });

  final MoralityLesson lesson;
  final String? categoryTitle;
  final List<UpcomingTopic<MoralityLesson>> upcoming;

  void _openNext(BuildContext context) {
    final next = upcoming.first;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MoralityLessonPage(
          lesson: next.item,
          categoryTitle: next.group,
          upcoming: upcoming.sublist(1),
        ),
      ),
    );
  }

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
          actions: [
            CopyIconButton(
              text: joinCopyParts([
                lesson.title,
                lesson.shortMessage,
                lesson.childExplanation.isNotEmpty
                    ? lesson.childExplanation
                    : lesson.lesson,
                ...lesson.quranReferences,
              ]),
            ),
          ],
          children: [
            MinikImage.asset(
              imagePath,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => MinikImage.asset(
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
              lesson.childExplanation.isNotEmpty
                  ? lesson.childExplanation
                  : lesson.lesson,
              style: theme.bodyLarge,
            ),
            if (lesson.quranReferences.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const SectionLabel('Kur\'an'),
              Text(lesson.quranReferences.join(' • '), style: theme.bodyLarge),
            ],
            const SizedBox(height: AppSpacing.lg),
            TopicFooter(
              learned: done,
              onLearn: () => store.markCompleted('morality', lesson.id, xp: 5),
              hasNext: upcoming.isNotEmpty,
              onNext: () => _openNext(context),
              currentGroup: categoryTitle,
              nextGroup: upcoming.isEmpty ? null : upcoming.first.group,
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
