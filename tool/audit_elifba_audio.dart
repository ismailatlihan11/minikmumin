import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_audio_map.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_letter_forms.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_quran_bridge.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_reading.dart';

/// Elifbâ derslerindeki her "Dinle" düğmesinin hangi kaydı istediğini bulur
/// ve dosyası olmayanları listeler. Üretim planı `--plan` ile JSON olarak
/// yazılır: `dart run tool/audit_elifba_audio.dart --plan > /tmp/audio_plan.json`
/// `--all` aynı biçimde var olanlar dahil bütün kayıtları yazar (ses kontrolü için).
void main(List<String> args) {
  final pack = _loadPack();
  final wanted = <String, _Need>{};

  void need(String path, String kind, String text, String say,
      {String voice = 'tr'}) {
    if (path.isEmpty || say.isEmpty) return;
    wanted.putIfAbsent(path, () => _Need(path, kind, text, say, voice));
  }

  for (final lesson in pack.contentLessons) {
    // Harf adı kartları
    for (final letter in lesson.letters) {
      final stem =
          elifbaLetterStem(letter.name.isEmpty ? letter.letter : letter.name);
      if (stem != null)
        need(elifbaNamePath(stem), 'harf adı', letter.letter, letter.name);
    }

    // Harf tabloları: ekranda hangi tablo görünüyorsa o (JSON'da tablolar
    // bir ders kaymış durumda, uygulama da bu çözümlemeyi kullanıyor).
    final rows = [
      ...pack.teachingTableFor(lesson),
      ...lesson.tripleFormTable,
      ...lesson.categoryTables.values.expand((rows) => rows),
      ...lesson.harakeTables.values.expand((rows) => rows),
    ];
    for (final row in rows) {
      final stem = elifbaLetterStem(row.name.isEmpty ? row.letter : row.name);
      if (stem == null) continue;
      need(elifbaNamePath(stem), 'harf adı', row.letter, row.name);
      for (final marked in [row.marked, row.fatha, row.kasra, row.damma]) {
        _needCluster(marked, need);
      }
    }

    // Tek parça örnekler (harf + hareke) ve Ra satırları
    for (final example in [
      ...lesson.examples,
      ...lesson.practice,
      ...lesson.comparison,
      ...lesson.coreExamples,
      ...lesson.blending,
    ]) {
      _needCluster(example.text, need);
    }
    for (final row in lesson.raTable) {
      _needCluster(row.form, need);
    }

    // Kelimeler: kayıtlı dosyası olmayanlar için yeni kayıt gerekir.
    for (final word in lesson.wordExamples) {
      if (word.audio.isNotEmpty && File(word.audio).existsSync()) {
        need(word.audio, 'kelime (kayıtlı)', word.text, word.text, voice: 'ar');
        continue;
      }
      final path = elifbaWordPath(word.reading);
      if (path != null) {
        need(path, 'kelime', word.text, word.text, voice: 'ar');
      }
    }
    for (final example in [
      ...lesson.examples,
      ...lesson.coreExamples,
      ...lesson.practice,
    ]) {
      if (_letterCount(example.text) < 2) continue;
      if (example.audio.isNotEmpty && File(example.audio).existsSync()) {
        need(example.audio, 'kelime (kayıtlı)', example.text, example.text,
            voice: 'ar');
        continue;
      }
      final path = elifbaWordPath(example.reading);
      if (path != null) {
        need(path, 'kelime', example.text, example.text, voice: 'ar');
      }
    }

    // Hareke tanıtım kartları
    final rule = lesson.rule;
    if (rule != null && rule.symbol.isNotEmpty) {
      final id = elifbaHarakaOf(rule.symbol).startsWith('shadda')
          ? 'shadda'
          : elifbaHarakaOf(rule.symbol);
      // Bu klasördeki kayıtlar harekenin Arapça adını söyler (فَتْحَة).
      const arabicNames = {'sukun': 'سُكُون', 'shadda': 'شَدَّة'};
      if (id != 'name') {
        need(elifbaMarkPath(id), 'hareke adı', rule.symbol,
            arabicNames[id] ?? rule.name,
            voice: 'ar');
      }
    }
  }

  final missing = wanted.values
      .where((item) => !File(item.path).existsSync())
      .toList(growable: false);

  if (args.contains('--plan') || args.contains('--all')) {
    final items = args.contains('--all') ? wanted.values : missing;
    stdout.writeln(const JsonEncoder.withIndent('  ').convert([
      for (final item in items)
        {
          'path': item.path,
          'say': item.say,
          'kind': item.kind,
          'text': item.text,
          'voice': item.voice,
        },
    ]));
    return;
  }

  final byKind = <String, List<_Need>>{};
  for (final item in missing) {
    byKind.putIfAbsent(item.kind, () => []).add(item);
  }
  for (final entry in byKind.entries) {
    stdout.writeln('${entry.key}: ${entry.value.length} eksik');
    for (final item in entry.value.take(6)) {
      stdout.writeln('   ${item.text}  →  "${item.say}"  (${item.path})');
    }
    if (entry.value.length > 6) stdout.writeln('   ...');
  }
  stdout
      .writeln('\nistenen kayıt: ${wanted.length} · eksik: ${missing.length}');
}

int _letterCount(String text) {
  var letters = 0;
  for (final rune in text.runes) {
    final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
    if (!isMark) letters += 1;
  }
  return letters;
}

/// Tek harflik parçalar için hece kaydı ister. Söylenecek metin kural
/// motorundan gelir; elif ve ayn gibi ünsüzü olmayan harflerin cezmli
/// hâli seslendirilemez, onlar atlanır.
void _needCluster(
  String text,
  void Function(String, String, String, String, {String voice}) need,
) {
  if (text.isEmpty || _letterCount(text) != 1) return;
  final stem = elifbaLetterStem(text);
  if (stem == null) return;
  final haraka = elifbaHarakaOf(text);
  if (haraka == 'name' || !elifbaSyllableHasRecording(haraka)) return;
  final say = ElifbaReading.forMarked(text, '', withTag: false);
  if (say.isEmpty) return;
  need(elifbaSyllablePath(stem, haraka), 'hece ($haraka)', text, say);
}

ElifbaPack _loadPack() {
  final raw = File('assets/data/elifba_tecvid_dersleri_eksiksiz.json')
      .readAsStringSync();
  final quran = QuranLearningPack.fromJson(
    jsonDecode(File('assets/data/kur_an_ogrenme_veri_paketi.json')
        .readAsStringSync()) as Map<String, dynamic>,
  );
  final forms = ElifbaLetterFormsLesson.build(quran);
  return ElifbaPack.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
    extras: [
      if (forms != null) ElifbaExtraLesson(afterLessonId: 1, json: forms),
    ],
    patches: ElifbaQuranBridge.patches(quran),
  );
}

class _Need {
  _Need(this.path, this.kind, this.text, this.say, this.voice);

  final String path;
  final String kind;
  final String text;
  final String say;
  final String voice;
}
