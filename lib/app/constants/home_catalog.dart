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
  });

  final String title;
  final String subtitle;
  final String image;
  final Color color;
  final Color accent;
  final String route;
}

class HomeMiniAction {
  const HomeMiniAction({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String image;
  final Color color;
  final String route;
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
      title: 'Abdesti Öğren',
      subtitle: 'Adım adım abdest almayı öğren',
      image: 'assets/images/home/card_wudu.png',
      color: Color(0xFFD8EEF8),
      accent: Color(0xFF3AA0C8),
      route: AppRoutes.learnWudu,
    ),
    HomeModule(
      title: 'Namazı Öğren',
      subtitle: 'Namaz kılmayı adım adım öğren',
      image: 'assets/images/home/card_prayer.png',
      color: Color(0xFFFFF1C2),
      accent: Color(0xFFE0A21A),
      route: AppRoutes.learnPrayer,
    ),
    HomeModule(
      title: 'Namazda okunan Ayetler ve Dualar',
      subtitle: 'Namazda okunan ayet ve dualar sırasıyla',
      image: 'assets/images/home/card_prayer_duas.png',
      color: Color(0xFFE8DFF8),
      accent: Color(0xFF8B6CC9),
      route: AppRoutes.learnPrayerDuas,
    ),
    HomeModule(
      title: "Kur’an-ı Kerim",
      subtitle: 'Oku, dinle ve öğren',
      image: 'assets/images/home/card_quran.png',
      color: Color(0xFFD4F0E2),
      accent: Color(0xFF3D8B6E),
      route: AppRoutes.quran,
    ),
    HomeModule(
      title: 'Hadisler',
      subtitle: 'Peygamberimizden öğütler',
      image: 'assets/images/home/card_hadith.png',
      color: Color(0xFFFADDE3),
      accent: Color(0xFFD36B84),
      route: AppRoutes.hadith,
    ),
    HomeModule(
      title: 'Dualar',
      subtitle: 'Kur\'an\'dan seçilmiş dualar',
      image: 'assets/images/home/card_duas.png',
      color: Color(0xFFC8EBE8),
      accent: Color(0xFF2A9A94),
      route: AppRoutes.duas,
    ),
    HomeModule(
      title: 'İlmihal',
      subtitle: 'Temel dini bilgiler',
      image: 'assets/images/home/card_ilmihal.png',
      color: Color(0xFFFBE6C8),
      accent: Color(0xFFD08A3A),
      route: AppRoutes.learnIlmihal,
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

  static const miniActions = [
    HomeMiniAction(
      title: 'Eğlenceli Testler',
      subtitle: 'Öğrendiklerini pekiştir',
      image: 'assets/images/home/mini_quiz.png',
      color: Color(0xFFFFF0B8),
      route: AppRoutes.quiz,
    ),
    HomeMiniAction(
      title: 'Başarılarım',
      subtitle: 'Rozetlerini gör ilerlemeni takip et',
      image: 'assets/images/home/mini_trophy.png',
      color: Color(0xFFD6ECFF),
      route: AppRoutes.profile,
    ),
    HomeMiniAction(
      title: 'Günün Görevi',
      subtitle: 'Bugünün görevi seni bekliyor!',
      image: 'assets/images/home/mini_gift.png',
      color: Color(0xFFF8D5C8),
      route: AppRoutes.dailyTask,
    ),
  ];

  static const quickItems = [
    HomeQuickItem(
      title: 'Esmaül Hüsna',
      image: 'assets/images/home/circle_asma.png',
      route: AppRoutes.learnAsma,
    ),
    HomeQuickItem(
      title: 'Peygamberler',
      image: 'assets/images/home/circle_prophets.png',
      route: AppRoutes.learnProphets,
    ),
    HomeQuickItem(
      title: 'Kıssalar',
      image: 'assets/images/home/circle_stories.png',
      route: AppRoutes.learnStories,
    ),
    HomeQuickItem(
      title: 'Değerler Eğitimi',
      image: 'assets/images/home/circle_values.png',
      route: AppRoutes.learnMorality,
    ),
    HomeQuickItem(
      title: 'Zikirmatik',
      image: 'assets/images/home/circle_zikr.png',
      route: AppRoutes.zikr,
    ),
    HomeQuickItem(
      title: 'Favorilerim',
      image: 'assets/images/home/circle_favorites.png',
      route: AppRoutes.favorites,
    ),
  ];
}
