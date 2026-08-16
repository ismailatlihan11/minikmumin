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
      image: 'assets/images/learn/wudu.png',
    ),
    LearnCategory(
      id: 'prayer',
      title: 'Namaz',
      route: '/minik/learn/prayer',
      icon: 'mosque',
      image: 'assets/images/learn/prayer.png',
    ),
    LearnCategory(
      id: 'duas',
      title: 'Dualar',
      route: '/minik/learn/duas',
      icon: 'favorite',
      image: 'assets/images/learn/duas.png',
    ),
    LearnCategory(
      id: 'asma',
      title: 'Esmaül Hüsna',
      route: '/minik/learn/asma',
      icon: 'auto_awesome',
      image: 'assets/images/learn/asma.png',
    ),
    LearnCategory(
      id: 'prophets',
      title: 'Peygamberler',
      route: '/minik/learn/prophets',
      icon: 'menu_book',
      image: 'assets/images/learn/prophets.png',
    ),
    LearnCategory(
      id: 'stories',
      title: 'Kıssalar',
      route: '/minik/learn/stories',
      icon: 'auto_stories',
      image: 'assets/images/learn/stories.png',
    ),
    LearnCategory(
      id: 'morality',
      title: 'Güzel Ahlak',
      route: '/minik/learn/morality',
      icon: 'favorite_outline',
      image: 'assets/images/learn/morality.png',
    ),
    LearnCategory(
      id: 'ilmihal',
      title: 'İlmihal',
      route: '/minik/learn/ilmihal',
      icon: 'menu_book',
      image: 'assets/images/learn/ilmihal.png',
    ),
    LearnCategory(
      id: 'hadith',
      title: 'Hadisler',
      route: '/minik/hadith',
      icon: 'menu_book',
      image: 'assets/images/learn/hadith.png',
    ),
    LearnCategory(
      id: 'quiz',
      title: 'Mini Testler',
      route: '/minik/quiz',
      icon: 'quiz',
      image: 'assets/images/learn/quiz.png',
    ),
  ];
}
