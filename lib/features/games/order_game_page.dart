import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/story.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';

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
    this.nextLabel,
    this.onNext,
  });

  final String title;
  final String prompt;
  final List<OrderGameItem> items;
  final String? nextLabel;
  final VoidCallback? onNext;

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
          LessonProgressBar(
            current: _next.clamp(0, widget.items.length),
            total: widget.items.length,
          ),
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
            if (widget.onNext != null && (widget.nextLabel ?? '').isNotEmpty) ...[
              PrimaryButton(label: widget.nextLabel!, onPressed: widget.onNext),
              const SizedBox(height: AppSpacing.sm),
            ],
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
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
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

List<StoryItem> playableStoryOrderItems(List<StoryItem> items) {
  return items.where((item) => item.scenes.length >= 3).toList();
}

class _StoryOrderGamePageState extends State<StoryOrderGamePage> {
  Future<List<StoryItem>>? _future;

  Future<List<StoryItem>> _load() async {
    final catalog = await context.read<ContentRepositories>().stories.load();
    final playable = playableStoryOrderItems(catalog.items)..shuffle(Random());
    return playable;
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return FutureBuilder<List<StoryItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kıssa sahneleri')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final stories = snapshot.data ?? const <StoryItem>[];
        if (stories.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Kıssa sahneleri')),
            body: const Center(child: Text('Sıralanacak kıssa bulunamadı.')),
          );
        }
        return _StoryOrderSession(stories: stories);
      },
    );
  }
}

class _StoryOrderSession extends StatefulWidget {
  const _StoryOrderSession({required this.stories});

  final List<StoryItem> stories;

  @override
  State<_StoryOrderSession> createState() => _StoryOrderSessionState();
}

class _StoryOrderSessionState extends State<_StoryOrderSession> {
  int _index = 0;

  StoryItem get _story => widget.stories[_index];

  void _nextStory() {
    setState(() => _index = (_index + 1) % widget.stories.length);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.stories.length;
    return OrderGamePage(
      key: ValueKey('${_story.id}-$_index'),
      title: _story.title,
      prompt: total > 1
          ? 'Kıssa ${_index + 1} / $total. Sahnelerine doğru sırayla dokun.'
          : 'Bu kıssanın sahnelerine doğru sırayla dokun.',
      items: [
        for (final scene in _story.scenes)
          OrderGameItem(id: '${scene.order}', title: scene.title),
      ],
      nextLabel: total > 1 ? 'Sonraki kıssa' : null,
      onNext: total > 1 ? _nextStory : null,
    );
  }
}
