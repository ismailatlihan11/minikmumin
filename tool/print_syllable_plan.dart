import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/features/elifba_adventure/elifba_audio_map.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_reading.dart';

/// Harekeli hece seslerinin üretim planını yazar: hangi ses dosyası hangi
/// okunuşu söylemeli. Ses üretimi bu planı okur, böylece kayıtlar kartlarda
/// yazan okunuşla birebir aynı olur.
///
/// `dart run tool/print_syllable_plan.dart > /tmp/syllable_plan.json`
void main() {
  const marks = {
    'fatha': ElifbaReading.fatha,
    'kasra': ElifbaReading.kasra,
    'damma': ElifbaReading.damma,
  };

  final plan = <String, dynamic>{};
  for (final entry in elifbaAudioGlyphs.entries) {
    final glyph = entry.key;
    final stem = entry.value;
    if (plan.containsKey(stem)) continue; // أ/إ ve ى yinelenen köklerdir
    final readings = <String, String>{};
    for (final mark in marks.entries) {
      final reading = ElifbaReading.of(glyph, mark.value, withTag: false);
      if (reading.isNotEmpty) readings[mark.key] = reading;
    }
    if (readings.isEmpty) continue;
    plan[stem] = {'glyph': glyph, 'readings': readings};
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(plan));
}
