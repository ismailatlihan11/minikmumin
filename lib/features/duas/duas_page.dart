import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikDuasPage extends StatefulWidget {
  const MinikDuasPage({super.key, this.prayerOnly = false});

  final bool prayerOnly;

  @override
  State<MinikDuasPage> createState() => _MinikDuasPageState();
}

class _MinikDuasPageState extends State<MinikDuasPage> {
  Future<List<DuaEntry>>? _future;

  Future<List<DuaEntry>> _load(ContentRepositories repos) {
    if (widget.prayerOnly) {
      return repos.duas
          .getPrayerDuas()
          .then((list) => list.map(DuaEntry.fromPrayerDua).toList());
    }
    return repos.duas.getCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= _load(repos);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<List<DuaEntry>>(
          future: _future!,
          onRetry: () => setState(() => _future = _load(repos)),
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
                    : 'Kur\'an\'dan seçilmiş dualar.',
                image: 'assets/images/duas/duas.png',
              ),
              for (final dua in duas)
                _DuaListTile(
                  dua: dua,
                  prayerOnly: widget.prayerOnly,
                  catalog: duas,
                ),
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
    required this.prayerOnly,
    required this.catalog,
  });

  final DuaEntry dua;
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
            color: Colors.white,
            elevation: 1,
            shadowColor: const Color(0x14000000),
            borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFFE7F4EC)
                            : const Color(0xFFF3F6F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dua.order > 0 ? '${dua.order}' : '•',
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
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: MinikColors.darkGreen,
                            ),
                          ),
                          if (dua.section.isNotEmpty)
                            Text(
                              dua.section,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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
                      color: done ? MinikColors.green : MinikColors.greenSoft,
                      size: 22,
                    ),
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
    final audioPath =
        dua.audio.isNotEmpty ? dua.audio : ContentAssets.audioFor(dua.id);
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted(widget.kind, dua.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F2),
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
                    DuaContentBlocks(dua: dua),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CopyTextButton(text: _duaCopyText(dua)),
                    ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              dua.displayImage,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(
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
                  style: const TextStyle(
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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
    return Column(
      children: [
        DuaPartCard(
          label: 'Arapça',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFE7F4EC),
          accent: MinikColors.green,
          arabic: dua.fullArabic,
          arabicFontSize: arabicFontSize,
        ),
        if (dua.fullReading.isNotEmpty) ...[
          const SizedBox(height: 12),
          DuaPartCard(
            label: 'Okunuşu',
            icon: Icons.record_voice_over_rounded,
            color: const Color(0xFFFFF3D6),
            accent: const Color(0xFFC29739),
            text: dua.fullReading,
          ),
        ],
        if (dua.fullMeaning.isNotEmpty) ...[
          const SizedBox(height: 12),
          DuaPartCard(
            label: 'Meali',
            icon: Icons.translate_rounded,
            color: const Color(0xFFE8F1FA),
            accent: const Color(0xFF3AA0C8),
            text: dua.fullMeaning,
          ),
        ],
      ],
    );
  }
}

class DuaPartCard extends StatelessWidget {
  const DuaPartCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.accent,
    this.arabic = '',
    this.text = '',
    this.emptyHint = '',
    this.arabicFontSize = 26,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color accent;
  final String arabic;
  final String text;
  final String emptyHint;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final hasArabic = arabic.trim().isNotEmpty;
    final hasText = text.trim().isNotEmpty;
    final body = hasArabic
        ? ArabicText(arabic, fontSize: arabicFontSize)
        : SelectableText(
            hasText ? text : emptyHint,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w600,
              fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
              color: hasText ? MinikColors.darkGreen : MinikColors.textMuted,
            ),
          );
    if (!hasArabic && !hasText && emptyHint.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14),
            ),
            child: body,
          ),
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
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x33000000),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ListenButton(audio: audio, path: path),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLearned,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: MinikColors.green,
                        side: const BorderSide(
                          color: MinikColors.green,
                          width: 1.4,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Text(learned ? 'Öğrendin' : 'Öğrendim'),
                    ),
                  ),
                  if (onNext != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3AA0C8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          textStyle: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Sonraki'),
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

String _duaCopyText(DuaEntry dua) {
  return joinCopyParts([
    dua.title,
    dua.fullArabic,
    dua.fullReading,
    dua.fullMeaning,
    dua.reference,
  ]);
}

class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    required this.audio,
    required this.path,
    this.iconStyle = false,
  });

  final AudioPlayerService audio;
  final String path;
  final bool iconStyle;

  Future<void> _play(BuildContext context) async {
    final played = await audio.toggleAsset(path);
    if (played || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ses yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: audio.playingStream,
      initialData: audio.isPlaying,
      builder: (context, snapshot) {
        final playing = snapshot.data ?? false;
        final icon = playing ? Icons.stop_rounded : Icons.volume_up_rounded;
        final label = playing ? 'Durdur' : 'Dinle';
        if (iconStyle) {
          return FilledButton.icon(
            onPressed: () => _play(context),
            icon: Icon(icon),
            label: Text(label),
          );
        }
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _play(context),
            style: FilledButton.styleFrom(
              backgroundColor: MinikColors.green,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            icon: Icon(icon),
            label: Text(label),
          ),
        );
      },
    );
  }
}
