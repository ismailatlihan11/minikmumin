import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../routes.dart';

class HomeModule {
  const HomeModule({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
    required this.accent,
    required this.route,
    this.featured = false,
    this.idleMotion = false,
  });

  final String title;
  final String subtitle;
  final String image;
  final Color color;
  final Color accent;
  final String route;
  final bool featured;
  final bool idleMotion;
}

abstract final class HomeCatalog {
  static List<HomeModule> get modules => [
    HomeModule(
      title: 'Temel Dini Bilgiler',
      subtitle: 'İslam\'ın temel bilgilerini birlikte öğrenelim.',
      image: 'assets/images/home/card_ilmihal.jpg',
      color: MinikColors.of(const Color(0xFFE7F4EC), const Color(0xFF233128)),
      accent: MinikColors.green,
      route: AppRoutes.learnBasics,
      featured: true,
    ),
    HomeModule(
      title: 'Abdest Öğren',
      subtitle: 'Adım adım abdest almayı öğren',
      image: 'assets/images/home/card_wudu.jpg',
      color: MinikColors.of(const Color(0xFFD8EEF8), const Color(0xFF1F323B)),
      accent: Color(0xFF3AA0C8),
      route: AppRoutes.learnWudu,
      idleMotion: true,
    ),
    HomeModule(
      title: 'Namaz Öğren',
      subtitle: 'Namaz kılmayı adım adım öğren',
      image: 'assets/images/home/card_prayer.jpg',
      color: MinikColors.of(const Color(0xFFFFF1C2), const Color(0xFF463C1B)),
      accent: Color(0xFFE0A21A),
      route: AppRoutes.learnPrayer,
      idleMotion: true,
    ),
    HomeModule(
      title: 'Namazda Okunan Ayetler ve Dualar',
      subtitle: 'Namazda okunan ayet ve dualar sırasıyla',
      image: 'assets/images/home/card_prayer_duas.jpg',
      color: MinikColors.of(const Color(0xFFE8DFF8), const Color(0xFF271F37)),
      accent: Color(0xFF8B6CC9),
      route: AppRoutes.learnPrayerDuas,
    ),
    HomeModule(
      title: "Kur'an Öğren",
      subtitle: 'Diyanet Elifba sırasıyla harflerden okumaya.',
      image: 'assets/images/home/card_quran_learn.jpg',
      color: MinikColors.of(const Color(0xFFEAF6FF), const Color(0xFF152938)),
      accent: MinikColors.green,
      route: AppRoutes.learnQuran,
    ),
    HomeModule(
      title: "Kur'an-ı Kerim",
      subtitle: "Kur'an'ı oku, dinle ve anlamını keşfet.",
      image: 'assets/images/home/card_quran.jpg',
      color: MinikColors.of(const Color(0xFFD4F0E2), const Color(0xFF253A30)),
      accent: MinikColors.greenSoft,
      route: AppRoutes.quran,
    ),
    HomeModule(
      title: 'Hadisler',
      subtitle: 'Peygamberimizden ﷺ öğütler',
      image: 'assets/images/home/card_hadith.jpg',
      color: MinikColors.of(const Color(0xFFFADDE3), const Color(0xFF391D22)),
      accent: Color(0xFFD36B84),
      route: AppRoutes.hadith,
    ),
    HomeModule(
      title: 'Peygamberler ve Kıssalar',
      subtitle: 'Peygamberlerin hayatları ve kıssalar',
      image: 'assets/images/home/circle_prophets.jpg',
      color: MinikColors.of(const Color(0xFFFFE8D2), const Color(0xFF402C18)),
      accent: Color(0xFFD08A3A),
      route: AppRoutes.learnProphetsStories,
    ),
    HomeModule(
      title: 'Güzel Ahlak',
      subtitle: 'Güzel davranışları öğrenelim',
      image: 'assets/images/home/card_morality.jpg',
      color: MinikColors.of(const Color(0xFFE6D9F5), const Color(0xFF2C2139)),
      accent: Color(0xFF9B6BC9),
      route: AppRoutes.learnMorality,
    ),
    HomeModule(
      title: 'Esmaül Hüsna',
      subtitle: 'Allah\'ın güzel isimleri',
      image: 'assets/images/home/circle_asma.jpg',
      color: MinikColors.of(const Color(0xFFE3F3E8), const Color(0xFF1F3327)),
      accent: MinikColors.green,
      route: AppRoutes.learnAsma,
    ),
    HomeModule(
      title: 'Dualar',
      subtitle: 'Günlük hayatta okunan dualar',
      image: 'assets/images/home/card_duas.jpg',
      color: MinikColors.of(const Color(0xFFDDEBFA), const Color(0xFF1C2A3A)),
      accent: Color(0xFF4F86C6),
      route: AppRoutes.learnDuas,
    ),
    HomeModule(
      title: 'Zikirmatik',
      subtitle: 'Zikirlerini say',
      image: 'assets/images/home/zikr_counter_badge.jpg',
      color: MinikColors.of(const Color(0xFFD8F1EC), const Color(0xFF1B332F)),
      accent: Color(0xFF2E9C8A),
      route: AppRoutes.zikr,
    ),
    HomeModule(
      title: 'Oyunlar',
      subtitle: 'Öğrenirken eğlen',
      image: 'assets/images/home/card_games.jpg',
      color: MinikColors.of(const Color(0xFFDDEFFB), const Color(0xFF17293A)),
      accent: Color(0xFF3AA0C8),
      route: AppRoutes.games,
    ),
  ];
}
