import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'elifba_models.dart';

class ElifbaWorld {
  const ElifbaWorld({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.lessons,
    this.badge = '',
  });

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final List<ElifbaLesson> lessons;
  final String badge;

  List<int> get lessonIds => [for (final lesson in lessons) lesson.id];

  bool contains(int lessonId) => lessons.any((lesson) => lesson.id == lessonId);

  bool isComplete(Set<int> done) =>
      lessons.isNotEmpty && lessonIds.every(done.contains);

  int get lastId => lessons.isEmpty ? 0 : lessons.last.id;
}

/// Harita bölgeleri ders numarasına göre değil, JSON içeriğine göre kurulur:
/// hareke işareti taşıyan ilk ders, seviye alanları ve final dersi belirleyici.
abstract final class ElifbaWorlds {
  static List<_WorldSpec> get _blueprint => [
        _WorldSpec(
            'letters', 'Harfler Köyü', '🌱', MinikColors.mint, 'Harf Kaşifi'),
        _WorldSpec(
          'harakat',
          'Harekeler Ormanı',
          '🌳',
          MinikColors.peach,
          'Hareke Ustası',
        ),
        _WorldSpec(
          'tajweed',
          'Tecvid Dağları',
          '🏔',
          MinikColors.lavender,
          'Tecvid Kaşifi',
        ),
        _WorldSpec(
          'reading',
          'Okuma Vadisi',
          '📖',
          MinikColors.sky,
          'Kelime Okuyucu',
        ),
        _WorldSpec(
          'final',
          'Final Kalesi',
          '🏰',
          MinikColors.goldSoft,
          'Elifbâ Kahramanı',
        ),
      ];

  static final _cache = <(int, bool), List<ElifbaWorld>>{};

  static List<ElifbaWorld> of(ElifbaPack pack) {
    final key = (pack.lessons.length, MinikColors.isDark);
    final cached = _cache[key];
    if (cached != null) return cached;
    final buckets = <String, List<ElifbaLesson>>{
      for (final spec in _blueprint) spec.id: <ElifbaLesson>[],
    };
    // İlk işaret dersinden sonraki başlangıç dersleri de Harekeler Ormanı'na.
    var markSeen = false;
    for (final lesson in pack.lessons) {
      if (_teachesMark(lesson)) markSeen = true;
      buckets[_bucketOf(lesson, markSeen)]!.add(lesson);
    }
    final worlds = <ElifbaWorld>[
      for (final spec in _blueprint)
        if (buckets[spec.id]!.isNotEmpty)
          ElifbaWorld(
            id: spec.id,
            title: spec.title,
            emoji: spec.emoji,
            color: spec.color,
            badge: spec.badge,
            lessons: List.unmodifiable(buckets[spec.id]!),
          ),
    ];
    _cache[key] = worlds;
    return worlds;
  }

  static String _bucketOf(ElifbaLesson lesson, bool markSeen) {
    final level = _fold(lesson.level);
    if (level.contains('final') || lesson.isFinal) return 'final';
    if (level.contains('orta')) return 'tajweed';
    if (level.startsWith('ileri baslangic')) return 'tajweed';
    if (level.contains('ileri')) return 'reading';
    return markSeen ? 'harakat' : 'letters';
  }

  /// Hareke, cezm, şedde, tenvin, med gibi işaret öğreten dersler.
  static bool _teachesMark(ElifbaLesson lesson) {
    if (lesson.rule?.symbol.isNotEmpty ?? false) return true;
    if (lesson.harakeTables.isNotEmpty) return true;
    if (lesson.medTable.isNotEmpty || lesson.medLetters.isNotEmpty) return true;
    if (lesson.types.isNotEmpty) return true;
    if (lesson.blending.isNotEmpty) return true;
    return false;
  }

  static String _fold(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .trim();
  }

  static ElifbaWorld forLesson(ElifbaPack pack, int id) {
    final worlds = of(pack);
    for (final world in worlds) {
      if (world.contains(id)) return world;
    }
    return worlds.first;
  }

  /// Bir bölgenin son dersi tamamlanınca o bölgenin rozeti verilir.
  static String badgeForLesson(ElifbaPack pack, int id) {
    if (pack.lessons.isNotEmpty && pack.lessons.first.id == id) {
      return 'İlk Harfim';
    }
    final lesson = pack.byId(id);
    if (lesson != null && lesson.blending.isNotEmpty) {
      return 'Harf Birleştirici';
    }
    for (final world in of(pack)) {
      if (world.lastId == id) return world.badge;
    }
    return '';
  }

  static List<String> get allBadges => const [
        'İlk Harfim',
        'Harf Kaşifi',
        'Hareke Ustası',
        'Harf Birleştirici',
        'Tecvid Kaşifi',
        'Kelime Okuyucu',
        'Elifbâ Kahramanı',
      ];
}

class _WorldSpec {
  const _WorldSpec(this.id, this.title, this.emoji, this.color, this.badge);

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final String badge;
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
    'İpucuna bakalım.',
    'Bir daha deneyelim.',
  ];

  static String introFor(ElifbaLesson lesson) =>
      'Bugün ${lesson.title} keşfedeceğiz!';

  static String pick(List<String> lines, int seed) =>
      lines[seed.abs() % lines.length];
}
