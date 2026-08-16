class LearnCategory {
  const LearnCategory({
    required this.id,
    required this.title,
    required this.route,
    required this.icon,
    required this.image,
  });

  final String id;
  final String title;
  final String route;
  final String icon;
  final String image;
}

abstract final class LearnCategories {
  static const List<LearnCategory> all = [
    LearnCategory(
      id: 'wudu',
      title: 'Abdest',
      route: '/minik/learn/wudu',
      icon: 'water_drop',
      image: 'assets/images/wudu/wudu.png',
    ),
    LearnCategory(
      id: 'prayer',
      title: 'Namaz',
      route: '/minik/learn/prayer',
      icon: 'mosque',
      image: 'assets/images/prayer/prayer.png',
    ),
    LearnCategory(
      id: 'duas',
      title: 'Dualar',
      route: '/minik/learn/duas',
      icon: 'favorite',
      image: 'assets/images/duas/duas.png',
    ),
    LearnCategory(
      id: 'asma',
      title: 'Esmaül Hüsna',
      route: '/minik/learn/asma',
      icon: 'auto_awesome',
      image: 'assets/images/duas/asma.png',
    ),
    LearnCategory(
      id: 'prophets',
      title: 'Peygamberler',
      route: '/minik/learn/prophets',
      icon: 'menu_book',
      image: 'assets/images/prophets/prophets.png',
    ),
    LearnCategory(
      id: 'morality',
      title: 'Güzel Ahlak',
      route: '/minik/learn/morality',
      icon: 'favorite_outline',
      image: 'assets/images/morality/morality.png',
    ),
    LearnCategory(
      id: 'ilmihal',
      title: 'İlmihal',
      route: '/minik/learn/ilmihal',
      icon: 'menu_book',
      image: 'assets/images/home/ilmihal.png',
    ),
    LearnCategory(
      id: 'hadith',
      title: 'Hadisler',
      route: '/minik/hadith',
      icon: 'menu_book',
      image: 'assets/images/quran/quran.png',
    ),
    LearnCategory(
      id: 'quiz',
      title: 'Mini Testler',
      route: '/minik/quiz',
      icon: 'quiz',
      image: 'assets/images/quiz/quiz.png',
    ),
  ];
}
