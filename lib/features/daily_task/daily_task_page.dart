import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/daily_seed.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/dua.dart';
import '../../data/models/quran_learning.dart';
import '../../data/models/quiz.dart';
import '../../data/models/story.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';
import '../duas/duas_page.dart';
import '../quiz/quiz_page.dart';
import '../quran_learn/quran_learn_nav.dart';
import '../quran_learn/quran_learn_progress.dart';
import '../stories/stories_page.dart';

class DailyTaskPage extends StatefulWidget {
  const DailyTaskPage({super.key});

  @override
  State<DailyTaskPage> createState() => _DailyTaskPageState();
}

class _DailyTaskPageState extends State<DailyTaskPage> {
  Future<_DailyLoop>? _future;

  Future<_DailyLoop> _load(
    ContentRepositories repos,
    LocalProgressStore store,
  ) async {
    final duas = await repos.duas.getCatalog();
    final stories = await repos.stories.load();
    final questions = await repos.quiz.getAll();
    QuranLearnDailyLesson? quranLesson;
    QuranLearningPack? pack;
    try {
      pack = await repos.quranLearning.load();
      final snap = await QuranLearnProgress.load(store, pack);
      quranLesson = snap.dailyLesson();
    } catch (_) {
      quranLesson = null;
      pack = null;
    }
    return _DailyLoop(
      dua: duas.isEmpty ? null : pickDaily(duas),
      story: stories.items.isEmpty ? null : pickDaily(stories.items),
      question: questions.isEmpty ? null : pickDaily(questions),
      quranPack: pack,
      quranLesson: quranLesson,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    final store = context.read<LocalProgressStore>();
    _future ??= _load(repos, store);
    return Scaffold(
      appBar: AppBar(title: const Text('Günün Görevi')),
      body: AsyncBody<_DailyLoop>(
        future: _future!,
        onRetry: () => setState(() {
          _future = _load(repos, store);
        }),
        emptyTitle: 'Bugün için görev bulunamadı.',
        builder: (loop) {
          if (loop.isEmpty) {
            return const EmptyState(title: 'Bugün için görev bulunamadı.');
          }
          return ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Günün Döngüsü',
                subtitle: 'Bugünün duası, kıssası ve sorusu.',
              ),
              if (loop.quranLesson != null && loop.quranPack != null)
                _DailyCard(
                  title: "Bugünün Kur'an dersi",
                  subtitle: loop.quranLesson!.title,
                  icon: Icons.menu_book_outlined,
                  onTap: () => openQuranLearnDaily(
                    context,
                    pack: loop.quranPack!,
                    lesson: loop.quranLesson!,
                  ),
                ),
              if (loop.dua != null)
                _DailyCard(
                  title: 'Günün duası',
                  subtitle: loop.dua!.title,
                  icon: Icons.menu_book_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DuaDetailPage(dua: loop.dua!, kind: 'dua'),
                    ),
                  ),
                ),
              if (loop.story != null)
                _DailyCard(
                  title: 'Günün kıssası',
                  subtitle: loop.story!.title,
                  icon: Icons.auto_stories_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryReaderPage(story: loop.story!),
                    ),
                  ),
                ),
              if (loop.question != null)
                _DailyCard(
                  title: 'Günün sorusu',
                  subtitle: loop.question!.question,
                  icon: Icons.quiz_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Günün sorusu')),
                        body: QuizPlayView(questions: [loop.question!]),
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

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ContentTile(
      title: title,
      subtitle: subtitle,
      leading: Icon(icon, color: MinikColors.green),
      onTap: onTap,
    );
  }
}

class _DailyLoop {
  const _DailyLoop({
    this.dua,
    this.story,
    this.question,
    this.quranPack,
    this.quranLesson,
  });

  final DuaEntry? dua;
  final StoryItem? story;
  final QuizQuestion? question;
  final QuranLearningPack? quranPack;
  final QuranLearnDailyLesson? quranLesson;

  bool get isEmpty =>
      dua == null && story == null && question == null && quranLesson == null;
}
