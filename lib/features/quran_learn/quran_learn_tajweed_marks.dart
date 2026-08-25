import 'package:flutter/material.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/quran_learning.dart';

const _waqfMarks = 'ؕۚۖۗۘۙۛۜۢ۝';
const _tanwinMarks = 'ًٌٍ';
const _maddMarks = 'ٰٓ';

String quranLearnNormalizeArabic(String value) {
  return value
      .replaceAll('ي', 'ی')
      .replaceAll('ى', 'ی')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('ٱ', 'ا')
      .replaceAll('ـ', '')
      .replaceAll(RegExp('[$_waqfMarks]'), '')
      .trim();
}

String quranLearnTajweedReference(String raw) {
  final text = raw.trim();
  final match = RegExp(r'^(\d+)\s*:\s*(\d+)$').firstMatch(text);
  if (match == null) return text;
  final surah = int.parse(match.group(1)!);
  final ayah = match.group(2)!;
  return '${surahName(surah)} $surah:$ayah';
}

class QuranTajweedHit {
  const QuranTajweedHit({
    required this.lessonId,
    required this.title,
    required this.color,
  });

  final String lessonId;
  final String title;
  final Color color;
}

bool _containsMark(String arabic, String marks) {
  for (final rune in marks.runes) {
    if (arabic.contains(String.fromCharCode(rune))) return true;
  }
  return false;
}

List<QuranTajweedHit> quranLearnTajweedHits({
  required String arabic,
  required List<QuranTajweedLesson> lessons,
}) {
  final hits = <QuranTajweedHit>[];
  final seen = <String>{};
  final normalized = quranLearnNormalizeArabic(arabic);
  final compact = normalized.replaceAll(' ', '');

  void add(QuranTajweedLesson lesson) {
    if (!seen.add(lesson.id)) return;
    hits.add(
      QuranTajweedHit(
        lessonId: lesson.id,
        title: lesson.title,
        color: MinikColors.pastelAt(lesson.order),
      ),
    );
  }

  for (final lesson in lessons) {
    var matched = false;
    switch (lesson.id) {
      case 'tajweed_02':
        matched = arabic.contains('ّ');
      case 'tajweed_04':
        matched = _containsMark(arabic, _tanwinMarks);
      case 'tajweed_03':
        matched = arabic.contains('ْ');
      case 'tajweed_01':
        matched = _containsMark(arabic, _maddMarks);
      case 'tajweed_05':
        matched = arabic.contains('نَّ') ||
            arabic.contains('مَّ') ||
            arabic.contains('نّ') ||
            arabic.contains('مّ');
      case 'tajweed_10':
        matched = _containsMark(arabic, _waqfMarks);
      case 'tajweed_06':
        for (final letter in lesson.qalqalaLetters) {
          if (arabic.contains('$letterْ')) {
            matched = true;
            break;
          }
        }
    }

    for (final example in lesson.examples) {
      final needle = quranLearnNormalizeArabic(example.arabic);
      if (needle.isNotEmpty && normalized.contains(needle)) {
        matched = true;
        break;
      }
      final focus = quranLearnNormalizeArabic(
        example.focus.split('(').first.trim(),
      ).replaceAll(' ', '');
      if (focus.length >= 2 && focus != 'son' && compact.contains(focus)) {
        matched = true;
        break;
      }
    }

    if (matched) add(lesson);
  }
  return hits;
}

class QlTajweedFocusArabic extends StatelessWidget {
  const QlTajweedFocusArabic(
    this.arabic, {
    super.key,
    required this.focus,
    this.fontSize = 32,
  });

  final String arabic;
  final String focus;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final needle = focus.split('(').first.trim();
    final style = TextStyle(
      fontFamily: AssetPaths.arabicFontFamily,
      fontSize: fontSize,
      height: 1.3,
      color: MinikColors.darkGreen,
    );
    var index = needle.isEmpty ? -1 : arabic.indexOf(needle);
    var length = needle.length;
    if (index < 0 && needle.contains(' ')) {
      final compact = needle.replaceAll(' ', '');
      index = arabic.indexOf(compact);
      length = compact.length;
    }
    if (index < 0) {
      return Text(
        arabic,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: style,
      );
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: arabic.substring(0, index)),
          TextSpan(
            text: arabic.substring(index, index + length),
            style: const TextStyle(
              backgroundColor: MinikColors.butter,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: arabic.substring(index + length)),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
  }
}

class QlTajweedHitChips extends StatelessWidget {
  const QlTajweedHitChips(this.hits, {super.key});

  final List<QuranTajweedHit> hits;

  @override
  Widget build(BuildContext context) {
    if (hits.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final hit in hits)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hit.color,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              hit.title,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: MinikColors.darkGreen,
              ),
            ),
          ),
      ],
    );
  }
}
