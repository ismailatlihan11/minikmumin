import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';

class MushafReaderPage extends StatefulWidget {
  const MushafReaderPage({
    super.key,
    this.resume = false,
    this.initialJsonPage,
  });

  final bool resume;
  final int? initialJsonPage;

  @override
  State<MushafReaderPage> createState() => _MushafReaderPageState();
}

class _MushafReaderPageState extends State<MushafReaderPage> {
  Future<List<MushafPageData>>? _future;
  PageController? _controller;
  int _index = 0;
  List<MushafPageData> _pages = const [];
  bool _savedHere = false;

  Future<List<MushafPageData>> _load() async {
    final pages = await context.read<ContentRepositories>().quran.getMushafPages();
    var start = 0;
    if (widget.initialJsonPage != null) {
      start = pages.indexWhere((page) => page.jsonPage == widget.initialJsonPage);
    } else if (widget.resume) {
      final mark = await context.read<LocalProgressStore>().getMushafBookmark();
      if (mark != null) {
        start = pages.indexWhere((page) => page.jsonPage == mark);
      }
    }
    if (start < 0) start = 0;
    _controller?.dispose();
    _controller = PageController(initialPage: start);
    _pages = pages;
    _index = start;
    WidgetsBinding.instance.addPostFrameCallback((_) => _rememberLastPage());
    return pages;
  }

  Future<void> _rememberLastPage() async {
    if (_pages.isEmpty || !mounted) return;
    final page = _pages[_index];
    await context.read<LocalProgressStore>().rememberMushafPage(
          jsonPage: page.jsonPage,
          displayNumber: page.jsonPage,
          surahLabel: _surahLabel(page),
        );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _surahLabel(MushafPageData page) {
    return page.surahIds.map(surahName).join(' · ');
  }

  Future<void> _saveHere() async {
    if (_pages.isEmpty) return;
    final page = _pages[_index];
    await context.read<LocalProgressStore>().setMushafBookmark(
          jsonPage: page.jsonPage,
          displayNumber: page.jsonPage,
          surahLabel: _surahLabel(page),
          totalPages: _pages.last.jsonPage <= 0 ? 1 : _pages.last.jsonPage,
        );
    if (!mounted) return;
    setState(() => _savedHere = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${TurkishNumber.pageLabel(page.jsonPage)} kaydedildi. Sonra buradan devam ederiz.',
        ),
      ),
    );
  }

  Future<void> _jumpToPage() async {
    if (_pages.isEmpty) return;
    final first = _pages.first.jsonPage;
    final last = _pages.last.jsonPage;
    final controller = TextEditingController(text: '${_pages[_index].jsonPage}');
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayfaya git'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Sayfa numarası',
            hintText: '$first – $last',
          ),
          onSubmitted: (value) => Navigator.pop(context, int.tryParse(value.trim())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Git'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (selected == null || !mounted) return;
    var next = _pages.indexWhere((page) => page.jsonPage == selected);
    if (next < 0) {
      next = _pages.indexWhere((page) => page.jsonPage >= selected);
      if (next < 0) next = _pages.length - 1;
    }
    _controller?.jumpToPage(next);
    setState(() {
      _index = next;
      _savedHere = false;
    });
    _rememberLastPage();
  }

  void _go(int delta) {
    if (_pages.isEmpty || _controller == null) return;
    final next = (_index + delta).clamp(0, _pages.length - 1);
    if (next == _index) return;
    _controller!.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDC),
      appBar: AppBar(
        title: const Text('Mushaf'),
        actions: [
          IconButton(
            tooltip: 'Sayfaya git',
            onPressed: _jumpToPage,
            icon: const Icon(Icons.numbers_rounded),
          ),
        ],
      ),
      body: AsyncBody<List<MushafPageData>>(
        future: _future!,
        onRetry: () => setState(() => _future = _load()),
        builder: (pages) {
          final page = pages[_index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _MushafPageHeader(
                  displayNumber: page.jsonPage,
                  lastJsonPage: pages.last.jsonPage,
                  surahLabel: _surahLabel(page),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _index = index;
                      _savedHere = false;
                    });
                    _rememberLastPage();
                  },
                  itemBuilder: (context, index) => _MushafLeaf(
                    page: pages[index],
                  ),
                ),
              ),
              Material(
                color: MinikColors.surface,
                elevation: 8,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Önceki sayfa',
                          onPressed: _index == 0 ? null : () => _go(-1),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saveHere,
                            icon: Icon(
                              _savedHere ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            ),
                            label: Text(_savedHere ? 'Kaydedildi' : 'Burada kaldım'),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sonraki sayfa',
                          onPressed: _index >= pages.length - 1 ? null : () => _go(1),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
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

class _MushafPageHeader extends StatelessWidget {
  const _MushafPageHeader({
    required this.displayNumber,
    required this.lastJsonPage,
    required this.surahLabel,
  });

  final int displayNumber;
  final int lastJsonPage;
  final String surahLabel;

  @override
  Widget build(BuildContext context) {
    return MinikCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TurkishNumber.pageLabel(displayNumber),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${TurkishNumber.words(displayNumber)} · $surahLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TurkishNumber.arabicIndic(displayNumber),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 22,
                  color: MinikColors.green,
                  height: 1.1,
                ),
              ),
              Text(
                '$displayNumber / $lastJsonPage',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MushafLeaf extends StatelessWidget {
  const _MushafLeaf({required this.page});

  final MushafPageData page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFE4D4A8)),
        ),
        child: _arabicFlow(),
      ),
    );
  }

  Widget _arabicFlow() {
    final spans = <InlineSpan>[];
    var lastSurah = 0;
    for (final verse in page.verses) {
      if (verse.ayahNo == 1 && verse.surahId != lastSurah) {
        lastSurah = verse.surahId;
        spans.add(
          TextSpan(
            text: '\n\u202A${surahName(verse.surahId)}\u202C\n',
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.gold,
              height: 1.8,
            ),
          ),
        );
      }
      spans.add(TextSpan(text: '${verse.arabic} '));
      spans.add(
        TextSpan(
          text: '﴿${TurkishNumber.arabicIndic(verse.ayahNo)}﴾ ',
          style: const TextStyle(
            fontSize: 16,
            color: MinikColors.gold,
            height: 1.9,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: SelectableText.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: AssetPaths.arabicFontFamily,
          fontSize: 26,
          height: 2.05,
          color: MinikColors.darkGreen,
        ),
      ),
    );
  }
}

