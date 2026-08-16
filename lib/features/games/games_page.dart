import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/daily_seed.dart';
import '../../data/models/story.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quiz/quiz_page.dart';
import '../wudu/wudu_visual_catalog.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            const PageHeader(
              title: 'Oyunlar',
              subtitle: 'Öğrendiklerini eğlenerek pekiştir.',
              image: 'assets/images/home/mini_quiz.png',
            ),
            ContentTile(
              title: 'Abdest sırası',
              subtitle: 'Adımları doğru sırayla dokun.',
              leading: Image.asset(
                'assets/images/wudu/wudu.png',
                width: 44,
                height: 44,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.water_drop_rounded, color: MinikColors.green),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderGamePage(
                    title: 'Abdest sırası',
                    prompt: 'Abdest adımlarına doğru sırayla dokun.',
                    items: [
                      for (final step in WuduVisualCatalog.playableSteps)
                        OrderGameItem(
                          id: step.id,
                          title: step.title,
                          image: step.image,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ContentTile(
              title: 'Kıssa sahneleri',
              subtitle: 'Bugünün kıssasını sıraya koy.',
              leading: const Icon(Icons.auto_stories_rounded, color: MinikColors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryOrderGamePage()),
              ),
            ),
            ContentTile(
              title: 'Mini testler',
              subtitle: 'Sorularla pekiştir.',
              leading: const Icon(Icons.quiz_rounded, color: MinikColors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderGameItem {
  const OrderGameItem({
    required this.id,
    required this.title,
    this.image = '',
  });

  final String id;
  final String title;
  final String image;
}

class OrderGamePage extends StatefulWidget {
  const OrderGamePage({
    super.key,
    required this.title,
    required this.prompt,
    required this.items,
  });

  final String title;
  final String prompt;
  final List<OrderGameItem> items;

  @override
  State<OrderGamePage> createState() => _OrderGamePageState();
}

class _OrderGamePageState extends State<OrderGamePage> {
  late List<OrderGameItem> _shuffled;
  int _next = 0;
  String? _wrongId;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _shuffled = List<OrderGameItem>.from(widget.items)..shuffle(Random());
    _next = 0;
    _wrongId = null;
    _awarded = false;
  }

  Future<void> _tap(OrderGameItem item) async {
    if (_next >= widget.items.length) return;
    final expected = widget.items[_next];
    if (item.id != expected.id) {
      setState(() => _wrongId = item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sıra böyle değil, tekrar dene.')),
      );
      return;
    }
    setState(() {
      _wrongId = null;
      _next += 1;
    });
    if (_next >= widget.items.length && !_awarded) {
      _awarded = true;
      if (!mounted) return;
      await context.read<LocalProgressStore>().addXp(8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = _next >= widget.items.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Text(widget.prompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          LessonProgressBar(current: _next.clamp(0, widget.items.length), total: widget.items.length),
          const SizedBox(height: AppSpacing.md),
          if (done) ...[
            Image.asset(
              'assets/images/home/success.png',
              height: 120,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Maşallah!', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSpacing.md),
            const MinikCard(child: Text('Sırayı doğru tamamladın.')),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Tekrar Dene', onPressed: () => setState(_reset)),
          ] else
            for (final item in _shuffled)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MinikCard(
                  color: item.id == _wrongId
                      ? MinikColors.blush
                      : MinikColors.surface,
                  onTap: () => _tap(item),
                  child: Row(
                    children: [
                      if (item.image.isNotEmpty)
                        Image.asset(
                          item.image,
                          width: 44,
                          height: 44,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.touch_app_rounded,
                            color: MinikColors.green,
                          ),
                        )
                      else
                        const Icon(Icons.touch_app_rounded, color: MinikColors.green),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class StoryOrderGamePage extends StatefulWidget {
  const StoryOrderGamePage({super.key});

  @override
  State<StoryOrderGamePage> createState() => _StoryOrderGamePageState();
}

class _StoryOrderGamePageState extends State<StoryOrderGamePage> {
  Future<StoryItem?>? _future;

  Future<StoryItem?> _load() async {
    final catalog = await context.read<ContentRepositories>().stories.load();
    final playable = catalog.items.where((item) => item.scenes.length >= 3).toList();
    if (playable.isEmpty) return null;
    return pickDaily(playable);
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return FutureBuilder<StoryItem?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kıssa sahneleri')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final story = snapshot.data;
        if (story == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kıssa sahneleri')),
            body: const Center(child: Text('Sıralanacak kıssa bulunamadı.')),
          );
        }
        return OrderGamePage(
          title: story.title,
          prompt: 'Bu kıssanın sahnelerine doğru sırayla dokun.',
          items: [
            for (final scene in story.scenes)
              OrderGameItem(id: '${scene.order}', title: scene.title),
          ],
        );
      },
    );
  }
}
