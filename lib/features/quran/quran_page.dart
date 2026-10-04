import 'dart:math';

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
import '../../shared/widgets/minik_ui.dart';
import '../search/search_index.dart';
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
  final _surahListKey = GlobalKey();
  final _surahSearch = TextEditingController();
  String _surahQuery = '';

  Future<_QuranHome> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    final store = context.read<LocalProgressStore>();
    return _QuranHome(
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
    _surahSearch.dispose();
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

  void _clearSurahSearch() {
    _surahSearch.clear();
    setState(() => _surahQuery = '');
  }

  List<Widget> _surahResults(List<SurahIndexItem> surahs) {
    final query = _surahQuery.trim();
    final ref = QuranRef.parse(query);
    final key = QuranRef.nameKey(query);
    final matches = ref != null
        ? surahs.where((s) => s.id == ref.surahId)
        : query.isEmpty
            ? surahs
            : surahs.where((s) =>
                '${s.id}' == key || QuranRef.nameKey(s.name).contains(key));
    final target = ref == null
        ? null
        : surahs.where((s) => s.id == ref.surahId).firstOrNull;
    return [
      if (target != null && ref!.ayahNo >= 1 && ref.ayahNo <= target.ayahCount)
        ContentTile(
          title: '${target.name} Sûresi, ${ref.ayahNo}. ayet',
          subtitle: 'Ayete git',
          leading: const Icon(Icons.my_location_rounded),
          onTap: () => _openMeal(surahId: target.id, ayahNo: ref.ayahNo),
        ),
      for (final surah in matches)
        ContentTile(
          title: surah.name,
          subtitle: '${surah.ayahCount} ayet',
          leading: NumberBadge('${surah.id}'),
          onTap: () => _openMeal(surahId: surah.id),
        ),
      if (matches.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            '“$query” ile eşleşen sure yok.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MinikColors.textMuted),
          ),
        ),
    ];
  }

  void _showSurahList() {
    final target = _surahListKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
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
            final mealColor = MinikColors.of(
                const Color(0xFFE8F0FA), const Color(0xFF1D2734));
            return ListView(
              padding: AppSpacing.page,
              children: [
                const PageHeader(
                  title: "Kur'an-ı Kerim",
                  subtitle: 'Nasıl okumak istersin?',
                ),
                const SectionLabel('Kaldığın yerden devam et'),
                _QuranResumeRow(
                  icon: Icons.menu_book_rounded,
                  iconColor: MinikColors.butter,
                  title: 'Mushafta devam et',
                  detail: mushaf == null
                      ? 'Henüz başlamadın · İlk sayfadan başla'
                      : '${TurkishNumber.pageLabel(mushaf.displayNumber)} · ${mushaf.surahLabel}',
                  onTap: () => _openMushaf(resume: mushaf != null),
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuranResumeRow(
                  icon: Icons.view_agenda_rounded,
                  iconColor: mealColor,
                  title: 'Ayet ve mealde devam et',
                  detail: meal == null
                      ? 'Henüz kayıt yok · Fâtiha\'dan başla'
                      : meal.label,
                  onTap: () => meal == null
                      ? _openMeal(surahId: 1)
                      : _openMeal(surahId: meal.surahId, ayahNo: meal.ayahNo),
                ),
                const SizedBox(height: AppSpacing.md),
                const SectionLabel('Okuma şekli seç'),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _QuranModeTile(
                          icon: Icons.menu_book_rounded,
                          color: MinikColors.butter,
                          title: 'Mushaf',
                          description:
                              "Arapça, sayfa sayfa oku. Basılı Kur'an gibi.",
                          onTap: () => _openMushaf(resume: false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuranModeTile(
                          icon: Icons.view_agenda_rounded,
                          color: mealColor,
                          title: 'Ayet ve Meal',
                          description:
                              'Her ayetin altında Türkçe anlamı. Aşağıdan sure seç.',
                          onTap: _showSurahList,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionLabel('Sureler', key: _surahListKey),
                TextField(
                  controller: _surahSearch,
                  onChanged: (value) => setState(() => _surahQuery = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Sure ara · ör. Furkan 69 ya da 25:69',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _surahQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Temizle',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _clearSurahSearch,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._surahResults(home.surahs),
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
    required this.surahs,
    this.mushafMark,
    this.mealMark,
  });

  final List<SurahIndexItem> surahs;
  final ({int jsonPage, int displayNumber, String surahLabel})? mushafMark;
  final ({int surahId, int ayahNo, String label})? mealMark;
}

class _QuranResumeRow extends StatelessWidget {
  const _QuranResumeRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return MinikCard(
      color: MinikColors.mint,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: MinikColors.green, size: 24),
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
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall?.copyWith(
                    color: MinikColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded,
              color: MinikColors.green, size: 32),
        ],
      ),
    );
  }
}

class _QuranModeTile extends StatelessWidget {
  const _QuranModeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return MinikCard(
      color: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MinikColors.green, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.titleMedium?.copyWith(color: MinikColors.darkGreen),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.bodySmall?.copyWith(color: MinikColors.textMuted),
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
  final _scroll = ScrollController();
  bool _didScrollToInitial = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _savedAyahNo = widget.initialAyahNo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<LocalProgressStore>();
      store.markCompleted('quran', '${widget.surahId}', xp: 2);
    });
  }

  /// The list is lazy, so a far ayah has no context until the viewport
  /// reaches it: jump a screen at a time towards it, then align precisely.
  Future<void> _scrollToAyah(int ayahNo) async {
    await WidgetsBinding.instance.endOfFrame;
    for (var i = 0; i < 400 && mounted && _scroll.hasClients; i++) {
      final ctx = _ayahKeys[ayahNo]?.currentContext;
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(ctx, alignment: 0.08);
        return;
      }
      final built = <int, double>{
        for (final e in _ayahKeys.entries)
          if (e.value.currentContext?.findRenderObject()
              case final RenderBox box when box.hasSize)
            e.key: box.size.height,
      };
      final position = _scroll.position;
      final double target;
      if (built.isEmpty) {
        target = position.pixels + position.viewportDimension;
      } else {
        final average =
            built.values.reduce((a, b) => a + b) / built.length + AppSpacing.sm;
        final first = built.keys.reduce(min);
        final last = built.keys.reduce(max);
        final gap = ayahNo > last ? ayahNo - last : ayahNo - first;
        target = position.pixels + gap * average;
      }
      final clamped =
          target.clamp(position.minScrollExtent, position.maxScrollExtent);
      if (clamped == position.pixels) return;
      _scroll.jumpTo(clamped);
      await WidgetsBinding.instance.endOfFrame;
    }
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
          '$label kaydedildi. Kur’an sayfasındaki “Ayet ve mealde devam et”ten dönebilirsin.',
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
            controller: _scroll,
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
                      quran: true,
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
