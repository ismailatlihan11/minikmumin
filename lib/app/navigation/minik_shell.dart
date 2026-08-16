import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';
import '../../features/asma/asma_page.dart';
import '../../features/duas/duas_page.dart';
import '../../features/hadith/hadith_page.dart';
import '../../features/home/home_page.dart';
import '../../features/learn/learn_page.dart';
import '../../features/learn/simple_topic_pages.dart';
import '../../features/prayer/prayer_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/prophets/prophets_page.dart';
import '../../features/quiz/quiz_page.dart';
import '../../features/quran/quran_page.dart';
import '../../features/wudu/wudu_flow_page.dart';

class MinikShell extends StatefulWidget {
  const MinikShell({super.key});

  @override
  State<MinikShell> createState() => _MinikShellState();
}

class _MinikShellState extends State<MinikShell> {
  int _index = 0;

  static const _pages = [
    MinikHomePage(),
    LearnPage(),
    MinikQuranPage(),
    MinikDuasPage(),
    MinikProfilePage(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: 'Ana Sayfa'),
    (icon: Icons.menu_book_rounded, label: 'Öğren'),
    (icon: Icons.auto_stories_rounded, label: "Kur'an"),
    (icon: Icons.favorite_rounded, label: 'Dualar'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MinikTheme.light(),
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: MinikColors.surface,
            boxShadow: AppShadows.nav,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, WidgetBuilder> minikRoutes() {
  return {
    AppRoutes.minik: (_) => const MinikShell(),
    AppRoutes.home: (_) => const MinikHomePage(),
    AppRoutes.learn: (_) => const LearnPage(),
    AppRoutes.learnWudu: (_) => const WuduFlowPage(),
    AppRoutes.learnPrayer: (_) => const PrayerPage(),
    AppRoutes.learnDuas: (_) => const MinikDuasPage(),
    AppRoutes.learnAsma: (_) => const AsmaPage(),
    AppRoutes.learnProphets: (_) => const ProphetsPage(),
    AppRoutes.learnMorality: (_) => const MoralityPage(),
    AppRoutes.learnIlmihal: (_) => const IlmihalPage(),
    AppRoutes.quiz: (_) => const QuizPage(),
    AppRoutes.quran: (_) => const MinikQuranPage(),
    AppRoutes.duas: (_) => const MinikDuasPage(),
    AppRoutes.hadith: (_) => const HadithPage(),
    AppRoutes.profile: (_) => const MinikProfilePage(),
  };
}
