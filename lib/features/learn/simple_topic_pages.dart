import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/lessons.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';

class MoralityPage extends StatefulWidget {
  const MoralityPage({super.key});

  @override
  State<MoralityPage> createState() => _MoralityPageState();
}

class _MoralityPageState extends State<MoralityPage> {
  Future<List<MoralityLesson>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.morality.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('Güzel Ahlak')),
      body: AsyncBody<List<MoralityLesson>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.morality.getAll()),
        builder: (items) => ListView.builder(
          padding: AppSpacing.page,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ContentTile(
              color: MinikColors.pastelAt(index),
              title: item.title,
              subtitle: item.lesson,
              leading: NumberBadge('${index + 1}', color: MinikColors.blush),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScaffold(
                    title: item.title,
                    children: [
                      Text(item.lesson, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.md),
                      Text('Kaynak: ${item.source}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class IlmihalPage extends StatefulWidget {
  const IlmihalPage({super.key});

  @override
  State<IlmihalPage> createState() => _IlmihalPageState();
}

class _IlmihalPageState extends State<IlmihalPage> {
  Future<List<IlmihalLesson>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.ilmihal.getAll();
    return Scaffold(
      appBar: AppBar(title: const Text('İlmihal')),
      body: AsyncBody<List<IlmihalLesson>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.ilmihal.getAll()),
        builder: (items) => ListView.builder(
          padding: AppSpacing.page,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ContentTile(
              color: MinikColors.pastelAt(index),
              title: item.title,
              subtitle: item.summary,
              leading: NumberBadge('${index + 1}', color: MinikColors.sky),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScaffold(
                    title: item.title,
                    children: [
                      Text(item.summary, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Kaynak: ${item.sourceReference}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
