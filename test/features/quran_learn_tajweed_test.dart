import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_practice.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_tajweed_marks.dart';

void main() {
  test('formats mushaf references with surah names', () {
    expect(quranLearnTajweedReference('1:7'), 'Fâtiha 1:7');
    expect(quranLearnTajweedReference('112:4'), 'İhlâs 112:4');
    expect(quranLearnTajweedReference('örnek'), 'örnek');
  });

  test('finds taught tajweed marks in Fatiha 1:7', () {
    const arabic =
        'صِرَاطَ الَّذٖینَ اَنْعَمْتَ عَلَیْهِمْۙ غَیْرِ الْمَغْضُوبِ عَلَیْهِمْ وَلَا الضَّٓالّٖینَ';
    final hits = quranLearnTajweedHits(arabic: arabic, lessons: _lessons);
    final titles = hits.map((hit) => hit.title).toSet();
    expect(titles, containsAll(['Şedde', 'Cezm (Sükûn)', 'Med', 'İzhâr', 'Vakıf']));
  });

  test('matches İdğam example from İhlas 112:4', () {
    const arabic = 'وَلَمْ یَكُنْ لَهُ كُفُوًا اَحَدٌ';
    final hits = quranLearnTajweedHits(arabic: arabic, lessons: _lessons);
    final titles = hits.map((hit) => hit.title).toSet();
    expect(titles, contains('İdğam'));
    expect(titles, contains('Tenvin'));
  });

  test('builds passage ids without colliding Bakara entries', () {
    const bakara15 = QuranLearningSurah(
      surahNumber: 2,
      nameAr: 'البقرة',
      nameTr: 'Bakara 1–5',
      ayahCount: 5,
      priority: 2,
      ayahFrom: 1,
      ayahTo: 5,
    );
    const kursi = QuranLearningSurah(
      surahNumber: 2,
      nameAr: 'البقرة',
      nameTr: "Âyetü'l-Kürsî",
      ayahCount: 1,
      priority: 14,
      ayahFrom: 255,
      ayahTo: 255,
    );
    const fatiha = QuranLearningSurah(
      surahNumber: 1,
      nameAr: 'الفاتحة',
      nameTr: 'Fâtiha',
      ayahCount: 7,
      priority: 1,
    );
    expect(bakara15.id, '2-1-5');
    expect(kursi.id, '2-255');
    expect(fatiha.id, '1');
    expect(bakara15.listSubtitle, contains('2:1–5'));
  });

  test('hareke teaching glyphs and elif rules', () {
    expect(quranLearnTeachingGlyph('fatha'), 'أَ');
    expect(quranLearnTeachingGlyph('sukun'), 'بْ');
    expect(quranLearnHarakaUsesElif('fatha'), isTrue);
    expect(quranLearnHarakaUsesElif('tanwin_fath'), isFalse);
  });

  test('fetha teach line uses JSON e/a and kalın examples', () {
    const fatha = QuranHaraka(
      id: 'fatha',
      order: 1,
      name: 'Fetha',
      symbol: 'َ',
      readingRule: "Kısa 'a' sesi verir.",
      examples: [
        QuranHarakaExample(arabic: 'أَ', reading: 'e / a'),
        QuranHarakaExample(arabic: 'طَ', reading: 'ta (kalın)'),
      ],
    );
    const kasra = QuranHaraka(
      id: 'kasra',
      order: 4,
      name: 'Kesra',
      symbol: 'ِ',
      readingRule: "Kısa 'i' sesi verir.",
      examples: [],
    );
    expect(quranLearnHarakatTeachLine(fatha), contains("Kısa 'a' sesi verir."));
    expect(quranLearnHarakatTeachLine(fatha), contains("'e'"));
    expect(quranLearnHarakatTeachLine(fatha), contains("'a'"));
    expect(quranLearnHarakatTeachLine(kasra), "Kısa 'i' sesi verir.");
  });

  test('practice glyphs mark heavy letters from JSON sound field', () {
    const heavy = QuranArabicLetter(
      id: 'letter_16',
      order: 16,
      letter: 'ط',
      name: 'Tı',
      approximateTurkishSound: 'ta (kalın)',
      connectionType: 'connected',
      forms: QuranLetterForms(
        isolated: 'ط',
        initial: 'طـ',
        medial: 'ـطـ',
        finalForm: 'ـط',
      ),
      connectsToNext: true,
    );
    const light = QuranArabicLetter(
      id: 'letter_03',
      order: 3,
      letter: 'ت',
      name: 'Te',
      approximateTurkishSound: 't',
      connectionType: 'connected',
      forms: QuranLetterForms(
        isolated: 'ت',
        initial: 'تـ',
        medial: 'ـتـ',
        finalForm: 'ـت',
      ),
      connectsToNext: true,
    );
    expect(heavy.isHeavySound, isTrue);
    expect(light.isHeavySound, isFalse);
    expect(quranLearnPracticeGlyph(heavy, 'fatha'), 'طَ');
    expect(quranLearnPracticeGlyph(light, 'fatha'), 'تَ');
  });

  test('cezm triplet and shadda unfold stay on existing letters', () {
    const ba = QuranArabicLetter(
      id: 'letter_02',
      order: 2,
      letter: 'ب',
      name: 'Be',
      approximateTurkishSound: 'b',
      connectionType: 'connected',
      forms: QuranLetterForms(
        isolated: 'ب',
        initial: 'بـ',
        medial: 'ـبـ',
        finalForm: 'ـب',
      ),
      connectsToNext: true,
    );
    const elif = QuranArabicLetter(
      id: 'letter_01',
      order: 1,
      letter: 'ا',
      name: 'Elif',
      approximateTurkishSound: 'a',
      connectionType: 'right_only',
      forms: QuranLetterForms(
        isolated: 'ا',
        initial: 'ا',
        medial: 'ـا',
        finalForm: 'ـا',
      ),
      connectsToNext: false,
    );
    expect(quranLearnIsSukunLetter(ba), isTrue);
    expect(quranLearnIsSukunLetter(elif), isFalse);
    expect(quranLearnSukunTriplet(ba), 'أَبْ إِبْ أُبْ');
    expect(quranLearnShaddaUnfold('ب'), 'بْ + بَ');
    expect(quranLearnSukunLetters([elif, ba]), [ba]);
  });
}

