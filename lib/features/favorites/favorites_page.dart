import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import '../duas/duas_page.dart';
import '../hadith/hadith_page.dart';
import '../quran_learn/quran_learn_harakat.dart';
import '../quran_learn/quran_learn_hub.dart';
import '../quran_learn/quran_learn_letters.dart';
import '../quran_learn/quran_learn_surahs.dart';
import '../quran_learn/quran_learn_tajweed.dart';
import '../quran_learn/quran_learn_words.dart';
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
        final pack = await repos.quranLearning.load();
        if (!context.mounted) return;
        await _openQuranLearnFavorite(context, pack, item);
      case 'elifba_example':
        if (!context.mounted) return;
        await Navigator.pushNamed(context, AppRoutes.learnElifbaAdventure);
      default:
        return;
    }
  }

  Future<void> _openQuranLearnFavorite(
    BuildContext context,
    QuranLearningPack pack,
    FavoriteEntry item,
  ) async {
    switch (item.kind) {
      case 'ql_letter':
        final letter = pack.letterById(item.id);
        if (letter == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuranLearnLetterDetailPage(pack: pack, letter: letter),
          ),
        );
      case 'ql_haraka':
        final haraka = pack.harakaById(item.id);
        if (haraka == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuranLearnHarakaDetailPage(pack: pack, haraka: haraka),
          ),
        );
      case 'ql_word':
        final word = pack.wordById(item.id);
        if (word == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranLearnWordDetailPage(pack: pack, word: word),
          ),
        );
      case 'ql_tajweed':
        final lesson = pack.tajweedById(item.id);
        if (lesson == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuranLearnTajweedDetailPage(pack: pack, lesson: lesson),
          ),
        );
      case 'ql_surah':
        final surah = pack.surahById(item.id);
        if (surah == null) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranLearnSurahReaderPage(
              pack: pack,
              surah: surah,
              mode: QuranLearnReadMode.surah,
            ),
          ),
        );
      default:
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuranLearnHubPage()),
        );
    }
  }
}
