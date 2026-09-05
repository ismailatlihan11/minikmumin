import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/constants/peygamberler_kitabi.dart';
import 'package:minik_kalpler/core/utils/daily_seed.dart';
import 'package:minik_kalpler/core/utils/turkish_number.dart';
import 'package:minik_kalpler/core/utils/json_map.dart';
import 'package:minik_kalpler/data/models/asmaul_husna.dart';
import 'package:minik_kalpler/data/models/dhikr.dart';
import 'package:minik_kalpler/data/models/dua.dart';
import 'package:minik_kalpler/features/games/zikr_collect_logic.dart';
import 'package:minik_kalpler/data/models/hadith.dart';
import 'package:minik_kalpler/data/models/interactive_lesson.dart';
import 'package:minik_kalpler/data/models/lessons.dart';
import 'package:minik_kalpler/data/models/prophet.dart';
import 'package:minik_kalpler/data/models/quran_verse.dart';
import 'package:minik_kalpler/data/models/quiz.dart';
import 'package:minik_kalpler/data/models/story.dart';

void main() {
  test('QuranVerse maps the existing kuran.json schema', () {
    final verse = QuranVerse.fromJson({
      'ayet_id': 1,
      'sure_id': 1,
      'ayet_no': 1,
      'sayfa': 0,
      'metin': {'arapca': 'بِسْمِ اللّٰهِ', 'meal': 'Rahmân ve rahîm'},
    });
    expect(verse.ayahId, 1);
    expect(verse.arabic, 'بِسْمِ اللّٰهِ');
    expect(verse.hasMeal, isTrue);
    expect(verse.displayPage, 0);
    expect(verse.toJson()['metin']['arapca'], 'بِسْمِ اللّٰهِ');
  });

  test('Hadith maps the existing hadis.json schema', () {
    final hadith = Hadith.fromJson({
      'hadith_id': 1,
      'arabic': 'العربية',
      'turkish': '<p>Niyetlere göre</p>',
    });
    expect(hadith.id, '1');
    expect(hadith.plainTurkish, 'Niyetlere göre');
  });

  test('QuizQuestion reads correct option from JSON', () {
    final question = QuizQuestion.fromJson({
      'id': 'quran_001',
      'category': 'Kur\'an',
      'difficulty': 'easy',
      'type': 'multiple_choice',
      'question': 'Test?',
      'xp': 5,
      'correctOption': 'a',
      'explanation': 'Açıklama',
      'options': [
        {'id': 'a', 'text': 'Doğru yol', 'correct': true},
        {'id': 'b', 'text': 'Dünya malı', 'correct': false},
      ],
    });
    expect(question.correctOption?.id, 'a');
    expect(question.xp, 5);
    expect(question.explanation, 'Açıklama');
  });

  test('WuduLesson reads steps from JSON', () {
    final lesson = WuduLesson.fromJson({
      'id': 'wudu',
      'title': 'Abdest',
      'sourceName': 'Diyanet',
      'verificationRequired': true,
      'steps': [
        {'id': 'hands', 'order': 1, 'title': 'Eller', 'description': 'Yıka'},
      ],
      'completionDua': {
        'id': 'abdest_duasi',
        'title': 'Abdest Tamamlandı Duası',
        'arabic': 'أَشْهَدُ',
        'transliteration': 'Eşhedü',
        'meaning': 'Şahitlik ederim',
        'audio': 'assets/audio/wudu/abdest_duasi.mp3',
      },
    });
    expect(lesson.steps, hasLength(1));
    expect(lesson.steps.first.id, 'hands');
    expect(lesson.completionDua?.id, 'abdest_duasi');
    expect(lesson.completionDua?.hasAudio, isTrue);
  });

  test('Dua maps the dualar.json schema', () {
    final dua = Dua.fromJson({
      'order': 1,
      'id': 'quran_dua_2_201',
      'type': 'quranic_dua',
      'title': 'Rabbenâ Âtinâ',
      'description': 'Kur\'an\'da geçen kapsamlı dua',
      'surahNumber': 2,
      'ayahNumber': 201,
      'arabic': 'رَبَّنَا',
      'transliteration': "Rabbenâ âtinâ fi'd-dünyâ haseneten.",
      'meaning': 'Rabbimiz',
      'source': 'Kur\'an-ı Kerim',
      'reference': '2:201',
      'audio': 'assets/audio/duas/quran_002_201.mp3',
      'image': 'assets/images/duas/quran_dua_2_201.png',
    });
    expect(dua.order, 1);
    expect(dua.surahNumber, 2);
    expect(dua.transliteration, "Rabbenâ âtinâ fi'd-dünyâ haseneten.");
    expect(DuaEntry.fromDua(dua).fullReading, "Rabbenâ âtinâ fi'd-dünyâ haseneten.");
    expect(dua.displayReference, 'Kur\'an-ı Kerim • 2:201');
    expect(DuaEntry.fromDua(dua).audio, 'assets/audio/duas/quran_002_201.mp3');
    expect(Dua.fromJson(dua.toJson()).id, 'quran_dua_2_201');
  });

  test('AsmaulHusna round-trip JSON', () {
    final asma = AsmaulHusna.fromJson({
      'id': 1,
      'arabic': 'الرَّحْمَنُ',
      'name': 'Er-Rahmân',
      'meaning': 'Çok merhamet eden',
      'childExplanation': 'Çok merhamet eden.',
      'audio': 'assets/audio/asma/01.mp3',
    });
    expect(asma.id, 1);
  });

  test('PrayerDua maps a namaz dua item', () {
    final dua = PrayerDua.fromJson({
      'order': 5,
      'id': 'subhaneke',
      'type': 'prayer_dua',
      'title': 'Sübhâneke',
      'arabic': 'سُبْحَانَكَ',
      'transliteration': 'Sübhâneke',
      'meaning': 'Allahım',
      'usage': 'Namazın başında',
      'source': 'Ebû Dâvûd',
    });
    expect(dua.order, 5);
    expect(dua.position, 'Namazın başında');
    expect(dua.displayArabic, 'سُبْحَانَكَ');
    expect(dua.reference, 'Ebû Dâvûd');
  });

  test('PrayerDua maps a surah item with verses', () {
    final dua = PrayerDua.fromJson({
      'order': 6,
      'id': 'surah_1',
      'type': 'surah',
      'title': 'Fâtiha Suresi',
      'surahNumber': 1,
      'source': "Kur'an-ı Kerim",
      'sourceReference': 'Sure 1',
      'verses': [
        {
          'ayahNo': 1,
          'arabic': 'بِسْمِ',
          'transliteration': 'Bismillâhirrahmânirrahîm.',
          'meal': 'Rahmân',
        },
        {
          'ayahNo': 2,
          'arabic': 'الْحَمْدُ',
          'transliteration': 'Elhamdü lillâhi rabbil âlemîn.',
          'meal': 'Hamd',
        },
      ],
    });
    expect(dua.verses, hasLength(2));
    expect(dua.surahNumber, 1);
    expect(dua.displayArabic.contains('بِسْمِ'), isTrue);
    expect(dua.displayMeaning.contains('Hamd'), isTrue);
    expect(dua.reference, "Kur'an-ı Kerim • Sure 1");
    expect(DuaEntry.fromPrayerDua(dua).verses.first.ayahNo, 1);
    expect(
      DuaEntry.fromPrayerDua(dua).fullReading,
      'Bismillâhirrahmânirrahîm.\nElhamdü lillâhi rabbil âlemîn.',
    );
  });

  test('IlmihalLesson maps the new lessons schema', () {
    final lesson = IlmihalLesson.fromJson({
      'order': 2,
      'id': 'iman_sartlari',
      'category': 'iman',
      'title': 'İmanın Şartları',
      'summary': 'İmanın altı temel esasını öğren.',
      'keyPoints': ['Allah\'a iman', 'Meleklere iman'],
      'memorization': 'Allah\'a iman',
      'source': 'Diyanet Temel Dini Bilgiler',
    });
    expect(lesson.order, 2);
    expect(lesson.keyPoints, hasLength(2));
    expect(lesson.sourceReference, 'Diyanet Temel Dini Bilgiler');
  });

  test('Prophet maps the peygamberler.json schema', () {
    final prophet = Prophet.fromJson({
      'order': 1,
      'id': 'adem',
      'name': 'Âdem',
      'arabicName': 'آدَم',
      'shortTitle': 'İlk insan ve peygamber',
      'summary': 'Kur’an’da anlatılır.',
      'lessons': ['Sorumluluk', 'Tevbe'],
      'quranReferences': ['Bakara 2:30-39', 'Tâhâ 20:115-123'],
      'image': 'assets/images/prophets/adem.png',
      'audio': 'assets/audio/prophets/adem.mp3',
    });
    expect(prophet.order, 1);
    expect(prophet.quranReferences, hasLength(2));
    expect(prophet.lessons.first, 'Sorumluluk');
    expect(prophet.quranReferencesText.contains('Bakara'), isTrue);
    expect(prophet.honorificName, 'Hz. Âdem');
  });

  test('Prophet displayName and roleTitle come from JSON', () {
    final prophet = Prophet.fromJson({
      'id': 'muhammed',
      'name': 'Muhammed',
      'arabicName': 'مُحَمَّد',
      'quranReferences': ['Ahzâb 33:40'],
      'illustrationPolicy': 'symbolic_only',
      'sourceName': "Kur'an-ı Kerim",
      'summary': 'Son peygamber',
      'displayName': 'Hz. Muhammed ﷺ',
      'roleTitle': 'Son Peygamber',
    });
    expect(prophet.name, 'Muhammed');
    expect(prophet.choiceName, 'Hz. Muhammed ﷺ');
    expect(prophet.honorificName, 'Hz. Muhammed ﷺ');
    expect(prophet.roleTitle, 'Son Peygamber');
  });

  test('PrayerLesson reads visualSteps from JSON', () {
    final lesson = PrayerLesson.fromJson({
      'id': 'prayer',
      'title': 'Namaz',
      'sourceName': 'Diyanet',
      'steps': [
        {'id': 'ruku', 'order': 1, 'title': 'Rükû', 'description': 'Tesbih'},
      ],
      'visualSteps': [
        {
          'id': 'ruku',
          'number': 6,
          'title': 'Rükû',
          'prompt': "Rükûya vardıktan sonra 3 kere Sübhâne Rabbiye’l-Azîm deriz.",
          'image': 'assets/images/prayer/step06_ruku.png',
          'kind': 'farz',
          'duaId': 'ruku',
        },
      ],
    });
    expect(lesson.visualSteps, hasLength(1));
    expect(lesson.visualSteps.first['duaId'], 'ruku');
  });

  test('PrayerLesson reads rakat counts from JSON', () {
    final lesson = PrayerLesson.fromJson({
      'id': 'prayer',
      'title': 'Namaz',
      'sourceName': 'Diyanet',
      'steps': [
        {'id': 'ruku', 'order': 1, 'title': 'Rükû', 'description': 'Tesbih'},
      ],
      'rakats': [
        {
          'id': 'fajr',
          'title': 'Sabah',
          'farz': 2,
          'summary': '2 rekat farz',
          'detail': '2 sünnet + 2 farz',
        },
      ],
    });
    expect(lesson.rakats, hasLength(1));
    expect(lesson.rakats.first['farz'], 2);
    expect(lesson.rakats.first['title'], 'Sabah');
  });

  test('MoralityLesson maps the guzel_ahlak.json schema', () {
    final lesson = MoralityLesson.fromJson({
      'order': 1,
      'id': 'dogruluk',
      'title': 'Doğruluk',
      'category': 'temel_degerler',
      'shortMessage': 'Doğruyu söylemek güven oluşturur.',
      'childExplanation': 'Doğruyu söylemek güzel ahlaktır.',
      'dailyChallenge': 'Bugün doğruyu söyle.',
      'quranReferences': ['Ahzâb 33:70'],
      'hadithReference': 'Riyâzü\'s-Sâlihîn; doğruluk bahsi',
      'image': 'assets/images/morality/dogruluk.png',
      'audio': 'assets/audio/morality/dogruluk.mp3',
    });
    expect(lesson.order, 1);
    expect(lesson.lesson, 'Doğruyu söylemek güzel ahlaktır.');
    expect(lesson.quranReferences, hasLength(1));
    expect(lesson.source.contains('Ahzâb'), isTrue);
  });

  test('StoryItem maps kissalar.json scenes', () {
    final story = StoryItem.fromJson({
      'id': 'adem_ve_yaratilis',
      'order': 1,
      'title': 'Hz. Âdem ve İlk İnsan',
      'category': 'peygamber_kissalari',
      'summary': 'Sorumluluk ve tevbe anlatılır.',
      'scenes': [
        {
          'order': 1,
          'title': 'Yaratılış',
          'text': 'Kur\'an\'da anlatılır.',
          'references': ['Bakara 2:30'],
        },
      ],
      'lessons': ['Sorumluluk', 'Tevbe'],
      'reflection': 'Hata yaptığımızda doğru olan nedir?',
      'quranReferences': ['Bakara 2:30-39'],
      'image': 'assets/images/qissalar/adem_ve_yaratilis.png',
    });
    expect(story.order, 1);
    expect(story.scenes, hasLength(1));
    expect(story.scenes.first.references.first, 'Bakara 2:30');
    expect(story.lessons, contains('Tevbe'));
  });

  test('Mushaf groups verses by sayfa and keeps JSON page numbers', () {
    final pages = MushafPageData.group([
      QuranVerse.fromJson({
        'ayet_id': 1,
        'sure_id': 1,
        'ayet_no': 1,
        'sayfa': 0,
        'metin': {'arapca': 'بِسْمِ اللّٰهِ', 'meal': 'Rahmân'},
      }),
      QuranVerse.fromJson({
        'ayet_id': 8,
        'sure_id': 2,
        'ayet_no': 1,
        'sayfa': 1,
        'metin': {'arapca': 'الم', 'meal': 'Elif Lâm Mîm'},
      }),
    ]);
    expect(pages, hasLength(2));
    expect(pages.first.displayNumber, 0);
    expect(pages.first.jsonPage, 0);
    expect(pages.last.displayNumber, 1);
    expect(pages.last.jsonPage, 1);
    expect(pages.last.verses.first.displayPage, 1);
  });

  test('mushaf juz ranges start at 0–20 then 21–40', () {
    expect(mushafJuzForPage(0), 1);
    expect(mushafJuzForPage(20), 1);
    expect(mushafJuzForPage(21), 2);
    expect(mushafJuzForPage(40), 2);
    expect(mushafJuzForPage(41), 3);
    expect(mushafJuzForPage(60), 3);
    expect(mushafJuzForPage(61), 4);
    expect(mushafJuzForPage(580), 29);
    expect(mushafJuzForPage(581), 30);
    expect(mushafJuzForPage(603), 30);
    expect(mushafFirstPageForJuz(1), 0);
    expect(mushafFirstPageForJuz(2), 21);
    expect(mushafFirstPageForJuz(30), 581);
    expect(mushafPageRangeForJuz(1), (0, 20));
    expect(mushafPageRangeForJuz(2), (21, 40));
    expect(mushafPageRangeForJuz(29), (561, 580));
    expect(mushafPageRangeForJuz(30), (581, 603));
    expect(mushafJuzFromInput('1'), 1);
    expect(mushafJuzFromInput('0'), 1);
    expect(mushafJuzFromInput('0-20'), 1);
    expect(mushafJuzFromInput('0 – 20'), 1);
    expect(mushafJuzFromInput('21-40'), 2);
    expect(mushafJuzFromInput('30'), 30);
    expect(mushafJuzFromInput('31'), isNull);
  });

  test('sajdah ayahs are the given 14 verses', () {
    const expected = <(int, int)>[
      (7, 206),
      (13, 15),
      (16, 49),
      (17, 107),
      (19, 58),
      (22, 18),
      (38, 24),
      (25, 60),
      (27, 25),
      (32, 15),
      (41, 37),
      (53, 62),
      (84, 21),
      (96, 19),
    ];
    expect(mushafSajdahAyahs, expected);
    for (final ayah in expected) {
      expect(mushafIsSajdahAyah(ayah.$1, ayah.$2), isTrue);
    }
    expect(mushafIsSajdahAyah(22, 77), isFalse);
    expect(mushafIsSajdahAyah(16, 50), isFalse);
    expect(mushafIsSajdahAyah(1, 1), isFalse);
  });

  test('TurkishNumber writes page labels in Turkish', () {
    expect(TurkishNumber.words(1), 'bir');
    expect(TurkishNumber.words(12), 'on iki');
    expect(TurkishNumber.words(100), 'yüz');
    expect(TurkishNumber.words(101), 'yüz bir');
    expect(TurkishNumber.words(604), 'altı yüz dört');
    expect(TurkishNumber.pageLabel(12), '12. sayfa');
    expect(TurkishNumber.arabicIndic(12), '١٢');
  });

  test('Peygamberler kitabı page images are numbered from one', () {
    expect(
      PeygamberlerKitabi.pageImage(1),
      'assets/images/books/peygamberler/page_01.jpg',
    );
    expect(
      PeygamberlerKitabi.pageImage(49),
      'assets/images/books/peygamberler/page_49.jpg',
    );
    expect(PeygamberlerKitabi.chapters.first.page, 9);
    expect(PeygamberlerKitabi.firstContentPage, 9);
    expect(
      PeygamberlerKitabi.pageImage(PeygamberlerKitabi.firstContentPage),
      'assets/images/books/peygamberler/page_09.jpg',
    );
  });

  test('ZikrCollectGame builds rounds from dhikr meanings', () {
    final catalog = [
      Dhikr.fromJson({
        'id': 'a',
        'title': 'Sübhânallah',
        'meaning': 'Allah\'ı tenzih ederim.',
      }),
      Dhikr.fromJson({
        'id': 'b',
        'title': 'Elhamdülillâh',
        'meaning': 'Hamd Allah\'a mahsustur.',
      }),
      Dhikr.fromJson({
        'id': 'c',
        'title': 'Allahü Ekber',
        'meaning': 'Allah en büyüktür.',
      }),
    ];
    final rounds = ZikrCollectGame.build(
      catalog,
      choiceCount: 3,
      random: Random(1),
    );
    expect(rounds, hasLength(3));
    expect(
      rounds.every((round) => round.choices.any((item) => item.id == round.target.id)),
      isTrue,
    );
    expect(rounds.every((round) => round.choices.length == 3), isTrue);
  });

  test('dailySeed stays stable for the same calendar day', () {
    final date = DateTime(2026, 8, 16);
    expect(dailySeed(date), 20260816);
    expect(pickDaily(['a', 'b', 'c'], now: date), isNotEmpty);
  });

  test('JsonMap extracts list or items/ayet/steps objects', () {
    expect(JsonMap.extractList([{'id': 1}]).first['id'], 1);
    expect(
      JsonMap.extractList({'ayet': [{'id': 2}]}, itemsKey: 'ayet').first['id'],
      2,
    );
  });
}
