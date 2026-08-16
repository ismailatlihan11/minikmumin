import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/hadith.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  Future<List<Hadith>>? _future;
  String _query = '';
  bool _shortOnly = true;

  static const _shortLimit = 420;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.hadith.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Hadisler')),
      body: AsyncBody<List<Hadith>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.hadith.getAll()),
        builder: (items) {
          final pool = _shortOnly
              ? items.where((item) => item.plainTurkish.length <= _shortLimit).toList()
              : items;
          final source = pool.isEmpty ? items : pool;
          final filtered = _query.trim().isEmpty
              ? source
              : source
                  .where((item) =>
                      item.plainTurkish.toLowerCase().contains(_query.toLowerCase()) ||
                      item.id.contains(_query))
                  .toList();
          return Column(
            children: [
              Padding(
                padding: AppSpacing.page,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Hadis ara',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Kısa hadisler'),
                      subtitle: const Text('Çocuklar için daha kısa metinler'),
                      value: _shortOnly,
                      onChanged: (value) => setState(() => _shortOnly = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ContentTile(
                      color: MinikColors.pastelAt(index),
                      title: 'Hadis ${item.id}',
                      subtitle: item.plainTurkish,
                      leading: NumberBadge(item.id, color: MinikColors.surface),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HadithDetailPage(hadith: item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HadithDetailPage extends StatelessWidget {
  const HadithDetailPage({super.key, required this.hadith});

  final Hadith hadith;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Hadis ${hadith.id}',
      actions: [
        CopyIconButton(
          text: joinCopyParts([
            'Hadis ${hadith.id}',
            hadith.arabic,
            hadith.plainTurkish,
          ]),
        ),
        FavoriteButton(kind: 'hadith', id: hadith.id, title: 'Hadis ${hadith.id}'),
      ],
      children: [
        ArabicPanel(hadith.arabic),
        const SizedBox(height: AppSpacing.md),
        SelectableText(hadith.plainTurkish, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        CopyTextButton(
          text: joinCopyParts([
            'Hadis ${hadith.id}',
            hadith.arabic,
            hadith.plainTurkish,
          ]),
        ),
      ],
    );
  }
}
