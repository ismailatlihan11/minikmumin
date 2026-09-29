import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/listen_button.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import 'dua_memorize_page.dart';

export '../../shared/widgets/listen_button.dart';

class MinikDuasPage extends StatefulWidget {
  const MinikDuasPage({super.key, this.prayerOnly = false});

  final bool prayerOnly;

  @override
  State<MinikDuasPage> createState() => _MinikDuasPageState();
}

class _MinikDuasPageState extends State<MinikDuasPage> {
  Future<List<DuaEntry>>? _future;

  Future<List<DuaEntry>> _load(ContentRepositories repos) async {
    if (widget.prayerOnly) {
      final list = await repos.duas.getPrayerDuas();
      return list.map(DuaEntry.fromPrayerDua).toList();
    }
    final catalog = await repos.duas.getCatalog();
    final categories = await repos.duas.getCategories();
    final rank = {
      for (final (index, category) in categories.indexed) category.title: index,
    };
    return [...catalog]..sort((a, b) {
        final byCategory = (rank[a.section] ?? categories.length)
            .compareTo(rank[b.section] ?? categories.length);
        return byCategory != 0 ? byCategory : a.order.compareTo(b.order);
      });
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= _load(repos);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<List<DuaEntry>>(
          future: _future!,
          onRetry: () => setState(() {
            _future = _load(repos);
          }),
          emptyTitle: 'Dua bulunamadı.',
          builder: (duas) => ListView(
            padding: AppSpacing.page,
            children: [
              PageHeader(
                title: widget.prayerOnly
                    ? 'Namazda okunan Ayetler ve Dualar'
                    : 'Dualar',
                subtitle: widget.prayerOnly
                    ? 'Namazda öğrenilecek ifadeler, sûreler ve dualar.'
                    : 'Günlük hayatta okuyabileceğin dualar.',
              ),
              for (final (index, dua) in duas.indexed) ...[
                if (!widget.prayerOnly &&
                    (index == 0 || duas[index - 1].section != dua.section))
                  Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                    child: SectionLabel(dua.section),
                  ),
                _DuaListTile(
                  dua: dua,
                  number: widget.prayerOnly ? dua.order : index + 1,
                  prayerOnly: widget.prayerOnly,
                  catalog: duas,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DuaListTile extends StatelessWidget {
  const _DuaListTile({
    required this.dua,
    required this.number,
    required this.prayerOnly,
    required this.catalog,
  });

  final DuaEntry dua;
  final int number;
  final bool prayerOnly;
  final List<DuaEntry> catalog;

  @override
  Widget build(BuildContext context) {
    final kind = prayerOnly ? 'prayer_dua' : 'dua';
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted(kind, dua.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: MinikColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x1421684E)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DuaDetailPage(
                    dua: dua,
                    kind: kind,
                    catalog: catalog,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: done
                                ? MinikColors.of(const Color(0xFFE7F4EC),
                                    const Color(0xFF233128))
                                : MinikColors.of(const Color(0xFFF3F6F8),
                                    const Color(0xFF21272A)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            number > 0 ? '$number' : '•',
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: done
                                  ? MinikColors.green
                                  : MinikColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dua.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: MinikColors.darkGreen,
                                ),
                              ),
                              if ((prayerOnly ? dua.section : dua.when)
                                  .isNotEmpty)
                                Text(
                                  prayerOnly ? dua.section : dua.when,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: MinikColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color:
                              done ? MinikColors.green : MinikColors.greenSoft,
                          size: 22,
                        ),
                      ],
                    ),
                    if (prayerOnly) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: _DuaQuickActions(
                          dua: dua,
                          kind: kind,
                          onRead: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DuaDetailPage(
                                dua: dua,
                                kind: kind,
                                catalog: catalog,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DuaDetailPage extends StatefulWidget {
  const DuaDetailPage({
    super.key,
    required this.dua,
    this.kind = 'dua',
    this.catalog = const [],
  });

  final DuaEntry dua;
  final String kind;
  final List<DuaEntry> catalog;

  @override
  State<DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<DuaDetailPage> {
  final AudioPlayerService _audio = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dua = widget.dua;
      context.read<LocalProgressStore>().setContinue(
            title: dua.title,
            subtitle: widget.kind == 'prayer_dua'
                ? 'Namazda okunan Ayetler ve Dualar'
                : 'Dualar',
            route: widget.kind == 'prayer_dua'
                ? AppRoutes.learnPrayerDuas
                : AppRoutes.learnDuas,
            progress: widget.catalog.isEmpty
                ? 0.4
                : ((_index + 1) / widget.catalog.length).clamp(0.05, 1),
          );
    });
  }

  int get _index {
    final i = widget.catalog.indexWhere((item) => item.id == widget.dua.id);
    return i;
  }

  DuaEntry? get _next {
    final i = _index;
    if (i < 0 || i + 1 >= widget.catalog.length) return null;
    return widget.catalog[i + 1];
  }

  void _openNext() {
    final next = _next;
    if (next == null) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DuaDetailPage(
          dua: next,
          kind: widget.kind,
          catalog: widget.catalog,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final audioPath = _duaAudioPath(dua, widget.kind);
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted(widget.kind, dua.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return Scaffold(
          backgroundColor: MinikColors.background,
          appBar: AppBar(
            title: Text(
              dua.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              CopyIconButton(text: _duaCopyText(dua)),
              FavoriteButton(
                kind: widget.kind,
                id: dua.id,
                title: dua.title,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _DuaDetailHeader(dua: dua),
                    const SizedBox(height: 14),
                    if (widget.kind == 'prayer_dua') ...[
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DuaMemorizePage(
                              dua: dua,
                              kind: widget.kind,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.psychology_alt_rounded),
                        label: const Text('Ezberle'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    DuaContentBlocks(dua: dua),
                  ],
                ),
              ),
              _DuaStickyBar(
                audio: _audio,
                path: audioPath,
                learned: done,
                onLearned: done
                    ? null
                    : () => store.markCompleted(widget.kind, dua.id, xp: 5),
                onNext: _next == null ? null : _openNext,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DuaDetailHeader extends StatelessWidget {
  const _DuaDetailHeader({required this.dua});

  final DuaEntry dua;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: MinikColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1421684E)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MinikImage.asset(
              dua.displayImage,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.menu_book_rounded, color: MinikColors.green),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                    height: 1.15,
                  ),
                ),
                if (dua.section.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dua.section,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MinikColors.textMuted,
                    ),
                  ),
                ],
                if (dua.reference.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dua.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MinikColors.greenSoft,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DuaContentBlocks extends StatelessWidget {
  const DuaContentBlocks({
    super.key,
    required this.dua,
    this.arabicFontSize = 28,
  });

  final DuaEntry dua;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final timing = [
      if (dua.when.isNotEmpty) dua.when,
      if (dua.repeat > 1) '${dua.repeat} kez okunur.',
    ].join('\n');
    final parts = <Widget>[
      if (timing.isNotEmpty)
        DuaPartCard(
          label: 'Ne zaman okunur?',
          color: MinikColors.lavender,
          accent: MinikColors.darkGreen,
          text: timing,
        ),
      if (dua.fullArabic.isNotEmpty)
        DuaPartCard(
          label: 'Arapça',
          color: MinikColors.mint,
          accent: MinikColors.greenSoft,
          arabic: dua.fullArabic,
          arabicFontSize: arabicFontSize,
        ),
      if (dua.fullReading.isNotEmpty)
        DuaPartCard(
          label: 'Okunuşu',
          color: MinikColors.butter,
          accent: MinikColors.gold,
          text: dua.fullReading,
        ),
      if (dua.fullMeaning.isNotEmpty)
        DuaPartCard(
          label: 'Meali',
          color: MinikColors.sky,
          accent: MinikColors.teal,
          text: dua.fullMeaning,
        ),
      for (final response in dua.responses)
        DuaPartCard(
          label: response.label,
          color: MinikColors.peach,
          accent: MinikColors.gold,
          arabic: response.arabic,
          arabicFontSize: arabicFontSize - 4,
          text: [
            response.transliteration,
            response.meaning,
          ].where((line) => line.trim().isNotEmpty).join('\n'),
        ),
      if (dua.note.isNotEmpty)
        DuaPartCard(
          label: 'Not',
          color: MinikColors.creamDark,
          accent: MinikColors.textMuted,
          text: dua.note,
        ),
    ];
    return Column(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          parts[i],
        ],
      ],
    );
  }
}

class DuaPartCard extends StatelessWidget {
  const DuaPartCard({
    super.key,
    required this.label,
    required this.color,
    required this.accent,
    this.arabic = '',
    this.text = '',
    this.arabicFontSize = 26,
  });

  final String label;
  final Color color;
  final Color accent;
  final String arabic;
  final String text;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final hasArabic = arabic.trim().isNotEmpty;
    final hasText = text.trim().isNotEmpty;
    if (!hasArabic && !hasText) return const SizedBox.shrink();
    final textBody = SelectableText(
      text,
      style: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w600,
        color: MinikColors.darkGreen,
      ),
    );
    final Widget body;
    if (hasArabic && hasText) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArabicText(arabic, fontSize: arabicFontSize),
          const SizedBox(height: 8),
          textBody,
        ],
      );
    } else {
      body = hasArabic ? ArabicText(arabic, fontSize: arabicFontSize) : textBody;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _DuaStickyBar extends StatelessWidget {
  const _DuaStickyBar({
    required this.audio,
    required this.path,
    required this.learned,
    required this.onLearned,
    this.onNext,
  });

  final AudioPlayerService audio;
  final String path;
  final bool learned;
  final VoidCallback? onLearned;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MinikColors.surface,
      elevation: 6,
      shadowColor: const Color(0x14000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (AssetCatalog.contains(path)) ...[
                SizedBox(
                  width: double.infinity,
                  child: ListenButton(audio: audio, path: path),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLearned,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: MinikColors.green,
                        side: BorderSide(
                          color: MinikColors.green,
                          width: 1.4,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(learned ? '✓ Öğrendin' : 'Öğrendim'),
                    ),
                  ),
                  if (onNext != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: MinikColors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(44),
                          textStyle: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Sonraki dua'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Günlük dualar are text-only; only namaz duaları fall back to bundled audio.
String _duaAudioPath(DuaEntry dua, String kind) {
  if (dua.audio.isNotEmpty) return dua.audio;
  if (kind != 'prayer_dua') return '';
  return ContentAssets.audioFor(dua.id);
}

String _duaCopyText(DuaEntry dua) {
  return joinCopyParts([
    dua.title,
    dua.fullArabic,
    dua.fullReading,
    dua.fullMeaning,
    dua.reference,
  ]);
}

class _DuaQuickActions extends StatefulWidget {
  const _DuaQuickActions({
    required this.dua,
    required this.kind,
    required this.onRead,
  });

  final DuaEntry dua;
  final String kind;
  final VoidCallback onRead;

  @override
  State<_DuaQuickActions> createState() => _DuaQuickActionsState();
}

class _DuaQuickActionsState extends State<_DuaQuickActions> {
  final _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = _duaAudioPath(widget.dua, widget.kind);
    final hasAudio = AssetCatalog.contains(path);
    return Row(
      children: [
        _TinyAction(
          icon: Icons.menu_book_rounded,
          label: 'Oku',
          onTap: widget.onRead,
        ),
        const SizedBox(width: 6),
        _TinyAction(
          icon: Icons.psychology_alt_rounded,
          label: 'Ezberle',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuaMemorizePage(
                dua: widget.dua,
                kind: widget.kind,
              ),
            ),
          ),
        ),
        if (hasAudio) ...[
          const SizedBox(width: 6),
          StreamBuilder<bool>(
            stream: _audio.playingStream,
            initialData: _audio.isPlaying,
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return _TinyAction(
                icon: playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                label: playing ? 'Durdur' : 'Dinle',
                onTap: () => _audio.toggleAsset(path),
                emphasized: true,
              );
            },
          ),
        ],
        const Spacer(),
        FavoriteButton(
          kind: widget.kind,
          id: widget.dua.id,
          title: widget.dua.title,
        ),
      ],
    );
  }
}

class _TinyAction extends StatelessWidget {
  const _TinyAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: emphasized
          ? MinikColors.mint
          : MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A)),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 16, color: MinikColors.green),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
