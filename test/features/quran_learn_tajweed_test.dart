import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_practice.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_audio.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_nav.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_tajweed_marks.dart';

void main() {
  test('elifba path is letters, forms, harakat, then short surahs', () {
    expect(elifbaPathIds, [1, 9, 2, 5]);
    expect(elifbaDrillIds, [3, 4, 11, 12, 13]);
    expect(elifbaTajweedIds, [6]);
    expect(elifbaReadIds, [7, 8]);
  });

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
    const ra = QuranArabicLetter(
      id: 'letter_10',
      order: 10,
      letter: 'ر',
      name: 'Ra',
      approximateTurkishSound: 'r (kalın)',
      connectionType: 'right_only',
      forms: QuranLetterForms(
        isolated: 'ر',
        initial: 'ر',
        medial: 'ـر',
        finalForm: 'ـر',
      ),
      connectsToNext: false,
    );
    expect(heavy.isHeavySound, isTrue);
    expect(light.isHeavySound, isFalse);
    expect(ra.isHeavySound, isTrue);
    expect(light.isLispSound, isFalse);
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
    expect(quranLearnSukunJoinGlyph(ba, 'fatha'), 'أَبْ');
    expect(quranLearnSukunJoinGlyph(ba, 'kasra'), 'إِبْ');
    expect(quranLearnSukunJoinGlyph(ba, 'damma'), 'أُبْ');
    expect(quranLearnShaddaUnfold('ب'), 'بْ + بَ');
    expect(quranLearnShaddaUnfold('ب', 'kasra'), 'بْ + بِ');
    expect(quranLearnShaddaEquation('ب'), 'بْ + بَ = بَّ');
    expect(quranLearnShaddaGlyph('ب', 'kasra'), 'بِّ');
    expect(quranLearnShaddaGlyph('ب', 'damma'), 'بُّ');
    expect(quranLearnSukunLetters([elif, ba]), [ba]);
    expect(quranLearnLetterByGlyph([elif, ba], 'ب'), ba);
    const bismi = QuranWord(
      id: 'word_02',
      arabic: 'بِسْمِ',
      reading: 'bismi',
      meaningTr: 'adıyla',
      quranReference: '1:1',
    );
    const rabbi = QuranWord(
      id: 'word_04',
      arabic: 'رَبِّ',
      reading: 'rabbi',
      meaningTr: 'Rabb',
      quranReference: '1:2',
    );
    const allah = QuranWord(
      id: 'word_01',
      arabic: 'الله',
      reading: 'Allâh',
      meaningTr: 'Allah',
      quranReference: '2:255',
    );
    expect(quranLearnWordsWithMark([bismi, rabbi, allah], 'ْ'), [bismi]);
    expect(quranLearnWordsWithMark([bismi, rabbi, allah], 'ّ'), [rabbi]);
    expect(
      quranLearnHarakatReviewWords([bismi, rabbi, allah]).map((word) => word.id),
      ['word_02', 'word_04'],
    );
    expect(quranLearnParseAyahRef('1:2'), (1, 2));
    expect(quranLearnParseAyahRef('112:1'), (112, 1));
    expect(quranLearnTajweedReference('1:2'), 'Fâtiha 1:2');
    expect(
      QuranLearnAudio.sukunTripletPath('assets/audio/quran_learn/alphabet/ba.mp3'),
      'assets/audio/quran_learn/sukun/ba_triplet.mp3',
    );
    expect(
      QuranLearnAudio.sukunJoinPath(
        'assets/audio/quran_learn/alphabet/ba.mp3',
        'kasra',
      ),
      'assets/audio/quran_learn/sukun/ba_join_kasra.mp3',
    );
    expect(
      QuranLearnAudio.shaddaHarekePath(
        'assets/audio/quran_learn/alphabet/ba.mp3',
        'damma',
      ),
      'assets/audio/quran_learn/shadda/ba_shadda_damma.mp3',
    );
  });

  test('tajweed example audio uses a unique clip per example', () {
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_08',
        index: 0,
        jsonAudio: 'assets/audio/quran_learn/tajweed/ihfa.mp3',
      ),
      'assets/audio/quran_learn/tajweed/tajweed_08_1.mp3',
    );
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_15',
        index: 0,
        jsonAudio: 'assets/audio/quran_learn/tajweed/idgham.mp3',
      ),
      'assets/audio/quran_learn/tajweed/tajweed_15_1.mp3',
    );
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_07',
        index: 1,
        jsonAudio: null,
      ),
      'assets/audio/quran_learn/tajweed/tajweed_07_2.mp3',
    );
  });

  test('nun-sakin compare uses first examples of izhar, ihfa and idgham', () {
    final cards = quranLearnCompareCards(
      lessonId: 'tajweed_08',
      lessons: [
        ..._lessons,
        const QuranTajweedLesson(
          id: 'tajweed_08',
          order: 6,
          title: 'İhfâ',
          shortDescription: '',
          explanation: '',
          examples: [
            QuranTajweedExample(
              arabic: 'مِنْ شَرِّ',
              reference: '113:2',
              focus: 'نْ ش',
              audio: 'assets/audio/quran_learn/tajweed/ihfa.mp3',
            ),
          ],
        ),
        const QuranTajweedLesson(
          id: 'tajweed_15',
          order: 9,
          title: "İdğâm-ı Mea'l-Ğunne",
          shortDescription: '',
          explanation: '',
          examples: [
            QuranTajweedExample(
              arabic: 'فَمَنْ یَعْمَلْ',
              reference: '99:7',
              focus: 'نْ ی',
              audio: 'assets/audio/quran_learn/tajweed/idgham.mp3',
            ),
          ],
        ),
      ],
    );
    expect(cards.map((card) => card.label), ['İzhâr', 'İhfâ', 'Gunnesiz', 'Gunneli']);
    expect(cards.map((card) => card.arabic), [
      'اَنْعَمْتَ',
      'مِنْ شَرِّ',
      'یَكُنْ لَهُ',
      'فَمَنْ یَعْمَلْ',
    ]);
  });

  test('short surahs and excerpts are distinct', () {
    const bakara15 = QuranLearningSurah(
      surahNumber: 2,
      nameAr: 'البقرة',
      nameTr: 'Bakara 1–5',
      ayahCount: 5,
      priority: 2,
      ayahFrom: 1,
      ayahTo: 5,
    );
    const fatiha = QuranLearningSurah(
      surahNumber: 1,
      nameAr: 'الفاتحة',
      nameTr: 'Fâtiha',
      ayahCount: 7,
      priority: 1,
    );
    expect(fatiha.isCompleteSurah, isTrue);
    expect(bakara15.isExcerpt, isTrue);
    expect(bakara15.id, '2-1-5');
  });

  test('levels 5, 7 and 8 split short surahs from excerpts', () {
    final json = jsonDecode(
      File('assets/data/kur_an_ogrenme_veri_paketi.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final pack = QuranLearningPack.fromJson(json);
    expect(
      pack.surahsForLevel(5).map((surah) => surah.id),
      [
        '1',
        '105',
        '106',
        '107',
        '108',
        '109',
        '110',
        '111',
        '112',
        '113',
        '114',
        '103',
      ],
    );
    expect(
      pack.surahsForLevel(7, kind: 'ql_practice').map((surah) => surah.id),
      ['2-1-5', '59-22-24', '2-255', '2-285-286'],
    );
    expect(
      pack.surahsForLevel(8, kind: 'ql_tajweed_read').map((surah) => surah.id),
      ['1', '112', '113', '114'],
    );
    expect(
      pack.surahsForLevel(5).every((surah) => surah.isCompleteSurah),
      isTrue,
    );
    expect(
      pack.surahsForLevel(7, kind: 'ql_practice').every((surah) => surah.isExcerpt),
      isTrue,
    );
  });

  test('alıştırma adds heavy, mahraj and games lessons', () {
    final json = jsonDecode(
      File('assets/data/kur_an_ogrenme_veri_paketi.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final pack = QuranLearningPack.fromJson(json);
    expect(pack.levelById(9)?.screen, 'letter_forms');
    expect(pack.levelById(10)?.screen, 'letter_review');
    expect(pack.levelById(11)?.screen, 'heavy_light');
    expect(pack.levelById(12)?.screen, 'mahraj');
    expect(pack.levelById(13)?.screen, 'games');
    expect(pack.itemsForLevel(11).map((item) => item.id), ['heavy', 'light']);
    expect(pack.itemsForLevel(13).length, 13);
    expect(
      elifbaDrillIds.map((id) => pack.levelById(id)?.id),
      [3, 4, 11, 12, 13],
    );
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
