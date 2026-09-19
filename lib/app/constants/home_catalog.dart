import 'package:flutter/material.dart';

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

class HomeQuickItem {
  const HomeQuickItem({
    required this.title,
    required this.image,
    required this.route,
  });

  final String title;
  final String image;
  final String route;
}

abstract final class HomeCatalog {
  static const modules = [
    HomeModule(
      title: 'Temel Dini Bilgiler',
      subtitle: 'İslam\'ın temel bilgilerini birlikte öğrenelim.',
      image: 'assets/images/home/card_ilmihal.png',
      color: Color(0xFFE7F4EC),
      accent: Color(0xFF21684E),
      route: AppRoutes.learnBasics,
      featured: true,
    ),
    HomeModule(
      title: 'Abdest Öğren',
      subtitle: 'Adım adım abdest almayı öğren',
      image: 'assets/images/home/card_wudu.png',
      color: Color(0xFFD8EEF8),
      accent: Color(0xFF3AA0C8),
      route: AppRoutes.learnWudu,
      idleMotion: true,
    ),
    HomeModule(
      title: 'Namaz Öğren',
      subtitle: 'Namaz kılmayı adım adım öğren',
      image: 'assets/images/home/card_prayer.png',
      color: Color(0xFFFFF1C2),
      accent: Color(0xFFE0A21A),
      route: AppRoutes.learnPrayer,
      idleMotion: true,
    ),
    HomeModule(
      title: 'Namazda Okunan Ayetler ve Dualar',
      subtitle: 'Namazda okunan ayet ve dualar sırasıyla',
      image: 'assets/images/home/card_prayer_duas.png',
      color: Color(0xFFE8DFF8),
      accent: Color(0xFF8B6CC9),
      route: AppRoutes.learnPrayerDuas,
    ),
    HomeModule(
      title: "Kur'an Öğren",
      subtitle: 'Diyanet Elifba sırasıyla harflerden okumaya.',
      image: 'assets/images/home/card_quran_learn.png',
      color: Color(0xFFEAF6FF),
      accent: Color(0xFF21684E),
      route: AppRoutes.learnQuran,
    ),
    HomeModule(
      title: "Kur'an-ı Kerim",
      subtitle: "Kur'an'ı oku, dinle ve anlamını keşfet.",
      image: 'assets/images/home/card_quran.png',
      color: Color(0xFFD4F0E2),
      accent: Color(0xFF3D8B6E),
      route: AppRoutes.quran,
    ),
    HomeModule(
      title: 'Hadisler',
      subtitle: 'Peygamberimizden ﷺ öğütler',
      image: 'assets/images/home/card_hadith.png',
      color: Color(0xFFFADDE3),
      accent: Color(0xFFD36B84),
      route: AppRoutes.hadith,
    ),
    HomeModule(
      title: 'Peygamberler ve Kıssalar',
      subtitle: 'Peygamberlerin hayatları ve kıssalar',
      image: 'assets/images/home/circle_prophets.png',
      color: Color(0xFFFFE8D2),
      accent: Color(0xFFD08A3A),
      route: AppRoutes.learnProphetsStories,
    ),
    HomeModule(
      title: 'Güzel Ahlak',
      subtitle: 'Güzel davranışları öğrenelim',
      image: 'assets/images/home/card_morality.png',
      color: Color(0xFFE6D9F5),
      accent: Color(0xFF9B6BC9),
      route: AppRoutes.learnMorality,
    ),
  ];

  static const quickItems = [
    HomeQuickItem(
      title: 'Esmaül Hüsna',
      image: 'assets/images/home/circle_asma.png',
      route: AppRoutes.learnAsma,
    ),
    HomeQuickItem(
      title: 'Devam Et',
      image: 'assets/images/home/continue_book.png',
      route: AppRoutes.learnBasics,
    ),
    HomeQuickItem(
      title: 'Zikirmatik',
      image: 'assets/images/home/circle_zikr.png',
      route: AppRoutes.zikr,
    ),
    HomeQuickItem(
      title: 'Macera',
      image: 'assets/images/home/mini_trophy.png',
      route: AppRoutes.dailyTask,
    ),
    HomeQuickItem(
      title: 'Favoriler',
      image: 'assets/images/home/circle_favorites.png',
      route: AppRoutes.favorites,
    ),
  ];
}
