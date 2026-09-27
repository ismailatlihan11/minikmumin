import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../shared/widgets/minik_ui.dart';
import 'games_catalog.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            const PageHeader(
              title: 'Oyunlar',
              subtitle: 'Öğrendiklerini eğlenerek pekiştir.',
            ),
            KidGamesList(games: kidGames()),
          ],
        ),
      ),
    );
  }
}
