import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/utils/daily_seed.dart';
import 'package:minik_kalpler/core/utils/json_map.dart';
import 'package:minik_kalpler/data/models/asmaul_husna.dart';
import 'package:minik_kalpler/data/models/dua.dart';
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
    });
    expect(lesson.steps, hasLength(1));
    expect(lesson.steps.first.id, 'hands');
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
      'meaning': 'Rabbimiz',
      'source': 'Kur\'an-ı Kerim',
      'reference': '2:201',
      'audio': 'assets/audio/duas/quran_002_201.mp3',
      'image': 'assets/images/duas/quran_dua_2_201.png',
    });
    expect(dua.order, 1);
    expect(dua.surahNumber, 2);
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
        {'ayahNo': 1, 'arabic': 'بِسْمِ', 'meal': 'Rahmân'},
        {'ayahNo': 2, 'arabic': 'الْحَمْدُ', 'meal': 'Hamd'},
      ],
    });
    expect(dua.verses, hasLength(2));
    expect(dua.surahNumber, 1);
    expect(dua.displayArabic.contains('بِسْمِ'), isTrue);
    expect(dua.displayMeaning.contains('Hamd'), isTrue);
    expect(dua.reference, "Kur'an-ı Kerim • Sure 1");
    expect(DuaEntry.fromPrayerDua(dua).verses.first.ayahNo, 1);
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
      'displayName': 'Hz. Muhammed (sallallahu aleyhi ve sellem)',
      'roleTitle': 'Son Peygamber',
    });
    expect(prophet.name, 'Muhammed');
    expect(prophet.honorificName, 'Hz. Muhammed (sallallahu aleyhi ve sellem)');
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
