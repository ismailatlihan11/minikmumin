import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class BasicsSectionDef {
  const BasicsSectionDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.itemIds,
    required this.color,
    required this.accent,
    required this.image,
    required this.actionLabel,
    this.symbols = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final List<int> itemIds;
  final Color color;
  final Color accent;
  final String image;
  final String actionLabel;
  final List<IconData> symbols;
}

/// JSON’daki 22 konuyu 4 öğrenme bölümüne bağlar. Konu metinleri değişmez.
abstract final class BasicsSections {
  static List<BasicsSectionDef> get all => [
    BasicsSectionDef(
      id: 'first_step',
      title: 'İlk Adım',
      subtitle: 'Temel kavramlarla başlayalım.',
      itemIds: [1, 2, 3, 4],
      color: MinikColors.of(const Color(0xFFFFF6DC), const Color(0xFF3D3317)),
      accent: const Color(0xFFE0A21A),
      image: 'assets/images/home/card_ilmihal.jpg',
      actionLabel: 'Öğrenmeye Başla →',
      symbols: [Icons.nightlight_round, Icons.star_rounded, Icons.menu_book_rounded],
    ),
    BasicsSectionDef(
      id: 'faith',
      title: 'İnanç',
      subtitle: 'İmanımızın temelini öğrenelim.',
      itemIds: [6, 7, 8, 9, 20, 21, 22, 10],
      color: MinikColors.of(const Color(0xFFE7F4EC), const Color(0xFF233128)),
      accent: MinikColors.green,
      image: 'assets/images/home/card_quran.jpg',
      actionLabel: 'Devam et →',
      symbols: [Icons.menu_book_rounded, Icons.nightlight_round, Icons.mosque_rounded],
    ),
    BasicsSectionDef(
      id: 'worship',
      title: 'İbadet',
      subtitle: 'Allah’a kulluğumuzu ve ibadetlerimizi öğrenelim.',
      itemIds: [5, 11, 12, 13, 14, 15],
      color: MinikColors.of(const Color(0xFFD8EEF8), const Color(0xFF1F323B)),
      accent: const Color(0xFF3AA0C8),
      image: 'assets/images/home/card_prayer.jpg',
      actionLabel: 'Devam et →',
      symbols: [Icons.mosque_rounded, Icons.water_drop_rounded, Icons.favorite_rounded],
    ),
    BasicsSectionDef(
      id: 'manners',
      title: 'Güzel Ahlak',
      subtitle: 'İyi ve güzel davranışları öğrenelim.',
      itemIds: [16, 17, 18, 19],
      color: MinikColors.of(const Color(0xFFE6D9F5), const Color(0xFF2C2139)),
      accent: const Color(0xFF9B6BC9),
      image: 'assets/images/home/card_morality.jpg',
      actionLabel: 'Devam et →',
      symbols: [Icons.volunteer_activism_rounded, Icons.favorite_rounded, Icons.eco_rounded],
    ),
  ];
}
