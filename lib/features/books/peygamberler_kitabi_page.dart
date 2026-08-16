import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/peygamberler_kitabi.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../shared/widgets/minik_ui.dart';

class PeygamberlerKitabiPage extends StatefulWidget {
  const PeygamberlerKitabiPage({super.key});

  @override
  State<PeygamberlerKitabiPage> createState() => _PeygamberlerKitabiPageState();
}

class _PeygamberlerKitabiPageState extends State<PeygamberlerKitabiPage> {
  int? _bookmark;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final page = await context.read<LocalProgressStore>().getBookBookmark(
          PeygamberlerKitabi.id,
        );
    if (!mounted) return;
    setState(() => _bookmark = page);
  }

  Future<void> _open({required int page}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeygamberlerKitabiReaderPage(initialPage: page),
      ),
    );
    if (!mounted) return;
    await _loadBookmark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peygamberler Kitabı')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Image.asset(
                PeygamberlerKitabi.cover,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            PeygamberlerKitabi.title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${PeygamberlerKitabi.author}\nResimleyen: ${PeygamberlerKitabi.illustrator}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${PeygamberlerKitabi.publisher}, ${PeygamberlerKitabi.year}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () => _open(page: PeygamberlerKitabi.firstContentPage),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Okumaya başla'),
          ),
          if (_bookmark != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _open(page: _bookmark!),
              icon: const Icon(Icons.bookmark_rounded),
              label: Text(
                'Kaldığın yerden devam et · ${TurkishNumber.pageLabel(_bookmark!)}',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('İçindekiler'),
          for (final chapter in PeygamberlerKitabi.chapters)
            ContentTile(
              title: chapter.title,
              subtitle: TurkishNumber.pageLabel(chapter.page),
              leading: NumberBadge('${chapter.page}'),
              onTap: () => _open(page: chapter.page),
            ),
        ],
      ),
    );
  }
}

class PeygamberlerKitabiReaderPage extends StatefulWidget {
  const PeygamberlerKitabiReaderPage({
    super.key,
    this.initialPage = PeygamberlerKitabi.firstContentPage,
    this.resume = false,
  });

  final int initialPage;
  final bool resume;

  @override
  State<PeygamberlerKitabiReaderPage> createState() =>
      _PeygamberlerKitabiReaderPageState();
}

class _PeygamberlerKitabiReaderPageState
    extends State<PeygamberlerKitabiReaderPage> {
  PageController? _controller;
  int _page = PeygamberlerKitabi.firstContentPage;
  bool _savedHere = false;
  bool _ready = false;

  int get _contentCount =>
      PeygamberlerKitabi.pageCount - PeygamberlerKitabi.firstContentPage + 1;

  int _toIndex(int page) => page - PeygamberlerKitabi.firstContentPage;

  int _toPage(int index) => index + PeygamberlerKitabi.firstContentPage;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    var start = widget.initialPage.clamp(
      PeygamberlerKitabi.firstContentPage,
      PeygamberlerKitabi.pageCount,
    );
    if (widget.resume) {
      final mark = await context.read<LocalProgressStore>().getBookBookmark(
            PeygamberlerKitabi.id,
          );
      if (mark != null) {
        start = mark.clamp(
          PeygamberlerKitabi.firstContentPage,
          PeygamberlerKitabi.pageCount,
        );
      }
    }
    _controller = PageController(initialPage: _toIndex(start));
    if (!mounted) return;
    setState(() {
      _page = start;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _saveHere() async {
    await context.read<LocalProgressStore>().setBookBookmark(
          bookId: PeygamberlerKitabi.id,
          page: _page,
          title: PeygamberlerKitabi.title,
          totalPages: PeygamberlerKitabi.pageCount,
        );
    if (!mounted) return;
    setState(() => _savedHere = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${TurkishNumber.pageLabel(_page)} kaydedildi. Sonra buradan devam ederiz.',
        ),
      ),
    );
  }

  void _go(int delta) {
    if (_controller == null) return;
    final next = (_toIndex(_page) + delta).clamp(0, _contentCount - 1);
    _controller!.animateToPage(
      next,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showContents() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('İçindekiler')),
            for (final chapter in PeygamberlerKitabi.chapters)
              ListTile(
                title: Text(chapter.title),
                trailing: Text(TurkishNumber.pageLabel(chapter.page)),
                onTap: () => Navigator.pop(context, chapter.page),
              ),
          ],
        ),
      ),
    );
    if (selected == null || _controller == null) return;
    _controller!.jumpToPage(_toIndex(selected));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEDC),
      appBar: AppBar(
        title: Text(TurkishNumber.pageLabel(_page)),
        actions: [
          IconButton(
            tooltip: 'İçindekiler',
            onPressed: _showContents,
            icon: const Icon(Icons.list_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _contentCount,
              onPageChanged: (index) => setState(() {
                _page = _toPage(index);
                _savedHere = false;
              }),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.asset(
                        PeygamberlerKitabi.pageImage(_toPage(index)),
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                );
              },
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
                      onPressed: _page <= PeygamberlerKitabi.firstContentPage
                          ? null
                          : () => _go(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saveHere,
                        icon: Icon(
                          _savedHere
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                        ),
                        label: Text(_savedHere ? 'Kaydedildi' : 'Burada kaldım'),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sonraki sayfa',
                      onPressed: _page >= PeygamberlerKitabi.pageCount
                          ? null
                          : () => _go(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
