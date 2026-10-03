import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import '../duas/duas_page.dart';
import '../hadith/hadith_page.dart';
import '../stories/stories_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<FavoriteEntry>>(
          future: store.getFavorites(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <FavoriteEntry>[];
            return ListView(
              padding: AppSpacing.page,
              children: [
                const PageHeader(
                  title: 'Favoriler',
                  subtitle: 'Kalp koyduğun dualar ve kıssalar burada.',
                ),
                if (items.isEmpty) ...[
                  const SizedBox(height: 24),
                  MinikImage.asset(
                    'assets/images/home/empty_favorites.png',
                    height: 96,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.favorite_outline_rounded, size: 56),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori yok.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Beğendiğin duaları ve kıssaları kalp ile buraya ekleyebilirsin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ] else
                  for (final item in items)
                    ContentTile(
                      title: item.title,
                      subtitle: _kindLabel(item.kind),
                      trailing: const Icon(Icons.favorite_rounded,
                          color: Color(0xFFC45B7A)),
                      onTap: () => _open(context, item),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _kindLabel(String kind) {
    switch (kind) {
      case 'dua':
        return 'Dua';
      case 'prayer_dua':
        return 'Namaz duası';
      case 'story':
        return 'Kıssa';
      case 'hadith':
        return 'Hadis';
      case 'ql_letter':
        return 'Harf';
      case 'ql_haraka':
        return 'Hareke';
      case 'ql_word':
        return 'Kelime';
      case 'ql_tajweed':
        return 'Tecvid';
      case 'ql_surah':
        return 'Kısa sure';
      case 'elifba_example':
        return 'Elifbâ örneği';
      default:
        return kind;
    }
  }

  Future<void> _open(BuildContext context, FavoriteEntry item) async {
    final repos = context.read<ContentRepositories>();
    switch (item.kind) {
      case 'dua':
      case 'prayer_dua':
        final dua = await repos.duas.getEntryById(item.id);
        if (!context.mounted || dua == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuaDetailPage(dua: dua, kind: item.kind),
          ),
        );
      case 'story':
        final story = await repos.stories.getById(item.id);
        if (!context.mounted || story == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoryReaderPage(story: story)),
        );
      case 'hadith':
        final hadith = await repos.hadith.getById(item.id);
        if (!context.mounted || hadith == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HadithDetailPage(hadith: hadith)),
        );
      case 'ql_letter':
      case 'ql_haraka':
      case 'ql_word':
      case 'ql_tajweed':
      case 'ql_surah':
      case 'elifba_example':
        if (!context.mounted) return;
        await Navigator.pushNamed(context, AppRoutes.learnElifbaAdventure);
      default:
        return;
    }
  }
}
