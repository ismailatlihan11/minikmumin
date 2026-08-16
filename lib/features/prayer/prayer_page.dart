import 'package:flutter/material.dart';

import 'prayer_catalog_view.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      body: SafeArea(
        child: PrayerCatalogView(
          onBack: () => Navigator.pop(context),
          onHome: () => Navigator.popUntil(context, (route) => route.isFirst),
          onOpenStep: (step) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerStepDetailPage(step: step),
              ),
            );
          },
        ),
      ),
    );
  }
}
