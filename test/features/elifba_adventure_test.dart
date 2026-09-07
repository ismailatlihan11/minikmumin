import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_worlds.dart';

ElifbaPack _loadPack() {
  final file = File('assets/data/elifba_tecvid_dersleri_eksiksiz.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return ElifbaPack.fromJson(json);
}

ElifbaLesson _byTitle(ElifbaPack pack, String needle) {
  return pack.lessons.firstWhere(
    (lesson) => lesson.title.toLowerCase().contains(needle.toLowerCase()),
  );
}

void main() {
  final pack = _loadPack();

  test('pack loads every lesson with a quiz', () {
    expect(pack.lessons.length, 34);
    for (final lesson in pack.lessons) {
      expect(lesson.id, greaterThan(0));
      expect(lesson.title, isNotEmpty);
      expect(lesson.quiz, isNotEmpty, reason: 'Ders ${lesson.id} testsiz');
    }
  });

  test('lesson 1 introduces all letters with their names', () {
    final lesson = pack.lessons.first;
    final items = lesson.rich.objective.isEmpty ? lesson.letters : lesson.letters;
    expect(items.length, greaterThanOrEqualTo(28));
    for (final item in items) {
      expect(item.letter, isNotEmpty);
      expect(item.name, isNotEmpty, reason: '${item.letter} isimsiz');
    }
  });

  test('heavy letter lesson keeps the fixed seven and treats Ra as special', () {
    final lesson = _byTitle(pack, 'Kalın Harfleri');
    final letters = lesson.tripleFormTable.map((row) => row.letter).toSet();
    expect(letters, {'خ', 'ص', 'ض', 'غ', 'ط', 'ق', 'ظ'});
    expect(letters.contains('ر'), isFalse);
    final special = lesson.specialLetters;
    expect(special.single.letter, 'ر');
    expect(special.single.thickWhen, containsAll(<String>['رَ', 'رُ']));
    expect(special.single.thinWhen, contains('رِ'));
  });

  test('lisp lesson marks zı as both lisp and heavy', () {
    final lesson = _byTitle(pack, 'Peltek Harfleri');
    final letters = lesson.tripleFormTable.map((row) => row.letter).toList();
    expect(letters, ['ث', 'ذ', 'ظ']);
    final review = _byTitle(pack, 'Genel Tekrar');
    expect(review.categoryTables['kalin_harfler']!.any((r) => r.letter == 'ظ'), isTrue);
    expect(review.categoryTables['peltek_harfler']!.any((r) => r.letter == 'ظ'), isTrue);
  });

  test('review lesson exposes drag groups for thin, heavy and lisp', () {
    final lesson = _byTitle(pack, 'Genel Tekrar');
    expect(lesson.categoryTables.keys,
        containsAll(<String>['kalin_harfler', 'peltek_harfler', 'ince_harfler']));
    expect(lesson.reviewGroups, isNotEmpty);
  });

  test('fetha, kasra and damma lessons teach all 28 letters plus 10+ words', () {
    for (final needle in ['Üstün', 'Esre', 'Ötre']) {
      final lesson = _byTitle(pack, needle);
      final table = pack.teachingTableFor(lesson);
      expect(table.length, 28, reason: '$needle tablosu eksik');
      final mark = lesson.rule!.symbol;
      for (final row in table) {
        expect(row.letter, isNotEmpty);
        expect(row.name, isNotEmpty, reason: '${row.letter} ismi yok');
        expect(row.marked.contains(mark), isTrue,
            reason: '${row.letter} yanlış hareke: ${row.marked}');
        expect(row.reading, isNotEmpty);
      }
      expect(lesson.wordExamples.length, greaterThanOrEqualTo(10));
      for (final word in lesson.wordExamples) {
        expect(word.text, isNotEmpty);
        expect(word.reading, isNotEmpty, reason: '${word.text} okunuşsuz');
        expect(word.meaning, isNotEmpty, reason: '${word.text} anlamsız');
      }
    }
  });

  test('letter name and reading stay separate fields', () {
    final fetha = _byTitle(pack, 'Üstün');
    final be = pack
        .teachingTableFor(fetha)
        .firstWhere((row) => row.letter == 'ب');
    expect(be.name, 'Be');
    expect(be.marked, 'بَ');
    expect(be.reading, 'ba');
    expect(be.name.toLowerCase(), isNot(be.reading.toLowerCase()));
  });

  test('shadda is only taught together with a haraka', () {
    final lesson = _byTitle(pack, 'Şedde');
    final tables = lesson.harakeTables;
    expect(tables.keys, containsAll(<String>['fetha', 'kasra', 'damma']));
    const marks = {'fetha': 'َ', 'kasra': 'ِ', 'damma': 'ُ'};
    for (final entry in tables.entries) {
      expect(entry.value.length, greaterThanOrEqualTo(20));
      for (final row in entry.value) {
        expect(row.marked.contains('ّ'), isTrue);
        expect(row.marked.contains(marks[entry.key]!), isTrue,
            reason: '${row.marked} harekesiz şedde');
      }
    }
    // Harekesiz şedde tablosu hiçbir derste gösterilmez.
    for (final other in pack.lessons) {
      expect(pack.teachingTableFor(other).any((row) => ElifbaPack
          .isStandaloneShaddaTable(<ElifbaLetterRow>[row])), isFalse,
          reason: 'Ders ${other.id} tek başına şedde gösteriyor');
    }
    expect(lesson.wordExamples.length, greaterThanOrEqualTo(10));
    expect(lesson.wordExamples.every((w) => w.text.contains('ّ')), isTrue);
  });

  test('cezm lesson uses the sukun table, not the shadda one', () {
    final lesson = _byTitle(pack, 'Cezm');
    final table = pack.teachingTableFor(lesson);
    expect(table.length, 28);
    expect(table.every((row) => row.marked.contains('ْ')), isTrue);
  });

  test('med table follows the med lesson, not the tenvin lesson', () {
    final lesson = _byTitle(pack, 'Med Harfleri');
    final rows = pack.medTableFor(lesson);
    expect(rows.map((row) => row.letter), containsAll(<String>['ا', 'و', 'ي']));
    for (final row in rows) {
      expect(row.examples, isNotEmpty);
    }
    expect(pack.medTableFor(_byTitle(pack, 'Tenvin')), isEmpty);
  });

  test('tajweed letter tables land on the matching rule lesson', () {
    const expected = {
      'İzhâr-ı Halkî': 'ءهعحغخ',
      'İdğam': 'يرملون',
      'İhfâ': 'تثجدذزسشصضطظفقك',
    };
    for (final entry in expected.entries) {
      final table = pack.teachingTableFor(_byTitle(pack, entry.key));
      expect(table.map((row) => row.letter).join(), entry.value);
    }
    expect(pack.decisionTreeFor(_byTitle(pack, 'Nun Sâkin')), isNotEmpty);
    expect(pack.decisionTreeFor(_byTitle(pack, 'Kalkale')), isEmpty);
  });

  test('ra lesson never claims ra is always heavy', () {
    final lesson = _byTitle(pack, 'Ra Harfi');
    final readings = {for (final row in lesson.raTable) row.form: row.reading};
    expect(readings['رَ'], contains('kalın'));
    expect(readings['رُ'], contains('kalın'));
    expect(readings['رِ'], contains('ince'));
    expect(lesson.askPairs, isNotEmpty);
  });

  test('tajweed lessons expose rules and examples', () {
    for (final needle in ['İzhâr', 'İdğam', 'İklâb', 'İhfâ', 'Mim Sâkin', 'Gunne']) {
      final lesson = _byTitle(pack, needle);
      final filled = lesson.examples.isNotEmpty ||
          lesson.rules.isNotEmpty ||
          pack.teachingTableFor(lesson).isNotEmpty;
      expect(filled, isTrue, reason: '$needle içeriği boş');
    }
  });

  test('makhraj lesson exposes tappable regions', () {
    final lesson = _byTitle(pack, 'Mahreç');
    expect(lesson.groups.length, greaterThanOrEqualTo(3));
    for (final group in lesson.groups) {
      expect(group.letters, isNotEmpty);
    }
  });

  test('final lesson is a graded exam', () {
    final lesson = pack.lessons.last;
    expect(lesson.isFinal, isTrue);
    expect(lesson.quiz.length, greaterThanOrEqualTo(10));
    expect(lesson.completion?.passPercent, greaterThan(0));
  });

  test('adventure map is derived from lesson data and covers every lesson', () {
    final worlds = ElifbaWorlds.of(pack);
    expect(worlds.length, greaterThanOrEqualTo(4));
    final mapped = <int>{for (final world in worlds) ...world.lessonIds};
    expect(mapped.length, pack.lessons.length);
    expect(worlds.last.id, 'final');
    expect(ElifbaWorlds.badgeForLesson(pack, pack.lessons.first.id), 'İlk Harfim');
    expect(
      ElifbaWorlds.badgeForLesson(pack, pack.lessons.last.id),
      'Elifbâ Kahramanı',
    );
  });
}
