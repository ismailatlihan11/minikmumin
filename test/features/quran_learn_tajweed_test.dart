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
