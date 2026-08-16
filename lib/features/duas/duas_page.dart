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
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
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
                title: widget.prayerOnly ? 'Namazda Okunanlar' : 'Dualar',
                subtitle: widget.prayerOnly
                    ? 'Namazda öğrenilecek ifadeler, sûreler ve dualar.'
                    : 'Kur\'an\'dan seçilmiş dualar.',
                image: 'assets/images/duas/duas.png',
              ),
              for (final dua in duas)
                _DuaListTile(dua: dua, prayerOnly: widget.prayerOnly),
            ],
          ),
        ),
      ),
    );
  }
}

class _DuaListTile extends StatelessWidget {
  const _DuaListTile({required this.dua, required this.prayerOnly});

  final DuaEntry dua;
  final bool prayerOnly;

  @override
  Widget build(BuildContext context) {
    final kind = prayerOnly ? 'prayer_dua' : 'dua';
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted(kind, dua.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return ContentTile(
          title: dua.order > 0 ? '${dua.order}. ${dua.title}' : dua.title,
          subtitle: dua.section,
          leading: Image.asset(
            dua.displayImage,
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.menu_book_rounded,
              color: MinikColors.green,
            ),
          ),
          trailing: done
              ? const Icon(Icons.check_circle_rounded, color: MinikColors.green)
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuaDetailPage(dua: dua, kind: kind),
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
  });

  final DuaEntry dua;
  final String kind;

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
            subtitle: widget.kind == 'prayer_dua' ? 'Namazda okunanlar' : 'Dualar',
            route: widget.kind == 'prayer_dua'
                ? AppRoutes.learnPrayerDuas
                : AppRoutes.learnDuas,
            progress: 0.4,
          );
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final audioPath = dua.audio.isNotEmpty ? dua.audio : ContentAssets.audioFor(dua.id);
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<bool>(
      future: store.isCompleted(widget.kind, dua.id),
      builder: (context, snapshot) {
        final done = snapshot.data ?? false;
        return DetailScaffold(
          title: dua.title,
          actions: [
            CopyIconButton(text: _duaCopyText(dua)),
            FavoriteButton(kind: widget.kind, id: dua.id, title: dua.title),
          ],
          children: [
            Image.asset(
              dua.displayImage,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/duas/duas.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DuaContentBlocks(dua: dua),
            const SizedBox(height: AppSpacing.sm),
            CopyTextButton(text: _duaCopyText(dua)),
            const SizedBox(height: AppSpacing.lg),
            ListenButton(audio: _audio, path: audioPath),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: done ? 'Öğrendin' : 'Öğrendim',
              onPressed: done
                  ? null
                  : () => store.markCompleted(widget.kind, dua.id, xp: 5),
            ),
          ],
        );
      },
    );
  }
}

class DuaContentBlocks extends StatelessWidget {
  const DuaContentBlocks({
    super.key,
    required this.dua,
    this.arabicFontSize = 24,
  });

  final DuaEntry dua;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dua.verses.isNotEmpty)
          for (final verse in dua.verses) ...[
            ArabicPanel(verse.arabic, fontSize: arabicFontSize),
            const SizedBox(height: AppSpacing.sm),
            SelectableText(verse.meal, style: theme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
          ]
        else ...[
          ArabicPanel(dua.arabic, fontSize: arabicFontSize),
          if (dua.transliteration.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(dua.transliteration),
          ],
          const SizedBox(height: AppSpacing.md),
          SelectableText(dua.meaning, style: theme.bodyLarge),
        ],
        if (dua.reference.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(dua.reference, style: theme.bodySmall),
        ],
      ],
    );
  }
}

String _duaCopyText(DuaEntry dua) {
  if (dua.verses.isNotEmpty) {
    return joinCopyParts([
      dua.title,
      for (final verse in dua.verses) ...[verse.arabic, verse.meal],
      dua.reference,
    ]);
  }
  return joinCopyParts([
    dua.title,
    dua.arabic,
    dua.transliteration,
    dua.meaning,
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
    final played = await audio.playAsset(path);
    if (played || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ses yakında eklenecek.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (iconStyle) {
      return FilledButton.icon(
        onPressed: () => _play(context),
        icon: const Icon(Icons.volume_up_rounded),
        label: const Text('Dinle'),
      );
    }
    return PrimaryButton(
      label: 'Dinle',
      onPressed: () => _play(context),
    );
  }
}
