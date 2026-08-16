import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/interactive_lesson.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  Future<PrayerLesson>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.prayer.getLesson();
    return Scaffold(
      appBar: AppBar(title: const Text('Namaz')),
      body: AsyncBody<PrayerLesson>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.prayer.getLesson()),
        builder: (lesson) {
          final steps = [...lesson.steps]..sort((a, b) => a.order.compareTo(b.order));
          return ListView(
            padding: AppSpacing.page,
            children: [
              PageHeader(
                title: lesson.title,
                subtitle: 'Kaynak: ${lesson.sourceName}',
                image: 'assets/images/prayer/prayer.png',
              ),
              CatalogGrid(
                children: [
                  for (final step in steps)
                    CatalogTile(
                      image: ContentAssets.prayerImage(step.id),
                      semanticLabel: '${step.order}. ${step.title}',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScaffold(
                            title: step.title,
                            children: [
                              Image.asset(
                                ContentAssets.prayerImage(step.id),
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                '${step.order}. ${step.title}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(step.description, style: Theme.of(context).textTheme.bodyLarge),
                              if (step.sourceReference.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text('Kaynak: ${step.sourceReference}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
