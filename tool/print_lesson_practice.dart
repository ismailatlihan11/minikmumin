import 'dart:convert';
import 'dart:io';

import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_letter_forms.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_models.dart';
import 'package:minik_kalpler/features/elifba_adventure/elifba_quran_bridge.dart';

/// Bir dersin kaç alıştırma parçası ürettiğini gösterir:
/// `dart run tool/print_lesson_practice.dart 13 14`
void main(List<String> args) {
  final wanted = args.map(int.parse).toSet();
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
    if (wanted.isNotEmpty && !wanted.contains(lesson.id)) continue;
    stdout.writeln('— Ders ${lesson.id}: ${lesson.title}');
    final counts = {
      'örnek kart': lesson.examples.length,
      'alıştırma': lesson.practice.length,
      'kelime': lesson.wordExamples.length,
      'karşılaştırma': lesson.comparison.length,
      'soru-cevap oyunu': lesson.askPairs.length,
      'birleştirme': lesson.blending.length,
      'tenvin kartı': lesson.types.length,
      'med kartı': lesson.medLetters.length,
      'med tablosu': pack.medTableFor(lesson).length,
      'harf grubu': lesson.categories.length,
      'kural kartı': lesson.rulesSummary.length + lesson.rules.length,
      'kural ağacı': pack.decisionTreeFor(lesson).length,
      'kural bulmaca': lesson.examples.where((e) => e.rule.isNotEmpty).length,
      'quiz': lesson.quiz.length,
    };
    counts.forEach((key, value) {
      if (value > 0) stdout.writeln('    $key: $value');
    });
    final total = counts.values.reduce((a, b) => a + b);
    stdout.writeln('    toplam parça: $total');
    for (final item in lesson.examples.take(3)) {
      stdout.writeln('    ör: ${item.text} = ${item.reading}');
    }
    for (final word in lesson.wordExamples.take(3)) {
      stdout.writeln('    kelime: ${word.text} = ${word.reading} · ${word.focus}');
    }
  }
}
