import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'mushaf_decor.dart';
import 'mushaf_page.dart';

class MinikQuranPage extends StatefulWidget {
  const MinikQuranPage({super.key});

  @override
  State<MinikQuranPage> createState() => _MinikQuranPageState();
}

class _MinikQuranPageState extends State<MinikQuranPage> {
  Future<_QuranHome>? _future;
  LocalProgressStore? _store;
  ({int jsonPage, int displayNumber, String surahLabel})? _mushafMark;
  ({int surahId, int ayahNo, String label})? _mealMark;
  bool _marksReady = false;

  Future<_QuranHome> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    final store = context.read<LocalProgressStore>();
    return _QuranHome(
      daily: await quran.getDailyAyah(),
      surahs: await quran.getSurahIndex(),
      mushafMark: await store.getMushafBookmarkInfo(),
      mealMark: await store.getQuranMealBookmarkInfo(),
    );
  }

  Future<void> _refreshMarks() async {
    final store = _store ?? context.read<LocalProgressStore>();
    final mushaf = await store.getMushafBookmarkInfo();
    final meal = await store.getQuranMealBookmarkInfo();
    if (!mounted) return;
    setState(() {
      _mushafMark = mushaf;
      _mealMark = meal;
      _marksReady = true;
    });
  }

  void _onProgress() {
    _refreshMarks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(store, _store)) {
      _store?.removeListener(_onProgress);
      _store = store;
      _store!.addListener(_onProgress);
      _refreshMarks();
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
    await _refreshMarks();
  }

  Future<void> _openMeal({
    required int surahId,
    int? ayahNo,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranSurahPage(
          surahId: surahId,
          initialAyahNo: ayahNo,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshMarks();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<_QuranHome>(
          future: _future!,
          onRetry: () => setState(() {
            _future = _load();
          }),
          builder: (home) {
            final mushaf = _marksReady ? _mushafMark : home.mushafMark;
            final meal = _marksReady ? _mealMark : home.mealMark;
            return ListView(
              padding: AppSpacing.page,
              children: [
                const PageHeader(
                  title: "Kur'an-ı Kerim",
                  subtitle: 'Sure sure ayet ve meal, sayfa sayfa mushaf.',
                ),
                _QuranResumeCard(
                  title: 'Mushaf · kaldığın yer',
                  emptyHint: 'Mushafta “Burada kaldım” dersen burada durur.',
                  detail: mushaf == null
                      ? null
                      : '${TurkishNumber.pageLabel(mushaf.displayNumber)} · ${mushaf.surahLabel}',
                  icon: Icons.menu_book_rounded,
                  color: MinikColors.mint,
                  onOpen: () => _openMushaf(resume: mushaf != null),
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuranResumeCard(
                  title: 'Ayet ve meal · kaldığın yer',
                  emptyHint:
                      'Sure listesinde “Burada kaldım” dersen burada durur.',
                  detail: meal?.label,
                  icon: Icons.view_agenda_rounded,
                  color: MinikColors.of(
                      const Color(0xFFE8F0FA), const Color(0xFF1D2734)),
                  onOpen: meal == null
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Önce bir surede “Burada kaldım”a bas.',
                              ),
                            ),
                          );
                        }
                      : () => _openMeal(
                            surahId: meal.surahId,
                            ayahNo: meal.ayahNo,
                          ),
                ),
                const SizedBox(height: AppSpacing.sm),
                MinikCard(
                  color: MinikColors.butter,
                  onTap: () => _openMushaf(resume: false),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          color: MinikColors.green, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mushaf',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: MinikColors.darkGreen),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Parşömen sayfa, yazı boyutu ve elle ayet takibi.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: MinikColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: MinikColors.greenSoft),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (home.daily != null) _DailyAyahCard(verse: home.daily!),
                const SizedBox(height: AppSpacing.md),
                for (final surah in home.surahs)
                  ContentTile(
                    title: surah.name,
                    subtitle: '${surah.ayahCount} ayet',
                    leading: NumberBadge('${surah.id}'),
                    onTap: () => _openMeal(surahId: surah.id),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard({required this.verse});

  final QuranVerse verse;

  @override
  Widget build(BuildContext context) {
    final copy = joinCopyParts([
      '${surahName(verse.surahId)} ${verse.ayahNo}',
      verse.arabic,
      verse.meal,
    ]);
    return MinikCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Bugünün ayeti'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${surahName(verse.surahId)} ${verse.ayahNo}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: MinikColors.darkGreen,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ArabicText(
            verse.arabic,
            color: verse.isSajdahAyah ? kMushafSajdahRed : null,
          ),
          if (verse.hasMeal) ...[
            const SizedBox(height: 10),
            SelectableText(
              verse.meal,
              style: TextStyle(
                color: verse.isSajdahAyah ? kMushafSajdahRed : MinikColors.text,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FavoriteButton(
                kind: 'quran',
                id: '${verse.surahId}:${verse.ayahNo}',
                title: '${surahName(verse.surahId)} ${verse.ayahNo}',
              ),
              CopyIconButton(text: copy),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuranHome {
  const _QuranHome({
    required this.daily,
    required this.surahs,
    this.mushafMark,
    this.mealMark,
  });

  final QuranVerse? daily;
  final List<SurahIndexItem> surahs;
  final ({int jsonPage, int displayNumber, String surahLabel})? mushafMark;
  final ({int surahId, int ayahNo, String label})? mealMark;
}

class _QuranResumeCard extends StatelessWidget {
  const _QuranResumeCard({
    required this.title,
    required this.emptyHint,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onOpen,
  });

  final String title;
  final String emptyHint;
  final String? detail;
  final IconData icon;
  final Color color;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final hasMark = detail != null && detail!.trim().isNotEmpty;
    return MinikCard(
      color: color,
      onTap: onOpen,
      child: Row(
        children: [
          Icon(
            hasMark ? Icons.bookmark_rounded : icon,
            color: MinikColors.green,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.titleMedium?.copyWith(
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasMark ? detail! : emptyHint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall?.copyWith(
                    color: MinikColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasMark ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
            color: MinikColors.green,
          ),
        ],
      ),
    );
  }
}

class QuranSurahPage extends StatefulWidget {
  const QuranSurahPage({
    super.key,
    required this.surahId,
    this.initialAyahNo,
  });

  final int surahId;
  final int? initialAyahNo;

  @override
  State<QuranSurahPage> createState() => _QuranSurahPageState();
}

class _QuranSurahPageState extends State<QuranSurahPage> {
  Future<List<QuranVerse>>? _future;
  int? _savedAyahNo;
  final _ayahKeys = <int, GlobalKey>{};
  bool _didScrollToInitial = false;

  @override
  void initState() {
    super.initState();
    _savedAyahNo = widget.initialAyahNo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<LocalProgressStore>();
      store.markCompleted('quran', '${widget.surahId}', xp: 2);
    });
  }

  void _scrollToAyah(int ayahNo) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _ayahKeys[ayahNo]?.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.08,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _saveHere(QuranVerse verse) async {
    final store = context.read<LocalProgressStore>();
    final label = '${surahName(widget.surahId)} ${verse.ayahNo}';
    await store.setQuranMealBookmark(
      surahId: widget.surahId,
      ayahNo: verse.ayahNo,
      label: label,
    );
    if (!mounted) return;
    setState(() => _savedAyahNo = verse.ayahNo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label kaydedildi. “Ayet ve meal · kaldığın yer”den devam edebilirsin.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.quran.getSurah(widget.surahId);
    return Scaffold(
      appBar: AppBar(title: Text(surahName(widget.surahId))),
      body: AsyncBody<List<QuranVerse>>(
        future: _future!,
        onRetry: () => setState(() {
          _future = repos.quran.getSurah(widget.surahId);
        }),
        builder: (verses) {
          if (!_didScrollToInitial && widget.initialAyahNo != null) {
            _didScrollToInitial = true;
            _scrollToAyah(widget.initialAyahNo!);
          }
          return ListView.separated(
            padding: AppSpacing.page,
            itemCount: verses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final verse = verses[index];
              final savedHere = _savedAyahNo == verse.ayahNo;
              final key = _ayahKeys.putIfAbsent(
                verse.ayahNo,
                GlobalKey.new,
              );
              return MinikCard(
                key: key,
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
                          child:
                              Text(TurkishNumber.pageLabel(verse.displayPage)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ArabicText(
                      verse.arabic,
                      color: verse.isSajdahAyah ? kMushafSajdahRed : null,
                    ),
                    if (verse.hasMeal) ...[
                      const SizedBox(height: 10),
                      SelectableText(
                        verse.meal,
                        style: TextStyle(
                          color: verse.isSajdahAyah
                              ? kMushafSajdahRed
                              : MinikColors.text,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _saveHere(verse),
                          icon: Icon(
                            savedHere
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 20,
                          ),
                          label: Text(
                            savedHere ? 'Kaydedildi' : 'Burada kaldım',
                          ),
                        ),
                        const Spacer(),
                        CopyIconButton(
                          text: joinCopyParts([
                            '${surahName(widget.surahId)} ${verse.ayahNo}',
                            verse.arabic,
                            verse.meal,
                          ]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
