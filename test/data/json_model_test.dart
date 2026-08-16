import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/utils/daily_seed.dart';
import 'package:minik_kalpler/core/utils/json_map.dart';
import 'package:minik_kalpler/data/models/asmaul_husna.dart';
import 'package:minik_kalpler/data/models/dua.dart';
import 'package:minik_kalpler/data/models/hadith.dart';
import 'package:minik_kalpler/data/models/interactive_lesson.dart';
import 'package:minik_kalpler/data/models/quran_verse.dart';
import 'package:minik_kalpler/data/models/quiz.dart';

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
      'id': 'quiz_fatiha',
      'category': 'quran',
      'question': 'Test?',
      'xp': 5,
      'options': [
        {'id': 'a', 'text': 'Doğru yol', 'correct': true},
        {'id': 'b', 'text': 'Dünya malı', 'correct': false},
      ],
    });
    expect(question.correctOption?.id, 'a');
    expect(question.xp, 5);
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

  test('Dua and AsmaulHusna round-trip JSON', () {
    final dua = Dua.fromJson({
      'id': 'dua_1',
      'title': 'Rabbenâ Âtinâ',
      'type': 'Quranic Dua',
      'arabic': 'رَبَّنَا',
      'meaning': 'Rabbimiz',
      'reference': 'Bakara 2:201',
    });
    expect(Dua.fromJson(dua.toJson()).id, 'dua_1');

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
