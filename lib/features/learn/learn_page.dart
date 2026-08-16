import 'package:flutter/material.dart';

import '../../app/constants/learn_categories.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/widgets/minik_ui.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            const PageHeader(
              title: 'Haydi Öğrenelim',
              subtitle: 'Bir konu seç, adım adım ilerleyelim.',
              image: 'assets/images/home/learn.png',
            ),
            CatalogGrid(
              children: [
                for (final category in LearnCategories.all)
                  CatalogTile(
                    image: category.image,
                    semanticLabel: category.title,
                    onTap: () => Navigator.pushNamed(context, category.route),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ModulePreviewPage extends StatelessWidget {
  const ModulePreviewPage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MinikTheme.light(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: AppSpacing.page,
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
