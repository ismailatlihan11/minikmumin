import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import 'mushaf_decor.dart';
import 'mushaf_reading.dart';

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
  double _fontSize = LocalProgressStore.mushafFontDefault;
  bool _fingerFollow = false;
  int? _followAyahId;

  Future<List<MushafPageData>> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    final store = context.read<LocalProgressStore>();
    final pages = await quran.getMushafPages();
    final font = await store.getMushafFontSize();
    final follow = await store.getMushafFingerFollow();
    var start = 0;
    if (widget.initialJsonPage != null) {
      start =
          pages.indexWhere((page) => page.jsonPage == widget.initialJsonPage);
    } else if (widget.resume) {
      final mark = await store.getMushafBookmark();
      if (mark != null) {
        start = pages.indexWhere((page) => page.jsonPage == mark);
      }
    }
    if (start < 0) start = 0;
    _controller?.dispose();
    _controller = PageController(initialPage: start);
    _pages = pages;
    _index = start;
    _fontSize = font;
    _fingerFollow = follow;
    if (follow) _followAyahOnPage(pages[start]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _rememberLastPage());
    return pages;
  }

  Future<void> _rememberLastPage() async {
    if (_pages.isEmpty || !mounted) return;
    final page = _pages[_index];
    final store = context.read<LocalProgressStore>();
    await store.rememberMushafPage(
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

  void _followAyahOnPage(MushafPageData page) {
    if (page.verses.isEmpty) {
      _followAyahId = null;
      return;
    }
    if (_followAyahId != null &&
        page.verses.any((verse) => verse.ayahId == _followAyahId)) {
      return;
    }
    _followAyahId = page.verses.first.ayahId;
  }

  Future<void> _saveHere() async {
    if (_pages.isEmpty) return;
    final page = _pages[_index];
    final store = context.read<LocalProgressStore>();
    await store.setMushafBookmark(
      jsonPage: page.jsonPage,
      displayNumber: page.jsonPage,
      surahLabel: _surahLabel(page),
      totalPages: _pages.last.jsonPage <= 0 ? 1 : _pages.last.jsonPage,
    );
    if (!mounted) return;
    setState(() => _savedHere = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kMushafGreen,
        content: Text(
          '${TurkishNumber.pageLabel(page.jsonPage)} kaydedildi. Kur’an sayfasındaki “Mushafta devam et”ten dönebilirsin.',
        ),
      ),
    );
  }

  void _goToJsonPage(int jsonPage) {
    if (_pages.isEmpty) return;
    var next = _pages.indexWhere((page) => page.jsonPage == jsonPage);
    if (next < 0) {
      next = _pages.indexWhere((page) => page.jsonPage >= jsonPage);
      if (next < 0) next = _pages.length - 1;
    }
    _controller?.jumpToPage(next);
    setState(() {
      _index = next;
      _savedHere = false;
      if (_fingerFollow) _followAyahOnPage(_pages[next]);
    });
    _rememberLastPage();
  }

  Future<void> _jumpToPage() async {
    if (_pages.isEmpty) return;
    final first = _pages.first.jsonPage;
    final last = _pages.last.jsonPage;
    final controller =
        TextEditingController(text: '${_pages[_index].jsonPage}');
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinikColors.nightSurface,
        title: const Text(
          'Sayfaya git',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Sayfa numarası',
            hintText: '$first – $last',
            labelStyle: const TextStyle(color: Color(0xFFD4C4A0)),
            hintStyle: const TextStyle(color: Color(0xFFD4C4A0)),
          ),
          onSubmitted: (value) =>
              Navigator.pop(context, int.tryParse(value.trim())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç', style: TextStyle(color: kMushafGold)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: const Text('Git', style: TextStyle(color: kMushafGold)),
          ),
        ],
      ),
    );
    controller.dispose();
    if (selected == null || !mounted) return;
    _goToJsonPage(selected);
  }

  Future<void> _jumpToJuz() async {
    if (_pages.isEmpty) return;
    final last = _pages.last.jsonPage;
    final currentJuz = _pages[_index].juzNumber;
    final range = mushafPageRangeForJuz(currentJuz, lastPage: last);
    final controller = TextEditingController(text: '${range.$1}-${range.$2}');
    final selected = await showDialog<int>(
      context: context,
      builder: (context) {
        const labelStyle = TextStyle(color: Color(0xFFD4C4A0));
        return AlertDialog(
          backgroundColor: MinikColors.nightSurface,
          title: const Text(
            'Cüze git',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: (MediaQuery.sizeOf(context).height * 0.55).clamp(280, 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Cüz veya sayfa aralığı',
                    hintText: '1–30 veya 0–20',
                    labelStyle: labelStyle,
                    hintStyle: labelStyle,
                  ),
                  onSubmitted: (value) =>
                      Navigator.pop(context, mushafJuzFromInput(value)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cüz 1 sayfaları 0–20’dir. Aralık da yazabilirsin.',
                  style: TextStyle(color: Color(0xFFD4C4A0), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final juz = index + 1;
                      final pages = mushafPageRangeForJuz(juz, lastPage: last);
                      final selectedJuz = juz == currentJuz;
                      return ListTile(
                        dense: true,
                        selected: selectedJuz,
                        selectedTileColor: kMushafGold.withValues(alpha: 0.16),
                        title: Text(
                          'Cüz $juz',
                          style: TextStyle(
                            color: selectedJuz ? kMushafGold : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${pages.$1}–${pages.$2}',
                          style: const TextStyle(color: Color(0xFFD4C4A0)),
                        ),
                        onTap: () => Navigator.pop(context, juz),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç', style: TextStyle(color: kMushafGold)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                mushafJuzFromInput(controller.text),
              ),
              child: const Text('Git', style: TextStyle(color: kMushafGold)),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (selected == null || !mounted) return;
    _goToJsonPage(mushafFirstPageForJuz(selected));
  }

  void _go(int delta) {
    if (_pages.isEmpty || _controller == null) return;
    final next = (_index + delta).clamp(0, _pages.length - 1);
    if (next == _index) return;
    _controller!.animateToPage(
      next,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _showReadingOptions() {
    showMushafReadingSheet(
      context: context,
      store: context.read<LocalProgressStore>(),
      fontSize: _fontSize,
      fingerFollow: _fingerFollow,
      onChanged: (font, follow) {
        setState(() {
          _fontSize = font;
          _fingerFollow = follow;
          if (follow && _pages.isNotEmpty) {
            _followAyahOnPage(_pages[_index]);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      backgroundColor: kMushafNight,
      appBar: AppBar(
        backgroundColor: kMushafNight,
        foregroundColor: kMushafGold,
        title: Text(
          _pages.isEmpty
              ? 'Mushaf'
              : 'Sayfa ${_pages[_index].jsonPage} / ${_pages.last.jsonPage}',
          style:
              const TextStyle(color: kMushafGold, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Yazı ve takip',
            onPressed: _showReadingOptions,
            icon: const Icon(Icons.text_fields_rounded, color: kMushafGold),
          ),
          IconButton(
            tooltip: _savedHere ? 'Kaydedildi' : 'Burada kaldım',
            onPressed: _saveHere,
            icon: Icon(
              _savedHere ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              color: kMushafGold,
            ),
          ),
          TextButton(
            onPressed: _jumpToJuz,
            style: TextButton.styleFrom(
              foregroundColor: kMushafGold,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Cüz',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          IconButton(
            tooltip: 'Sayfaya git',
            onPressed: _jumpToPage,
            icon: const Icon(Icons.numbers_rounded, color: kMushafGold),
          ),
        ],
      ),
      body: AsyncBody<List<MushafPageData>>(
        future: _future!,
        onRetry: () => setState(() {
          _future = _load();
        }),
        builder: (pages) {
          final last = pages.last.jsonPage.toDouble().clamp(1.0, 9999.0);
          final current = pages[_index].jsonPage.toDouble().clamp(0.0, last);
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  reverse: true,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _index = index;
                      _savedHere = false;
                      if (_fingerFollow) _followAyahOnPage(pages[index]);
                    });
                    _rememberLastPage();
                  },
                  itemBuilder: (context, index) => _MushafLeaf(
                    page: pages[index],
                    fontSize: _fontSize,
                    followEnabled: _fingerFollow,
                    selectedAyahId: _followAyahId,
                    onSelectAyah: (id) => setState(() => _followAyahId = id),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: kMushafGold,
                          inactiveTrackColor:
                              kMushafGold.withValues(alpha: 0.25),
                          thumbColor: kMushafGold,
                        ),
                        child: Slider(
                          value: current,
                          min: 0,
                          max: last <= 0 ? 1.0 : last,
                          onChanged: (value) {
                            var next = pages.indexWhere(
                              (page) => page.jsonPage == value.round(),
                            );
                            if (next < 0) {
                              next = pages.indexWhere(
                                (page) => page.jsonPage >= value.round(),
                              );
                              if (next < 0) next = pages.length - 1;
                            }
                            _controller?.jumpToPage(next);
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Önceki sayfa',
                            onPressed: _index == 0 ? null : () => _go(-1),
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: kMushafGold,
                            ),
                          ),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveHere,
                              style: FilledButton.styleFrom(
                                backgroundColor: kMushafGreen,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 44),
                              ),
                              icon: Icon(
                                _savedHere
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                              ),
                              label: Text(
                                _savedHere ? 'Kaydedildi' : 'Burada kaldım',
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sonraki sayfa',
                            onPressed: _index >= pages.length - 1
                                ? null
                                : () => _go(1),
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: kMushafGold,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _MushafLeaf extends StatelessWidget {
  const _MushafLeaf({
    required this.page,
    required this.fontSize,
    required this.followEnabled,
    required this.selectedAyahId,
    required this.onSelectAyah,
  });

  final MushafPageData page;
  final double fontSize;
  final bool followEnabled;
  final int? selectedAyahId;
  final ValueChanged<int> onSelectAyah;

  @override
  Widget build(BuildContext context) {
    if (page.verses.isEmpty) {
      return const Center(
        child: Text(
          'Bu sayfa boş.',
          style: TextStyle(color: Color(0xFFD4C4A0)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: MushafPageChrome(
          child: Column(
            children: [
              _PageHeader(page: page),
              Expanded(child: _buildContent()),
              _PageFooter(pageNumber: page.jsonPage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final sections = <Widget>[];
    var prevSurah = 0;
    final current = <QuranVerse>[];

    void flush() {
      if (current.isEmpty) return;
      sections.add(
        _AyahFlowBlock(
          verses: List<QuranVerse>.from(current),
          fontSize: fontSize,
          followEnabled: followEnabled,
          selectedAyahId: selectedAyahId,
          onSelectAyah: onSelectAyah,
        ),
      );
      current.clear();
    }

    for (final verse in page.verses) {
      if (verse.surahId != prevSurah) {
        flush();
        if (verse.ayahNo == 1) {
          sections.add(_SurahHeader(surahId: verse.surahId));
        }
        prevSurah = verse.surahId;
      }
      current.add(verse);
    }
    flush();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sections,
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.page});

  final MushafPageData page;

  @override
  Widget build(BuildContext context) {
    final juz = page.juzNumber;
    final surah =
        page.verses.isEmpty ? '' : surahName(page.verses.first.surahId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              surah,
              style: const TextStyle(
                color: Color(0xFF5C3A1E),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Cüz $juz',
            style: const TextStyle(
              color: Color(0xFF5C3A1E),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter({required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❧', style: TextStyle(color: kMushafGoldDeep)),
          const SizedBox(width: 12),
          Text(
            '$pageNumber',
            style: const TextStyle(
              color: Color(0xFF5C3A1E),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          const Text('❧', style: TextStyle(color: kMushafGoldDeep)),
        ],
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surahId});

  final int surahId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 8),
          MushafSurahUnwan(
            arabicName: surahArabicName(surahId),
            turkishName: surahName(surahId),
          ),
          if (surahId != 1 && surahId != 9) const MushafBismillahBanner(),
        ],
      ),
    );
  }
}

class _AyahFlowBlock extends StatefulWidget {
  const _AyahFlowBlock({
    required this.verses,
    required this.fontSize,
    required this.followEnabled,
    required this.selectedAyahId,
    required this.onSelectAyah,
  });

  final List<QuranVerse> verses;
  final double fontSize;
  final bool followEnabled;
  final int? selectedAyahId;
  final ValueChanged<int> onSelectAyah;

  @override
  State<_AyahFlowBlock> createState() => _AyahFlowBlockState();
}

class _AyahFlowBlockState extends State<_AyahFlowBlock> {
  final GlobalKey _textKey = GlobalKey();

  String _ayahMark(int n) => ' ﴿${TurkishNumber.arabicIndic(n)}﴾ ';

  void _pickAt(Offset global) {
    if (!widget.followEnabled) return;
    final box = _textKey.currentContext?.findRenderObject();
    if (box is! RenderParagraph) return;
    final local = box.globalToLocal(global);
    final pos = box.getPositionForOffset(local).offset;
    var cursor = 0;
    for (final verse in widget.verses) {
      final len = verse.arabic.length + _ayahMark(verse.ayahNo).length;
      if (pos >= cursor && pos < cursor + len) {
        if (verse.ayahId != widget.selectedAyahId) {
          widget.onSelectAyah(verse.ayahId);
        }
        return;
      }
      cursor += len;
    }
    if (widget.verses.isEmpty) return;
    if (pos <= 0) {
      widget.onSelectAyah(widget.verses.first.ayahId);
    } else {
      widget.onSelectAyah(widget.verses.last.ayahId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final highlight = Paint()..color = const Color(0x66C8A96E);

    for (final verse in widget.verses) {
      final selected =
          widget.followEnabled && verse.ayahId == widget.selectedAyahId;
      final ink = verse.isSajdahAyah ? kMushafSajdahRed : kMushafInk;
      final markColor =
          verse.isSajdahAyah ? kMushafSajdahRed : const Color(0xFF8B4513);
      spans.add(
        TextSpan(
          text: verse.arabic,
          style: TextStyle(
            color: ink,
            fontSize: widget.fontSize,
            fontFamily: AssetPaths.arabicFontFamily,
            height: 2.2,
            background: selected ? highlight : null,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: _ayahMark(verse.ayahNo),
          style: TextStyle(
            color: markColor,
            fontSize: widget.fontSize - 4,
            fontFamily: AssetPaths.arabicFontFamily,
            height: 2.2,
            background: selected ? highlight : null,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.followEnabled ? (e) => _pickAt(e.position) : null,
        onPointerMove: widget.followEnabled ? (e) => _pickAt(e.position) : null,
        child: RichText(
          key: _textKey,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
          text: TextSpan(children: spans),
        ),
      ),
    );
  }
}
