import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import 'mushaf_decor.dart';
import 'mushaf_reading.dart';
import '../../core/utils/quran_font.dart';

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
                  itemBuilder: (context, index) => _FlipLeaf(
                    controller: _controller!,
                    index: index,
                    child: _MushafLeaf(
                      page: pages[index],
                      fontSize: _fontSize,
                      followEnabled: _fingerFollow,
                      selectedAyahId: _followAyahId,
                      onSelectAyah: (id) => setState(() => _followAyahId = id),
                    ),
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

class _FlipLeaf extends StatelessWidget {
  const _FlipLeaf({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        var delta = 0.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? index.toDouble()) - index;
        }
        final t = delta.clamp(-1.0, 1.0);
        final p = t.abs();
        // Cilt sağda: sayfa sola kayıp hafif kalkar.
        return Transform.translate(
          offset: Offset(22.0 * t, -10.0 * p),
          child: Transform.rotate(
            angle: t * 0.05,
            alignment: Alignment.centerRight,
            child: Transform.scale(
              scale: 1.0 - 0.02 * p,
              alignment: Alignment.centerRight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  if (p > 0.02)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            stops: const [0, 0.16, 0.7, 1],
                            colors: [
                              Colors.black.withValues(alpha: 0.26 * p),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2 * p),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      child: child,
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
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kMushafPage,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kMushafPageBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
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
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
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
    const style = TextStyle(
      color: kMushafPageLabel,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          Expanded(child: Text(surah, style: style)),
          Text('Cüz $juz', style: style),
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
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          const Expanded(child: _FooterRule()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$pageNumber',
              style: const TextStyle(
                color: kMushafPageLabel,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Expanded(child: _FooterRule()),
        ],
      ),
    );
  }
}

class _FooterRule extends StatelessWidget {
  const _FooterRule();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'ـ ✦ ـ ✦ ـ',
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: TextStyle(
        color: Color(0xFFB9A57A),
        fontSize: 9,
        letterSpacing: 1,
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
  final _textKey = GlobalKey();

  /// Each ayah's end offset in the joined paragraph text.
  List<int> _ends = const [];

  void _pickAt(Offset global) {
    if (!widget.followEnabled) return;
    final paragraph = _textKey.currentContext?.findRenderObject();
    if (paragraph is! RenderParagraph || !paragraph.hasSize) return;
    final local = paragraph.globalToLocal(global);
    if (local.dy < 0 || local.dy > paragraph.size.height) return;
    final offset = paragraph.getPositionForOffset(local).offset;
    for (var i = 0; i < _ends.length; i++) {
      if (offset <= _ends[i]) {
        final id = widget.verses[i].ayahId;
        if (id != widget.selectedAyahId) widget.onSelectAyah(id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final ends = <int>[];
    var length = 0;
    for (var i = 0; i < widget.verses.length; i++) {
      final verse = widget.verses[i];
      if (i > 0) {
        spans.add(const TextSpan(text: ' '));
        length += 1;
      }
      final piece =
          '${verse.arabic} \uFD3F${TurkishNumber.arabicIndic(verse.ayahNo)}\uFD3E';
      final selected =
          widget.followEnabled && verse.ayahId == widget.selectedAyahId;
      spans.add(TextSpan(
        text: piece,
        style: TextStyle(
          color: verse.isSajdahAyah ? kMushafSajdahRed : null,
          backgroundColor: selected ? const Color(0x66C8A96E) : null,
        ),
      ));
      length += piece.length;
      ends.add(length);
    }
    _ends = ends;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: widget.followEnabled ? (e) => _pickAt(e.position) : null,
        onPointerMove: widget.followEnabled ? (e) => _pickAt(e.position) : null,
        child: RichText(
          key: _textKey,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          textScaler: MediaQuery.textScalerOf(context),
          text: TextSpan(
            style: TextStyle(
              color: kMushafInk,
              fontSize: widget.fontSize,
              fontFamily: QuranFont.family,
              fontFamilyFallback: QuranFont.fallback,
              height: 2.05,
            ),
            children: spans,
          ),
        ),
      ),
    );
  }
}
