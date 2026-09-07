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

    for (final word in [...lesson.wordExamples, ...lesson.coreExamples]) {
      final text = word is ElifbaWordExample ? word.text : (word as ElifbaExample).text;
      final reading = word is ElifbaWordExample ? word.reading : (word as ElifbaExample).reading;
      for (final missing in _missingDoubles(text, reading)) {
        stdout.writeln(
          '${lesson.id}. ${lesson.title} → $text = "$reading" '
          '($missing sesi şeddeli, iki kez okunmalı)',
        );
        problems += 1;
      }
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

/// Şeddeli harflerin okunuşta iki kez geçip geçmediğine bakar. Kelimelerde
/// ünlüler komşu kalın harflerden etkilendiği için (نَصَرَ = "nasara") ünlü
/// denetimi yapılmaz, yalnızca şeddenin çift sesi aranır.
List<String> _missingDoubles(String word, String reading) {
  final plain = reading.toLowerCase().replaceAll(RegExp(r"[-' ]"), '');
  final missing = <String>[];
  final runes = word.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    if (String.fromCharCode(runes[i]) != ElifbaReading.shadda) continue;
    for (var j = i - 1; j >= 0; j--) {
      final letter = String.fromCharCode(runes[j]);
      final base = ElifbaReading.consonants[letter];
      if (base == null) continue;
      if (base.isNotEmpty && !plain.contains('$base$base')) {
        missing.add(letter);
      }
      break;
    }
  }
  return missing;
}

/// "tü", "sı" gibi eski hece okunuşları; harf adları (Hı, Tı) hariç.
bool _hasOldVowel(String value) {
  if (RegExp(r'^[A-ZÇĞŞİÖÜ]').hasMatch(value)) return false;
  return RegExp(r'^[a-zçğş]{0,2}[üı]$').hasMatch(value.trim());
}
