import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'prayer_catalog_view.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A)),
      body: SafeArea(
        child: PrayerCatalogView(
          onBack: () => Navigator.pop(context),
          onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
          onOpenStep: (
            step, {
            required girl,
            required totalSteps,
            required upcoming,
          }) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerStepDetailPage(
                  step: step,
                  girl: girl,
                  totalSteps: totalSteps,
                  upcoming: upcoming,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
