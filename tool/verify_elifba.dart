// Elifbâ + Tecvid içerik kontrolü: `dart run tool/verify_elifba.dart`
// Ders içerikleri JSON'dan geldiği için kuralları burada de doğruluyoruz.
import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';

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

void main() {
  final raw = File('assets/data/elifba_tecvid_dersleri_eksiksiz.json')
      .readAsStringSync();
  final pack = ElifbaPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  stdout.writeln('Ders sayısı: ${pack.lessons.length}');
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
  check('ب = Be, بَ = ba ayrımı',
      be.name == 'Be' && be.marked == 'بَ' && be.reading == 'ba',
      '${be.name} / ${be.marked} / ${be.reading}');

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