final _lessons = [
  const QuranTajweedLesson(
    id: 'tajweed_01',
    order: 1,
    title: 'Med',
    shortDescription: '',
    explanation: '',
    examples: [
      QuranTajweedExample(
        arabic: 'الضَّٓالّٖینَ',
        reference: '1:7',
        focus: 'ضَّٓا',
      ),
    ],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_02',
    order: 2,
    title: 'Şedde',
    shortDescription: '',
    explanation: '',
    examples: [],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_03',
    order: 3,
    title: 'Cezm (Sükûn)',
    shortDescription: '',
    explanation: '',
    examples: [],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_04',
    order: 4,
    title: 'Tenvin',
    shortDescription: '',
    explanation: '',
    examples: [],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_07',
    order: 8,
    title: 'İdğam',
    shortDescription: '',
    explanation: '',
    examples: [
      QuranTajweedExample(
        arabic: 'یَكُنْ لَهُ',
        reference: '112:4',
        focus: 'نْ ل',
      ),
    ],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_10',
    order: 11,
    title: 'Vakıf',
    shortDescription: '',
    explanation: '',
    examples: [],
  ),
  const QuranTajweedLesson(
    id: 'tajweed_11',
    order: 7,
    title: 'İzhâr',
    shortDescription: '',
    explanation: '',
    examples: [
      QuranTajweedExample(
        arabic: 'اَنْعَمْتَ',
        reference: '1:7',
        focus: 'نْ ع',
      ),
    ],
  ),
];
