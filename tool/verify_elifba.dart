// Elifbâ + Tecvid içerik kontrolü: `dart run tool/verify_elifba.dart`
// Ders içerikleri JSON'dan geldiği için kuralları burada de doğruluyoruz.
import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_letter_forms.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_quran_bridge.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_reading.dart';

var failures = 0;

void check(String label, bool ok, [String detail = '']) {
  if (ok) {
    stdout.writeln('  ok   $label');
  } else {
    failures += 1;
    stdout.writeln('  FAIL $label ${detail.isEmpty ? '' : '· $detail'}');
  }
}

ElifbaLesson byTitle(ElifbaPack pack, String needle) => pack.lessons.firstWhere(
      (lesson) => lesson.title.toLowerCase().contains(needle.toLowerCase()),
    );

/// `dart run tool/verify_elifba.dart --tablo` bütün harflerin üstün, esre ve
/// ötre okunuşunu listeler.
void printReadingTable() {
  stdout.writeln('Harf | Üstün | Esre | Ötre');
  for (final letter in ElifbaReading.consonants.keys) {
    if (letter.length != 1) continue;
    final row = [
      for (final mark in [
        ElifbaReading.fatha,
        ElifbaReading.kasra,
        ElifbaReading.damma,
      ])
        '$letter$mark = ${ElifbaReading.of(letter, mark)}',
    ];
    stdout.writeln('  ${row.join('  ·  ')}');
  }
}

