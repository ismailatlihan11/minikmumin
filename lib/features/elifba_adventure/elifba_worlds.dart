import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'elifba_models.dart';

class ElifbaWorld {
  const ElifbaWorld({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.lessonIds,
    this.badge = '',
  });

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final List<int> lessonIds;
  final String badge;

  bool contains(int lessonId) => lessonIds.contains(lessonId);

  bool isComplete(Set<int> done) =>
      lessonIds.every(done.contains) && lessonIds.isNotEmpty;
}

abstract final class ElifbaWorlds {
  static const all = <ElifbaWorld>[
    ElifbaWorld(
      id: 'letters',
      title: 'Harfler Diyarı',
      emoji: '🌱',
      color: MinikColors.mint,
      lessonIds: [1, 2, 3],
      badge: 'İlk Harfim',
    ),
    ElifbaWorld(
      id: 'harakat',
      title: 'Harekeler Ormanı',
      emoji: '🌿',
      color: MinikColors.peach,
      lessonIds: [4, 5, 6],
      badge: 'Hareke Ustası',
    ),
    ElifbaWorld(
      id: 'reading',
      title: 'Okuma Vadisi',
      emoji: '🌳',
      color: MinikColors.sky,
      lessonIds: [7, 8, 9, 10, 11, 12],
      badge: 'Harf Birleştirici',
    ),
    ElifbaWorld(
      id: 'tajweed',
      title: 'Tecvid Dağları',
      emoji: '🏔',
      color: MinikColors.lavender,
      lessonIds: [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
      badge: 'Tecvid Kaşifi',
    ),
    ElifbaWorld(
      id: 'makhraj',
      title: 'Mahreç Bahçesi',
      emoji: '🌸',
      color: MinikColors.blush,
      lessonIds: [25, 26],
      badge: 'İlk Kelimem',
    ),
    ElifbaWorld(
      id: 'practice',
      title: 'Okuma Kalesine Yol',
      emoji: '📖',
      color: MinikColors.butter,
      lessonIds: [27, 28, 29, 30],
      badge: 'İlk Kelimem',
    ),
    ElifbaWorld(
      id: 'final',
      title: 'Final Kalesi',
      emoji: '🏰',
      color: MinikColors.goldSoft,
      lessonIds: [31],
      badge: 'Elifbâ Kahramanı',
    ),
  ];

  static ElifbaWorld forLesson(int id) {
    for (final world in all) {
      if (world.contains(id)) return world;
    }
    return all.first;
  }

  static List<ElifbaLesson> lessonsIn(
    ElifbaWorld world,
    List<ElifbaLesson> lessons,
  ) {
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    return [
      for (final id in world.lessonIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  static String badgeForLesson(int id) {
    switch (id) {
      case 1:
        return 'İlk Harfim';
      case 6:
        return 'Hareke Ustası';
      case 12:
        return 'Harf Birleştirici';
      case 18:
        return 'Tecvid Kaşifi';
      case 27:
        return 'İlk Kelimem';
      case 31:
        return 'Elifbâ Kahramanı';
      default:
        return '';
    }
  }
}

abstract final class ElifbaVoice {
  static const greetings = [
    'Merhaba! Ben Elif. Bugün birlikte yeni harfler öğreneceğiz. Hazır mısın?',
    'Haydi, kaldığımız yerden devam edelim!',
    'Bugün yeni bir keşif var. Hazır mısın?',
  ];

  static const correct = [
    'Harika! 🎉 Doğru bildin!',
    'Mükemmel!',
    'Bunu öğrendin!',
    'Çok güzel!',
  ];

  static const retry = [
    'Bir daha bakalım 😊',
    'Az kaldı!',
    'Harfi birlikte inceleyelim.',
    'Tekrar denersen başarabilirsin.',
    'Bir daha deneyelim.',
    'İpucu ister misin?',
  ];

  static String introFor(ElifbaLesson lesson) =>
      'Bugün ${lesson.title} keşfedeceğiz!';

  static String pick(List<String> lines, int seed) =>
      lines[seed.abs() % lines.length];
}
