import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../../features/asma/asma_page.dart';
import '../../features/books/peygamberler_kitabi_page.dart';
import '../../features/daily_task/daily_task_page.dart';
import '../../features/duas/duas_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/games/games_page.dart';
import '../../features/games/zikr_collect_page.dart';
import '../../features/hadith/hadith_page.dart';
import '../../features/home/home_page.dart';
import '../../features/learn/basics_page.dart';
import '../../features/learn/ilmihal_page.dart';
import '../../features/learn/learn_page.dart';
import '../../features/learn/morality_page.dart';
import '../../features/learn/prophets_stories_hub.dart';
import '../../features/stories/stories_page.dart';
import '../../features/prayer/prayer_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/prophets/prophets_page.dart';
import '../../features/quiz/quiz_page.dart';
import '../../features/quran/mushaf_page.dart';
import '../../features/quran/quran_page.dart';
import '../../features/elifba_adventure/elifba_hub.dart';
import '../../features/settings/settings_page.dart';
import '../../features/wudu/wudu_flow_page.dart';
import '../../features/zikr/zikr_page.dart';

class MinikShell extends StatefulWidget {
  const MinikShell({super.key});

  @override
  State<MinikShell> createState() => _MinikShellState();
}

class _MinikShellState extends State<MinikShell> {
  int _index = 0;

  static const _pages = [
    MinikQuranPage(),
    LearnPage(),
    GamesPage(),
    MinikProfilePage(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: 'Ana Sayfa'),
    (icon: Icons.menu_book_rounded, label: "Kur'an"),
    (icon: Icons.school_rounded, label: 'Öğren'),
    (icon: Icons.sports_esports_rounded, label: 'Oyunlar'),
    (icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MinikTheme.light(),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            MinikHomePage(isCurrentTab: _index == 0),
            ..._pages,
          ],
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x22000000),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: _items[i].icon,
                        label: _items[i].label,
                        selected: _index == i,
                        onTap: () => setState(() => _index = i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MinikColors.green : MinikColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: selected ? MinikColors.mint : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 10,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, WidgetBuilder> minikRoutes() {
  WidgetBuilder light(WidgetBuilder builder) {
    return (context) => MinikTheme.lightSurfaces(builder(context));
  }

  return {
    AppRoutes.minik: (_) => const MinikShell(),
    AppRoutes.home: light((_) => const MinikHomePage()),
    AppRoutes.learn: light((_) => const LearnPage()),
    AppRoutes.learnWudu: light((_) => const WuduFlowPage()),
    AppRoutes.learnPrayer: light((_) => const PrayerPage()),
    AppRoutes.learnPrayerDuas: light((_) => const MinikDuasPage(prayerOnly: true)),
    AppRoutes.learnDuas: light((_) => const MinikDuasPage()),
    AppRoutes.learnAsma: light((_) => const AsmaPage()),
    AppRoutes.learnProphets: light((_) => const ProphetsPage()),
    AppRoutes.learnProphetsBook: light(
      (_) => const PeygamberlerKitabiReaderPage(resume: true),
    ),
    AppRoutes.learnProphetsBookRead: light(
      (_) => const PeygamberlerKitabiReaderPage(resume: true),
    ),
    AppRoutes.learnStories: light((_) => const StoriesPage()),
    AppRoutes.learnMorality: light((_) => const MoralityPage()),
    AppRoutes.learnIlmihal: light((_) => const IlmihalPage()),
    AppRoutes.learnBasics: light((_) => const BasicsPage()),
    AppRoutes.learnQuran: light((_) => const ElifbaChooserPage()),
    AppRoutes.learnElifbaAdventure: light((_) => const ElifbaHubPage()),
    AppRoutes.learnProphetsStories: light((_) => const ProphetsStoriesHubPage()),
    AppRoutes.quiz: light((_) => const QuizPage()),
    AppRoutes.quran: light((_) => const MinikQuranPage()),
    AppRoutes.quranReader: light((_) => const MushafReaderPage(resume: true)),
    AppRoutes.duas: light((_) => const MinikDuasPage()),
    AppRoutes.hadith: light((_) => const HadithPage()),
    AppRoutes.games: light((_) => const GamesPage()),
    AppRoutes.zikrCollect: light((_) => const ZikrCollectPage()),
    AppRoutes.zikr: light((_) => const ZikrPage()),
    AppRoutes.dailyTask: light((_) => const DailyTaskPage()),
    AppRoutes.favorites: light((_) => const FavoritesPage()),
    AppRoutes.profile: light((_) => const MinikProfilePage()),
    AppRoutes.settings: light((_) => const SettingsPage()),
  };
}
