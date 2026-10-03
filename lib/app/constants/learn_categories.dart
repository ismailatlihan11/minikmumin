class LearnCategory {
  const LearnCategory({
    required this.id,
    required this.title,
    required this.route,
    required this.icon,
    required this.image,
    this.idleMotion = false,
  });

  final String id;
  final String title;
  final String route;
  final String icon;
  final String image;
  final bool idleMotion;
}

abstract final class LearnCategories {
  static const List<LearnCategory> all = [
    LearnCategory(
      id: 'basics',
      title: 'Temel Dini Bilgiler',
      route: '/minik/learn/basics',
      icon: 'menu_book',
      image: 'assets/images/home/card_ilmihal.jpg',
    ),
    LearnCategory(
      id: 'wudu',
      title: 'Abdest Öğren',
      route: '/minik/learn/wudu',
      icon: 'water_drop',
      image: 'assets/images/home/card_wudu.jpg',
      idleMotion: true,
    ),
    LearnCategory(
      id: 'prayer',
      title: 'Namaz Öğren',
      route: '/minik/learn/prayer',
      icon: 'mosque',
      image: 'assets/images/home/card_prayer.jpg',
      idleMotion: true,
    ),
    LearnCategory(
      id: 'prayer_duas',
      title: 'Namaz Duaları',
      route: '/minik/learn/prayer-duas',
      icon: 'favorite',
      image: 'assets/images/home/card_prayer_duas.jpg',
    ),
    LearnCategory(
      id: 'quran_learn',
      title: "Kur'an Öğren",
      route: '/minik/learn/quran-learn',
      icon: 'menu_book',
      image: 'assets/images/home/card_quran_learn.jpg',
    ),
    LearnCategory(
      id: 'duas',
      title: 'Dualar',
      route: '/minik/learn/duas',
      icon: 'favorite',
      image: 'assets/images/home/card_prayer_duas.jpg',
    ),
    LearnCategory(
      id: 'hadith',
      title: 'Hadisler',
      route: '/minik/hadith',
      icon: 'menu_book',
      image: 'assets/images/home/card_hadith.jpg',
    ),
    LearnCategory(
      id: 'prophets_stories',
      title: 'Peygamberler ve Kıssalar',
      route: '/minik/learn/prophets-stories',
      icon: 'auto_stories',
      image: 'assets/images/home/circle_prophets.jpg',
    ),
    LearnCategory(
      id: 'morality',
      title: 'Güzel Ahlak',
      route: '/minik/learn/morality',
      icon: 'favorite_outline',
      image: 'assets/images/home/card_morality.jpg',
    ),
    LearnCategory(
      id: 'asma',
      title: 'Esmaül Hüsna',
      route: '/minik/learn/asma',
      icon: 'auto_awesome',
      image: 'assets/images/home/circle_asma.jpg',
    ),
    LearnCategory(
      id: 'quiz',
      title: 'Mini Testler',
      route: '/minik/quiz',
      icon: 'quiz',
      image: 'assets/images/home/mini_quiz.jpg',
    ),
  ];
}
