import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/lessons.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/content_repositories.dart';
import '../../data/repositories/learn_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quiz/quiz_page.dart';

class IlmihalPage extends StatefulWidget {
  const IlmihalPage({super.key});

  @override
  State<IlmihalPage> createState() => _IlmihalPageState();
}

class _IlmihalPageState extends State<IlmihalPage> {
  Future<IlmihalCatalog>? _future;

  Future<IlmihalCatalog> _load() {
    return context.read<ContentRepositories>().ilmihal.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<IlmihalCatalog>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (catalog) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Temel Dini Bilgiler',
                subtitle: 'İman, temizlik, namaz ve günlük hayattaki konuları öğrenelim.',
                image: 'assets/images/home/ilmihal.png',
              ),
              for (final category in catalog.categories)
                ContentTile(
                  title: category.title,
                  subtitle: '${catalog.lessonsFor(category.id).length} konu',
                  leading: Image.asset(
                    ContentAssets.ilmihalImage(category.id, category.icon),
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: MinikColors.green,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IlmihalCategoryPage(
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
                      builder: (_) => _IlmihalQuizPage(questions: catalog.quiz),
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

class IlmihalCategoryPage extends StatelessWidget {
  const IlmihalCategoryPage({
    super.key,
    required this.category,
    required this.lessons,
  });

  final IlmihalCategory category;
  final List<IlmihalLesson> lessons;

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
              subtitle: lesson.summary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IlmihalLessonPage(lesson: lesson),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class IlmihalLessonPage extends StatelessWidget {
  const IlmihalLessonPage({super.key, required this.lesson});

  final IlmihalLesson lesson;

  static String? _routeFor(String linkedModule) {
    switch (linkedModule) {
      case '/learn/wudu':
        return AppRoutes.learnWudu;
      case '/learn/prayer':
        return AppRoutes.learnPrayer;
      case '/learn/duas':
        return AppRoutes.learnDuas;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final linkedRoute = _routeFor(lesson.linkedModule);
    return DetailScaffold(
      title: lesson.title,
      actions: [
        CopyIconButton(
          text: joinCopyParts([
            lesson.title,
            lesson.summary,
            ...lesson.keyPoints,
            lesson.memorization,
            lesson.activity,
            lesson.quranReference,
          ]),
        ),
      ],
      children: [
        Text(lesson.summary, style: theme.bodyLarge),
        if (lesson.keyPoints.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          for (final point in lesson.keyPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: MinikColors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point, style: theme.bodyLarge)),
                ],
              ),
            ),
        ],
        if (lesson.memorization.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.mint,
            child: Text(lesson.memorization, style: theme.bodyLarge),
          ),
        ],
        if (lesson.activity.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.butter,
            child: Text(lesson.activity, style: theme.bodyLarge),
          ),
        ],
        if (lesson.quranReference.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(lesson.quranReference, style: theme.bodySmall),
        ],
        if (lesson.parentGuidance.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(lesson.parentGuidance, style: theme.bodySmall),
        ],
        if (lesson.adultGuidance.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(lesson.adultGuidance, style: theme.bodySmall),
        ],
        if (linkedRoute != null) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Uygulamalı öğren',
            onPressed: () => Navigator.pushNamed(context, linkedRoute),
          ),
        ],
      ],
    );
  }
}

class _IlmihalQuizPage extends StatelessWidget {
  const _IlmihalQuizPage({required this.questions});

  final List<QuizQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini sorular')),
      body: QuizPlayView(questions: questions),
    );
  }
}
