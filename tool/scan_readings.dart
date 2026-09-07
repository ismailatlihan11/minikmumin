import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_reading.dart';

/// Ekranda görünen okunuşları kuralla karşılaştırır: harf tabloları, örnek
/// kartları, med/ra satırları ve quiz şıkları. `dart run tool/scan_readings.dart`
void main() {
  final raw = File('assets/data/elifba_tecvid_dersleri_eksiksiz.json')
      .readAsStringSync();
  final pack = ElifbaPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  var problems = 0;
  for (final lesson in pack.contentLessons) {
    final shown = <String, String>{};
    for (final row in [
      ...lesson.letterTable,
      ...lesson.tripleFormTable,
      ...lesson.categoryTables.values.expand((rows) => rows),
      ...lesson.harakeTables.values.expand((rows) => rows),
    ]) {
      shown.addAll({
        if (row.marked.isNotEmpty) row.marked: row.reading,
        if (row.fatha.isNotEmpty) row.fatha: row.fathaReading,
        if (row.kasra.isNotEmpty) row.kasra: row.kasraReading,
        if (row.damma.isNotEmpty) row.damma: row.dammaReading,
      });
    }
    for (final example in [
      ...lesson.examples,
      ...lesson.practice,
      ...lesson.comparison,
      ...lesson.coreExamples,
      ...lesson.blending,
    ]) {
      shown[example.text] = example.reading;
    }
    for (final row in lesson.raTable) {
      shown[row.form] = row.reading;
    }
    for (final row in lesson.medTable) {
      shown[row.pattern] = row.reading;
    }

    for (final entry in shown.entries) {
      final want = ElifbaReading.forMarked(entry.key, '');
      if (want.isEmpty || want == entry.value) continue;
      stdout.writeln(
        '${lesson.id}. ${lesson.title} → ${entry.key} = "${entry.value}" '
        '(kural: "$want")',
      );
      problems += 1;
    }

    for (final item in lesson.quiz) {
      for (final option in item.options) {
        if (_hasOldVowel(option)) {
          stdout.writeln('${lesson.id}. ${lesson.title} → şık "$option"');
          problems += 1;
        }
      }
    }
  }
  stdout.writeln(problems == 0 ? 'temiz' : 'kural dışı: $problems');
}

/// "tü", "sı" gibi eski hece okunuşları; harf adları (Hı, Tı) hariç.
bool _hasOldVowel(String value) {
  if (RegExp(r'^[A-ZÇĞŞİÖÜ]').hasMatch(value)) return false;
  return RegExp(r'^[a-zçğş]{0,2}[üı]$').hasMatch(value.trim());
}
