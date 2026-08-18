import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/minik_ui.dart';

class ProphetsStoriesHubPage extends StatelessWidget {
  const ProphetsStoriesHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            const PageHeader(
              title: 'Peygamberler ve Kıssalar',
              subtitle: 'Peygamberlerin hayatlarını ve çocuklara uygun kıssaları oku.',
              image: 'assets/images/learn/prophets.png',
            ),
            ContentTile(
              title: 'Peygamberler',
              subtitle: 'Peygamberlerimizi tanıyalım',
              leading: Image.asset(
                'assets/images/home/circle_prophets.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              onTap: () => Navigator.pushNamed(context, AppRoutes.learnProphets),
            ),
            ContentTile(
              title: 'Kıssalar',
              subtitle: 'Kıssalardan güzel dersler çıkaralım',
              leading: Image.asset(
                'assets/images/home/circle_stories.png',
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
              onTap: () => Navigator.pushNamed(context, AppRoutes.learnStories),
            ),
            ContentTile(
              title: 'Peygamberler Kitabı',
              subtitle: 'Sayfa sayfa okumaya devam et',
              leading: const Icon(
                Icons.auto_stories_rounded,
                color: MinikColors.green,
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.learnProphetsBook),
            ),
          ],
        ),
      ),
    );
  }
}
