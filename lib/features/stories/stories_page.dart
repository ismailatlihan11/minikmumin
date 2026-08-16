import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/story.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import '../duas/duas_page.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  Future<StoryCatalog>? _future;

  Future<StoryCatalog> _load() {
    return context.read<ContentRepositories>().stories.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<StoryCatalog>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (catalog) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Kıssalar',
                subtitle: 'Kur\'an\'daki kıssaları sahne sahne dinleyelim.',
                image: 'assets/images/home/circle_stories.png',
              ),
              ContentTile(
                title: 'Tüm kıssalar',
                subtitle: '${catalog.items.length} kıssa',
                leading: const Icon(Icons.auto_stories_rounded, color: MinikColors.green),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoriesListPage(
                      title: 'Tüm kıssalar',
                      stories: catalog.items,
                    ),
                  ),
                ),
              ),
              for (final category in catalog.categories)
                ContentTile(
                  title: category.title,
                  subtitle: '${catalog.forCategory(category.id).length} kıssa',
                  leading: const Icon(Icons.menu_book_rounded, color: MinikColors.green),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoriesListPage(
                        title: category.title,
                        stories: catalog.forCategory(category.id),
                      ),
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

class StoriesListPage extends StatelessWidget {
  const StoriesListPage({
    super.key,
    required this.title,
    required this.stories,
  });

  final String title;
  final List<StoryItem> stories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          for (final story in stories)
            ContentTile(
              title: story.order > 0 ? '${story.order}. ${story.title}' : story.title,
              subtitle: story.summary,
              leading: Image.asset(
                story.image.isNotEmpty
                    ? story.image
                    : 'assets/images/home/circle_stories.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_stories_rounded,
                  color: MinikColors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StoryReaderPage(story: story)),
              ),
            ),
        ],
      ),
    );
  }
}

class StoryReaderPage extends StatefulWidget {
  const StoryReaderPage({super.key, required this.story});

  final StoryItem story;

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  final _audio = AudioPlayerService();
  int _page = 0;
  bool _restored = false;
  bool _completed = false;

  int get _sceneCount => widget.story.scenes.length;
  int get _lastPage => _sceneCount + 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    final store = context.read<LocalProgressStore>();
    final saved = await store.getStoryPage(widget.story.id);
    if (!mounted) return;
    setState(() {
      _page = saved.clamp(0, _lastPage);
      _restored = true;
    });
    await _syncProgress();
  }

  Future<void> _goTo(int page) async {
    setState(() => _page = page);
    await _syncProgress();
    if (page >= _lastPage && !_completed) {
      _completed = true;
      if (!mounted) return;
      await context.read<LocalProgressStore>().markCompleted(
            'story',
            widget.story.id,
            xp: 8,
          );
    }
  }

  Future<void> _syncProgress() async {
    final store = context.read<LocalProgressStore>();
    await store.setStoryPage(widget.story.id, _page);
    await store.setContinue(
      title: widget.story.title,
      subtitle: 'Kıssa',
      route: AppRoutes.learnStories,
      progress: _lastPage == 0 ? 0 : (_page / _lastPage).clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    return Scaffold(
      appBar: AppBar(
        title: Text(story.title),
        actions: [
          FavoriteButton(kind: 'story', id: story.id, title: story.title),
        ],
      ),
      body: !_restored
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.page,
              children: [
                if (_page == 0)
                  _cover(context, story)
                else if (_page <= _sceneCount)
                  _scene(context, story.scenes[_page - 1], _page, _sceneCount)
                else
                  _ending(context, story),
                const SizedBox(height: AppSpacing.lg),
                if (_page == 0)
                  PrimaryButton(
                    label: 'Başla',
                    onPressed: () => _goTo(_sceneCount == 0 ? _lastPage : 1),
                  )
                else ...[
                  PrimaryButton(
                    label: _page >= _lastPage
                        ? 'Bitti'
                        : (_page == _sceneCount ? 'Dersi gör' : 'Devam Et'),
                    onPressed: _page >= _lastPage
                        ? null
                        : () => _goTo(_page + 1),
                  ),
                  if (_page > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: 'Geri',
                      onPressed: () => _goTo(_page - 1),
                    ),
                  ],
                ],
              ],
            ),
    );
  }

  Widget _cover(BuildContext context, StoryItem story) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          story.image.isNotEmpty ? story.image : 'assets/images/home/circle_stories.png',
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/home/circle_stories.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(story.title, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(story.summary, style: Theme.of(context).textTheme.bodyLarge),
        if (story.audio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ListenButton(audio: _audio, path: story.audio),
        ],
      ],
    );
  }

  Widget _scene(BuildContext context, StoryScene scene, int index, int total) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Sahne $index / $total', style: theme.bodySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(scene.title, style: theme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(scene.text, style: theme.bodyLarge),
        if (scene.references.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(scene.references.join(' • '), style: theme.bodySmall),
        ],
      ],
    );
  }

  Widget _ending(BuildContext context, StoryItem story) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (story.lessons.isNotEmpty) ...[
          const SectionLabel('Bu kıssadan öğrendiklerimiz'),
          for (final lesson in story.lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: MinikColors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(lesson, style: theme.bodyLarge)),
                ],
              ),
            ),
        ],
        if (story.reflection.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.butter,
            child: Text(story.reflection, style: theme.bodyLarge),
          ),
        ],
        if (story.quranReferences.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Kur\'an'),
          Text(story.quranReferences.join(' • '), style: theme.bodyLarge),
        ],
        if (story.duaReference.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(story.duaReference, style: theme.bodySmall),
        ],
      ],
    );
  }
}
