import 'package:flutter/material.dart';

import '../../app/constants/learn_categories.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../shared/widgets/lesson_motion_image.dart';
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
            LayoutBuilder(
              builder: (context, constraints) {
                const columns = 3;
                const spacing = 10.0;
                final tileWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: 10,
                  children: [
                    for (final category in LearnCategories.all)
                      SizedBox(
                        width: tileWidth,
                        child: _LearnTopicTile(category: category),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnTopicTile extends StatelessWidget {
  const _LearnTopicTile({required this.category});

  final LearnCategory category;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.88,
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: const Color(0x22000000),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, category.route),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: category.idleMotion
                        ? LessonMotionImage(
                            image: category.image,
                            fit: BoxFit.cover,
                            semanticLabel: category.title,
                          )
                        : Image.asset(
                      category.image,
                      fit: BoxFit.cover,
                      semanticLabel: category.title,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: MinikColors.mint,
                        child: Center(
                          child: Text(
                            category.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MinikColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
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
