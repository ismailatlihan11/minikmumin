import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/prophet.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';

class ProphetsPage extends StatefulWidget {
  const ProphetsPage({super.key});

  @override
  State<ProphetsPage> createState() => _ProphetsPageState();
}

class _ProphetsPageState extends State<ProphetsPage> {
  Future<List<Prophet>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.prophets.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Peygamberler')),
      body: AsyncBody<List<Prophet>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.prophets.getAll()),
        builder: (items) => ListView(
          padding: AppSpacing.page,
          children: [
            CatalogGrid(
              children: [
                for (final item in items)
                  if (ContentAssets.prophetImages.containsKey(item.name.toLowerCase()))
                    CatalogTile(
                      image: ContentAssets.prophetImage(item.name),
                      semanticLabel: item.name,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProphetDetailPage(item: item)),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...items
                .where((item) => !ContentAssets.prophetImages.containsKey(item.name.toLowerCase()))
                .map(
                  (item) => ContentTile(
                    title: item.name,
                    subtitle: item.arabicName,
                    leading: const RoundedAsset(
                      path: 'assets/images/prophets/prophets.png',
                      width: 52,
                      height: 52,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProphetDetailPage(item: item)),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class ProphetDetailPage extends StatelessWidget {
  const ProphetDetailPage({super.key, required this.item});

  final Prophet item;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: item.name,
      children: [
        Image.asset(
          ContentAssets.prophetImage(item.name),
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(item.arabicName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Text(item.summary, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        Text('Kur\'an: ${item.quranReferences}'),
        const SizedBox(height: AppSpacing.sm),
        Text('Kaynak: ${item.sourceName}', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
