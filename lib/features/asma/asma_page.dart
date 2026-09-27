import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/asmaul_husna.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/listen_button.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';

class AsmaPage extends StatefulWidget {
  const AsmaPage({super.key});

  @override
  State<AsmaPage> createState() => _AsmaPageState();
}

class _AsmaPageState extends State<AsmaPage> {
  Future<List<AsmaulHusna>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.asma.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Esmaül Hüsna')),
      body: AsyncBody<List<AsmaulHusna>>(
        future: _future!,
        onRetry: () => setState(() {
          _future = repos.asma.getAll();
        }),
        builder: (items) => ListView.builder(
          padding: AppSpacing.page,
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MinikImage.asset(
                  'assets/images/duas/asma.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              );
            }
            final item = items[index - 1];
            return ContentTile(
              color: MinikColors.pastelAt(index),
              title: item.name,
              subtitle: item.meaning,
              leading: NumberBadge('${item.id}'),
              trailing: SizedBox(
                width: 72,
                child: ArabicText(item.arabic, fontSize: 16),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AsmaDetailPage(item: item)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AsmaDetailPage extends StatefulWidget {
  const AsmaDetailPage({super.key, required this.item});

  final AsmaulHusna item;

  @override
  State<AsmaDetailPage> createState() => _AsmaDetailPageState();
}

class _AsmaDetailPageState extends State<AsmaDetailPage> {
  final AudioPlayerService _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return DetailScaffold(
      title: item.name,
      actions: [
        CopyIconButton(
          text: joinCopyParts([
            item.name,
            item.arabic,
            item.meaning,
            item.childExplanation,
          ]),
        ),
      ],
      children: [
        ArabicPanel(item.arabic, fontSize: 36),
        if (item.audio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ListenButton(audio: _audio, path: item.audio),
        ],
        const SizedBox(height: AppSpacing.md),
        SelectableText(item.meaning,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(item.childExplanation,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        CopyTextButton(
          text: joinCopyParts([
            item.name,
            item.arabic,
            item.meaning,
            item.childExplanation,
          ]),
        ),
      ],
    );
  }
}
