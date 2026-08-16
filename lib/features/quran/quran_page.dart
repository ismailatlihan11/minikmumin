import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/surah_names.dart';
import '../../app/routes.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikQuranPage extends StatefulWidget {
  const MinikQuranPage({super.key});

  @override
  State<MinikQuranPage> createState() => _MinikQuranPageState();
}

class _MinikQuranPageState extends State<MinikQuranPage> {
  Future<_QuranHome>? _future;

  Future<_QuranHome> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    return _QuranHome(
      daily: await quran.getDailyAyah(),
      surahs: await quran.getSurahIndex(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<_QuranHome>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (home) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: "Kur'an",
                subtitle: 'Sureleri oku ve keşfet.',
                image: 'assets/images/quran/quran.png',
              ),
              if (home.daily != null)
                MinikCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranSurahPage(surahId: home.daily!.surahId),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionLabel('Bugünün ayeti'),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${surahName(home.daily!.surahId)} ${home.daily!.ayahNo}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ArabicText(home.daily!.arabic),
                      const SizedBox(height: 10),
                      SelectableText(home.daily!.meal),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CopyIconButton(
                          text: joinCopyParts([
                            '${surahName(home.daily!.surahId)} ${home.daily!.ayahNo}',
                            home.daily!.arabic,
                            home.daily!.meal,
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              for (final surah in home.surahs)
                ContentTile(
                  title: surah.name,
                  subtitle: '${surah.ayahCount} ayet',
                  leading: NumberBadge('${surah.id}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranSurahPage(surahId: surah.id),
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

class _QuranHome {
  const _QuranHome({required this.daily, required this.surahs});

  final QuranVerse? daily;
  final List<SurahIndexItem> surahs;
}

class QuranSurahPage extends StatefulWidget {
  const QuranSurahPage({super.key, required this.surahId});

  final int surahId;

  @override
  State<QuranSurahPage> createState() => _QuranSurahPageState();
}

class _QuranSurahPageState extends State<QuranSurahPage> {
  Future<List<QuranVerse>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<LocalProgressStore>();
      store.markCompleted('quran', '${widget.surahId}', xp: 2);
      store.setContinue(
        title: surahName(widget.surahId),
        subtitle: "Kur'an",
        route: AppRoutes.quran,
        progress: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.quran.getSurah(widget.surahId);
    return Scaffold(
      appBar: AppBar(title: Text(surahName(widget.surahId))),
      body: AsyncBody<List<QuranVerse>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.quran.getSurah(widget.surahId)),
        builder: (verses) => ListView.separated(
          padding: AppSpacing.page,
          itemCount: verses.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final verse = verses[index];
            return MinikCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SoftBadge(label: '${verse.ayahNo}'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArabicText(verse.arabic),
                  const SizedBox(height: 10),
                  SelectableText(verse.meal),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CopyIconButton(
                      text: joinCopyParts([
                        '${surahName(widget.surahId)} ${verse.ayahNo}',
                        verse.arabic,
                        verse.meal,
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