void main(List<String> args) {
  if (args.contains('--tablo')) {
    printReadingTable();
    return;
  }
  final raw = File('assets/data/elifba_tecvid_dersleri_eksiksiz.json')
      .readAsStringSync();
  final quranRaw =
      File('assets/data/kur_an_ogrenme_veri_paketi.json').readAsStringSync();
  final quranPack =
      QuranLearningPack.fromJson(jsonDecode(quranRaw) as Map<String, dynamic>);
  final formsJson = ElifbaLetterFormsLesson.build(quranPack);
  final pack = ElifbaPack.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
    extras: [
      if (formsJson != null)
        ElifbaExtraLesson(afterLessonId: 1, json: formsJson),
    ],
    patches: ElifbaQuranBridge.patches(quranPack),
    hiddenTitles: const {ElifbaLetterFormsLesson.replacesTitle},
  );

  final cezmLesson = byTitle(pack, 'Cezm');
  check('Cezm dersinde en az 10 kelime örneği',
      cezmLesson.wordExamples.length >= 10,
      '${cezmLesson.wordExamples.length} kelime');
  check(
      'Cezm kelimelerinin hepsinde cezm var',
      cezmLesson.wordExamples.every((word) => word.text.contains('ْ')),
      cezmLesson.wordExamples.map((w) => w.text).take(3).join(' '));
  check('Cezm dersinde sâkin harf örnekleri', cezmLesson.examples.length >= 6,
      '${cezmLesson.examples.length} harf');
  for (final word in cezmLesson.wordExamples) {
    stdout.writeln('  ${word.text}  ${word.reading}  ${word.focus}');
  }

  final shaddaLesson = byTitle(pack, 'Şedde');
  check('Şedde dersinde en az 10 kelime örneği',
      shaddaLesson.wordExamples.length >= 10,
      '${shaddaLesson.wordExamples.length} kelime');
  check(
      'Şedde kelimelerinin hepsinde şedde var',
      shaddaLesson.wordExamples.every((word) => word.text.contains('ّ')),
      shaddaLesson.wordExamples.map((w) => w.text).take(3).join(' '));
  check(
      'Şeddeli harf örnekleri harekeli',
      shaddaLesson.examples
          .where((item) => item.text.contains('ّ'))
          .every((item) =>
              item.text.contains('َ') ||
              item.text.contains('ِ') ||
              item.text.contains('ُ')),
      shaddaLesson.examples.map((e) => e.text).join(' '));
  for (final word in shaddaLesson.wordExamples) {
    stdout.writeln('  ${word.text}  ${word.reading}  ${word.focus}');
  }
  check('Eski "Harflerin Kelimedeki Şekilleri" dersi haritada yok',
      pack.lessons.every((lesson) => lesson.id != 6) && pack.hidden.length == 1,
      '${pack.hidden.length} gizli ders');

  stdout.writeln('Ders sayısı: ${pack.lessons.length}');

  final forms = byTitle(pack, 'Harfler ve Şekilleri');
  check('"Harfler ve Şekilleri" 1. dersten hemen sonra',
      pack.orderOf(forms.id) == 2, 'sıra ${pack.orderOf(forms.id)}');
  check('Dört şekil tablosu Kur\'an serisiyle aynı',
      forms.letterForms.length == quranPack.letters.length,
      '${forms.letterForms.length} harf');
  check(
      'Her harfin dört şekli dolu',
      forms.letterForms.every((row) =>
          row.isolated.isNotEmpty &&
          row.initial.isNotEmpty &&
          row.medial.isNotEmpty &&
          row.finalForm.isNotEmpty &&
          row.name.isNotEmpty));
  check('Bütün derslerde quiz var',
      pack.lessons.every((lesson) => lesson.quiz.isNotEmpty));

  final first = pack.lessons.first;
  check('Ders 1 bütün harfleri isimleriyle veriyor',
      first.letters.length >= 28 && first.letters.every((l) => l.name.isNotEmpty),
      '${first.letters.length} harf');

  final heavy = byTitle(pack, 'Kalın Harfleri');
  final heavySet = heavy.tripleFormTable.map((r) => r.letter).toSet();
  check('7 sabit kalın harf',
      heavySet.length == 7 && !heavySet.contains('ر'), heavySet.join(' '));
  check('Ra özel harf olarak ayrı',
      heavy.specialLetters.any((s) => s.letter == 'ر' && s.thinWhen.contains('رِ')));

  final lisp = byTitle(pack, 'Peltek');
  check('Peltek harfler ث ذ ظ',
      lisp.tripleFormTable.map((r) => r.letter).join() == 'ثذظ');

  final review = byTitle(pack, 'Genel Tekrar');
  final cats = review.categoryTables;
  check('Genel tekrarda 3 kategori tablosu', cats.length == 3);
  check('ظ hem kalın hem peltek listesinde',
      (cats['kalin_harfler'] ?? []).any((r) => r.letter == 'ظ') &&
          (cats['peltek_harfler'] ?? []).any((r) => r.letter == 'ظ'));

  for (final needle in ['Üstün', 'Esre', 'Ötre']) {
    final lesson = byTitle(pack, needle);
    final table = pack.teachingTableFor(lesson);
    final mark = lesson.rule?.symbol ?? '';
    check('$needle dersinde 28 harf', table.length == 28, '${table.length}');
    check('$needle işaretleri doğru',
        table.isNotEmpty && table.every((r) => r.marked.contains(mark)));
    check('$needle harf adı + okunuş ayrı',
        table.every((r) => r.name.isNotEmpty && r.reading.isNotEmpty));
    final words = lesson.wordExamples;
    check('$needle en az 10 kelime', words.length >= 10, '${words.length}');
    check('$needle kelimelerde okunuş + anlam',
        words.every((w) => w.reading.isNotEmpty && w.meaning.isNotEmpty));
  }

  final fetha = byTitle(pack, 'Üstün');
  final be = pack.teachingTableFor(fetha).firstWhere((r) => r.letter == 'ب');
  // ب ince harftir: adı "Be", üstünlü okunuşu da "be". Ayrım kalın harflerde
  // görünür: ص harfinin adı "Sad", üstünlü okunuşu "sa (kalın)".
  final sad = pack.teachingTableFor(fetha).firstWhere((r) => r.letter == 'ص');
  check('Harf adı ve okunuş ayrı alanlarda',
      be.name == 'Be' && be.marked == 'بَ' && be.reading == 'be',
      '${be.name} / ${be.marked} / ${be.reading}');
  check('Kalın harfte ad ≠ okunuş',
      sad.name == 'Sad' && sad.reading.startsWith('sa'),
      '${sad.name} / ${sad.reading}');

  final shadda = byTitle(pack, 'Şedde');
  final tables = shadda.harakeTables;
  const vowels = {'fetha': 'َ', 'kasra': 'ِ', 'damma': 'ُ'};
  check('Şedde 3 hareke tablosu', tables.length == 3);
  for (final entry in tables.entries) {
    check('Şedde + ${entry.key} hep harekeli',
        entry.value.every((r) =>
            r.marked.contains('ّ') && r.marked.contains(vowels[entry.key]!)));
  }
  check('Şedde kelime örnekleri', shadda.wordExamples.length >= 10);
  final standalone = pack.lessons
      .where((l) => ElifbaPack.isStandaloneShaddaTable(pack.teachingTableFor(l)))
      .map((l) => l.id)
      .toList();
  check('Hiçbir derste tek başına şedde tablosu yok', standalone.isEmpty,
      standalone.join(','));

  final cezm = byTitle(pack, 'Cezm');
  final cezmTable = pack.teachingTableFor(cezm);
  check('Cezm dersinde cezmli tablo',
      cezmTable.length == 28 && cezmTable.every((r) => r.marked.contains('ْ')));

  final med = byTitle(pack, 'Med Harfleri');
  check('Med: elif, vav, ya',
      pack.medTableFor(med).map((r) => r.letter).toSet().containsAll({'ا', 'و', 'ي'}));
  check('Med tablosu tenvin dersinde görünmüyor',
      pack.medTableFor(byTitle(pack, 'Tenvin')).isEmpty);
  check('Kural ağacı nun sâkin dersinde',
      pack.decisionTreeFor(byTitle(pack, 'Nun Sâkin')).isNotEmpty &&
          pack.decisionTreeFor(byTitle(pack, 'Kalkale')).isEmpty);

  const tajweedLetters = {
    'İzhâr-ı Halkî': 'ءهعحغخ',
    'İdğam': 'يرملون',
    'İhfâ': 'تثجدذزسشصضطظفقك',
  };
  for (final entry in tajweedLetters.entries) {
    final lesson = byTitle(pack, entry.key);
    final table = pack.teachingTableFor(lesson);
    check('${entry.key} harf tablosu doğru derste',
        table.map((r) => r.letter).join() == entry.value,
        table.map((r) => r.letter).join());
  }

  final ra = byTitle(pack, 'Ra Harfi');
  final raMap = {for (final row in ra.raTable) row.form: row.reading};
  check('Ra kalın/ince ayrımı',
      (raMap['رَ'] ?? '').contains('kalın') &&
          (raMap['رُ'] ?? '').contains('kalın') &&
          (raMap['رِ'] ?? '').contains('ince'),
      raMap.toString());

  for (final needle in ['İzhâr', 'İdğam', 'İklâb', 'İhfâ', 'Mim Sâkin', 'Gunne']) {
    final lesson = byTitle(pack, needle);
    check(
      '$needle içeriği dolu',
      lesson.examples.isNotEmpty ||
          lesson.rules.isNotEmpty ||
          pack.teachingTableFor(lesson).isNotEmpty,
    );
  }

  final mahrec = byTitle(pack, 'Mahreç');
  check('Mahreç bölgeleri', mahrec.groups.length >= 3);

  final fatiha = byTitle(pack, 'Fâtiha');
  check('Fâtiha kelime çalışması', fatiha.verses.isNotEmpty || fatiha.examples.isNotEmpty);

  final surahs = byTitle(pack, 'Kısa Sûrelerle');
  check('Kısa sûreler', surahs.surahs.isNotEmpty);

  final last = pack.lessons.last;
  check('Final sınavı', last.isFinal && last.quiz.length >= 10);

  final unanswerable = <String>[];
  for (final lesson in pack.lessons) {
    for (final pair in lesson.askPairs) {
      if (!pair.options.contains(pair.answer)) {
        unanswerable.add('Ders ${lesson.id}: ${pair.question} → ${pair.answer}');
      }
    }
    for (final item in lesson.quiz) {
      if (!item.options.contains(item.answer)) {
        unanswerable.add('Ders ${lesson.id}: ${item.question} → ${item.answer}');
      }
    }
  }
  check('Her sorunun doğru şıkkı var', unanswerable.isEmpty,
      unanswerable.take(3).join(' | '));

  final wrongReadings = <String>[];
  for (final lesson in pack.lessons) {
    for (final row in [...lesson.letterTable, ...lesson.tripleFormTable]) {
      final cases = <String, String>{
        if (row.marked.isNotEmpty) row.marked: row.reading,
        if (row.fatha.isNotEmpty) row.fatha: row.fathaReading,
        if (row.kasra.isNotEmpty) row.kasra: row.kasraReading,
        if (row.damma.isNotEmpty) row.damma: row.dammaReading,
      };
      for (final entry in cases.entries) {
        if (!ElifbaReading.isShortSyllable(entry.key)) continue;
        if (entry.value.isEmpty) continue;
        final want = ElifbaReading.of(
          ElifbaReading.letterOf(entry.key),
          ElifbaReading.markOf(entry.key),
        );
        if (entry.value != want) {
          wrongReadings.add('Ders ${lesson.id}: ${entry.key} ${entry.value}');
        }
      }
    }
  }
  check('Okunuşlar kalın/ince kuralına uyuyor', wrongReadings.isEmpty,
      wrongReadings.take(4).join(' | '));

  final sample = pack.lessons
      .expand((lesson) => lesson.letterTable)
      .where((row) => ElifbaReading.isShortSyllable(row.marked))
      .take(6)
      .map((row) => '${row.marked}=${row.reading}')
      .join('  ');
  stdout.writeln('  örnek okunuşlar: $sample');

  final singleSound = <String>[];
  for (final lesson in pack.lessons) {
    for (final text in [lesson.goal, lesson.explanation, lesson.rich.objective]) {
      if (text.contains('ince harflerde')) continue;
      // Esre ve ötre tek ses verir; yalnızca üstün ikili anlatım ister.
      if (RegExp("kısa ['\u2018]?a['\u2019]? ses").hasMatch(text)) {
        singleSound.add('Ders ${lesson.id}: $text');
      }
    }
  }
  check('Hareke anlatımları iki sesi de veriyor', singleSound.isEmpty,
      singleSound.take(2).join(' | '));
  for (final lesson in pack.lessons) {
    final mark = lesson.rule?.symbol ?? '';
    if (ElifbaReading.vowelPairs.containsKey(mark)) {
      stdout.writeln('  ${lesson.title}: ${lesson.goal}');
    }
  }

  final wrongQuiz = <String>[];
  for (final lesson in pack.lessons) {
    for (final item in lesson.quiz) {
      if (!item.question.contains('nasıl okunur')) continue;
      // Uzatmalı sorular (بَا → bâ) bu kuralın dışındadır.
      final arabic = RegExp(r'[\u0600-\u06FF]+')
          .allMatches(item.question)
          .map((match) => match.group(0)!)
          .toList();
      if (!arabic.every(ElifbaReading.isShortSyllable)) continue;
      if (arabic.isEmpty) continue;
      // "Kalın / İnce" gibi sınıflandırma soruları hece üretmez.
      final syllabic = RegExp(r'^[a-zçğışöü]+(-[a-zçğışöü]+)*$');
      if (!item.options.every((option) => syllabic.hasMatch(option))) continue;
      final want = arabic
          .map((syllable) => ElifbaReading.of(
                ElifbaReading.letterOf(syllable),
                ElifbaReading.markOf(syllable),
                withTag: false,
              ))
          .join('-');
      if (item.answer != want || !item.options.contains(want)) {
        wrongQuiz.add(
          'Ders ${lesson.id}: ${item.question} ${item.options} → '
          '${item.answer} (beklenen $want)',
        );
      }
    }
  }
  check('Okunuş soruları kurala uygun', wrongQuiz.isEmpty,
      wrongQuiz.take(4).join(' | '));

  stdout.writeln('\nDers içerik blokları:');
  for (final lesson in pack.lessons) {
    final blocks = <String>[
      if (lesson.ruleText.isNotEmpty) 'kural',
      if (lesson.rule != null) 'isaret',
      if (lesson.letters.isNotEmpty) 'harfler',
      if (lesson.tripleFormTable.isNotEmpty) 'uclu-tablo',
      if (pack.teachingTableFor(lesson).isNotEmpty) 'harf-tablosu',
      if (lesson.harakeTables.isNotEmpty) 'sedde-tablolari',
      if (lesson.categoryTables.isNotEmpty) 'kategori-tablolari',
      if (lesson.categories.isNotEmpty) 'kategoriler',
      if (lesson.reviewGroups.isNotEmpty) 'tekrar-gruplari',
      if (lesson.specialLetters.isNotEmpty) 'ozel-harf',
      if (lesson.askPairs.isNotEmpty) 'karsilastirma-oyunu',
      if (lesson.wordExamples.isNotEmpty) 'kelime-okuma',
      if (lesson.coreExamples.isNotEmpty) 'cekirdek-ornek',
      if (lesson.examples.isNotEmpty) 'ornekler',
      if (lesson.blending.isNotEmpty) 'birlestirme',
      if (lesson.types.isNotEmpty) 'tenvin',
      if (pack.medTableFor(lesson).isNotEmpty) 'med-tablosu',
      if (lesson.medLetters.isNotEmpty) 'med-harfleri',
      if (lesson.raTable.isNotEmpty) 'ra-tablosu',
      if (lesson.focusLetter != null) 'harf-sekilleri',
      if (lesson.groups.isNotEmpty) 'mahrec',
      if (lesson.pairs.isNotEmpty) 'benzer-harfler',
      if (lesson.verses.isNotEmpty) 'ayetler',
      if (lesson.surahs.isNotEmpty) 'sureler',
      if (pack.decisionTreeFor(lesson).isNotEmpty) 'kural-agaci',
      if (lesson.rulesSummary.isNotEmpty ||
          lesson.rules.isNotEmpty ||
          lesson.basicRules.isNotEmpty ||
          lesson.concepts.isNotEmpty ||
          lesson.signs.isNotEmpty)
        'kural-kartlari',
    ];
    check('Ders ${lesson.id} içerik üretiyor', blocks.isNotEmpty,
        '${lesson.title} → ${blocks.join(', ')}');
  }

  stdout.writeln(failures == 0
      ? '\nTüm kontroller geçti.'
      : '\n$failures kontrol başarısız.');
  exitCode = failures == 0 ? 0 : 1;
}
