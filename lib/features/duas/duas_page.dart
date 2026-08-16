import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikDuasPage extends StatefulWidget {
  const MinikDuasPage({super.key});

  @override
  State<MinikDuasPage> createState() => _MinikDuasPageState();
}

class _MinikDuasPageState extends State<MinikDuasPage> {
  Future<List<DuaEntry>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.duas.getCatalog();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<List<DuaEntry>>(
          future: _future!,
          onRetry: () => setState(() => _future = repos.duas.getCatalog()),
          emptyTitle: 'Dua bulunamadı.',
          builder: (duas) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Dualar',
                subtitle: 'Güzel duaları oku ve dinle.',
                image: 'assets/images/duas/duas.png',
              ),
              CatalogGrid(
                children: [
                  for (final dua in duas)
                    CatalogTile(
                      image: ContentAssets.duaImage(dua.id),
                      semanticLabel: dua.title,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DuaDetailPage(dua: dua)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DuaDetailPage extends StatefulWidget {
  const DuaDetailPage({super.key, required this.dua});

  final DuaEntry dua;

  @override
  State<DuaDetailPage> createState() => _DuaDetailPageState();
}

class _DuaDetailPageState extends State<DuaDetailPage> {
  final AudioPlayerService _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final audioPath = dua.audio.isNotEmpty ? dua.audio : ContentAssets.audioFor(dua.id);
    return DetailScaffold(
      title: dua.title,
      children: [
        Image.asset(
          ContentAssets.duaImage(dua.id),
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        ArabicPanel(dua.arabic, fontSize: 24),
        if (dua.transliteration.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(dua.transliteration),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(dua.meaning, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(dua.reference, style: Theme.of(context).textTheme.bodySmall),
        if (audioPath != null && audioPath.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Dinle',
            onPressed: () => _audio.playAsset(audioPath),
          ),
        ],
      ],
    );
  }
}
