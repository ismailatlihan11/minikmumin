import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_letter_forms.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_quran_bridge.dart';

/// Hangi dersin ekranında hangi harf tablosunun çıktığını listeler.
void main() {
  final quran = QuranLearningPack.fromJson(
    jsonDecode(File('assets/data/kur_an_ogrenme_veri_paketi.json')
        .readAsStringSync()) as Map<String, dynamic>,
  );
  final forms = ElifbaLetterFormsLesson.build(quran);
  final pack = ElifbaPack.fromJson(
    jsonDecode(File('assets/data/elifba_tecvid_dersleri_eksiksiz.json')
        .readAsStringSync()) as Map<String, dynamic>,
    extras: [
      if (forms != null) ElifbaExtraLesson(afterLessonId: 1, json: forms),
    ],
    patches: ElifbaQuranBridge.patches(quran),
  );

  for (final lesson in pack.contentLessons) {
    final table = pack.teachingTableFor(lesson);
    if (table.isEmpty) continue;
    final letters = table.map((row) => row.letter).take(8).join(' ');
    final own = identical(table, lesson.letterTable) ||
        table.length == lesson.letterTable.length &&
            lesson.letterTable.isNotEmpty &&
            table.first.letter == lesson.letterTable.first.letter;
    stdout.writeln(
      '${lesson.id.toString().padLeft(2)} ${lesson.title.padRight(28)} '
      '${own ? "kendi " : "ÖDÜNÇ "} ${table.length} satır · '
      'kategori "${table.first.category}" · $letters',
    );
  }
}
