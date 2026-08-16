import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/surah_names.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_ui.dart';
import 'mushaf_page.dart';

class MinikQuranPage extends StatefulWidget {
  const MinikQuranPage({super.key});

  @override
  State<MinikQuranPage> createState() => _MinikQuranPageState();
}

class _MinikQuranPageState extends State<MinikQuranPage> {
  Future<_QuranHome>? _future;
  LocalProgressStore? _store;
  ({int jsonPage, int displayNumber, String surahLabel})? _bookmark;
  bool _bookmarkReady = false;

  Future<_QuranHome> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    final store = context.read<LocalProgressStore>();
    return _QuranHome(
      daily: await quran.getDailyAyah(),
      surahs: await quran.getSurahIndex(),
      bookmark: await store.getMushafBookmarkInfo(),
    );
  }

  Future<void> _refreshBookmark() async {
    final info = await (_store ?? context.read<LocalProgressStore>())
        .getMushafBookmarkInfo();
    if (!mounted) return;
    setState(() {
      _bookmark = info;
      _bookmarkReady = true;
    });
  }

  void _onProgress() {
    _refreshBookmark();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(store, _store)) {
      _store?.removeListener(_onProgress);
      _store = store;
      _store!.addListener(_onProgress);
      _refreshBookmark();
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_onProgress);
    super.dispose();
  }

  Future<void> _openMushaf({required bool resume}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MushafReaderPage(resume: resume)),
    );
    if (!mounted) return;
    await _refreshBookmark();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<_QuranHome>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (home) {
            final bookmark = _bookmarkReady ? _bookmark : home.bookmark;
            return ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: "Kur'an-ı Kerim",
                subtitle: 'Sure sure ayet ve meal, sayfa sayfa mushaf.',
                image: 'assets/images/quran/quran.png',
              ),
              _QuranResumeCard(
                bookmark: bookmark,
                onOpen: () => _openMushaf(resume: bookmark != null),
              ),
              const SizedBox(height: AppSpacing.sm),
              MinikCard(
                color: const Color(0xFFF7EBC4),
                onTap: () => _openMushaf(resume: false),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: MinikColors.green, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mushaf', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            'Sayfa sayfa Arapça.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: MinikColors.greenSoft),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                      if (home.daily!.hasMeal) ...[
                        const SizedBox(height: 10),
                        SelectableText(home.daily!.meal),
                      ],
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
          );
          },
        ),
      ),
    );
  }
}

class _QuranHome {
  const _QuranHome({
    required this.daily,
    required this.surahs,
    this.bookmark,
  });

  final QuranVerse? daily;
  final List<SurahIndexItem> surahs;
  final ({int jsonPage, int displayNumber, String surahLabel})? bookmark;
}

class _QuranResumeCard extends StatelessWidget {
  const _QuranResumeCard({
    required this.bookmark,
    required this.onOpen,
  });

  final ({int jsonPage, int displayNumber, String surahLabel})? bookmark;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final subtitle = bookmark == null
        ? 'Mushafı aç. Okuduğun sayfa burada durur.'
        : '${TurkishNumber.pageLabel(bookmark!.displayNumber)} · ${TurkishNumber.words(bookmark!.displayNumber)} · ${bookmark!.surahLabel}';
    return MinikCard(
      color: MinikColors.mint,
      onTap: onOpen,
      child: Row(
        children: [
          Icon(
            bookmark == null ? Icons.menu_book_rounded : Icons.bookmark_rounded,
            color: MinikColors.green,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaldığın yerden devam et',
                  style: theme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: MinikColors.green),
        ],
      ),
    );
  }
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
                  Row(
                    children: [
                      SoftBadge(label: '${verse.ayahNo}'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MushafReaderPage(
                              initialJsonPage: verse.page,
                            ),
                          ),
                        ),
                        child: Text(TurkishNumber.pageLabel(verse.displayPage)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArabicText(verse.arabic),
                  if (verse.hasMeal) ...[
                    const SizedBox(height: 10),
                    SelectableText(verse.meal),
                  ],
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
