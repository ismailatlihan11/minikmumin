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

(int, int)? quranLearnParseAyahRef(String raw) {
  final match = RegExp(r'^(\d+)\s*:\s*(\d+)$').firstMatch(raw.trim());
  if (match == null) return null;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

String quranLearnTajweedReference(String raw) {
  final parsed = quranLearnParseAyahRef(raw);
  if (parsed == null) return raw.trim();
  return '${surahName(parsed.$1)} ${parsed.$1}:${parsed.$2}';
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

bool quranLearnLessonMatchesAyah({
  required QuranTajweedLesson lesson,
  required String arabic,
}) {
  return quranLearnTajweedHits(
    arabic: arabic,
    lessons: [lesson],
  ).isNotEmpty;
}

String? quranLearnLessonFocusInAyah({
  required QuranTajweedLesson lesson,
  required String arabic,
}) {
  for (final example in lesson.examples) {
    final focus = example.focus.split('(').first.trim();
    if (focus.isNotEmpty &&
        focus != 'son' &&
        arabic.contains(focus)) {
      return focus;
    }
    if (example.arabic.isNotEmpty && arabic.contains(example.arabic)) {
      return example.focus.split('(').first.trim();
    }
  }
  return null;
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
      case 'tajweed_21':
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

const quranLearnNunSakinCompareIds = [
  'tajweed_11',
  'tajweed_08',
  'tajweed_07',
  'tajweed_15',
];

const quranLearnNunSakinCompareLabels = {
  'tajweed_11': 'İzhâr',
  'tajweed_08': 'İhfâ',
  'tajweed_07': 'Gunnesiz',
  'tajweed_15': 'Gunneli',
};

const quranLearnMaddCompareIds = ['tajweed_01', 'tajweed_22'];

class QuranLearnCompareCard {
  const QuranLearnCompareCard({
    required this.label,
    required this.arabic,
    this.audio,
    this.lessonId,
    this.exampleIndex = 0,
  });

  final String label;
  final String arabic;
  final String? audio;
  final String? lessonId;
  final int exampleIndex;
}

String? quranLearnTajweedExampleLabel(String lessonId, int index) {
  const labels = <String, List<String>>{
    'tajweed_01': [
      'Medd-i Tabîî',
      'Medd-i Muttasıl',
      'Medd-i Munfasıl',
      'Medd-i Tabîî',
      'Medd-i Muttasıl',
    ],
    'tajweed_07': ['نْ + ل', 'نْ + ر', 'تنوين + ل', 'نْ + ر'],
    'tajweed_08': ['نْ + ش', 'نْ + ق', 'نْ + ص', 'نْ + ق', 'نْ + س', 'نْ + ج'],
    'tajweed_09': ['İklâb', 'İhfâ-i Şefeviyye'],
    'tajweed_12': ["Uzatılan hâ", 'Uzatılmayan hâ', 'Uzatılmayan hâ', 'هُوَ'],
    'tajweed_13': ['Kalın râ', 'İnce râ', 'Kalın râ'],
    'tajweed_14': ['Kesradan sonra', 'Fethadan sonra'],
    'tajweed_15': ['نْ + ی', 'تنوين + م', 'تنوين + م', 'نْ + ن', 'تنوين + و'],
    'tajweed_19': ['Mütekâribeyn', 'Mütecâniseyn'],
    'tajweed_22': ['Medd-i Lâzım', 'Medd-i Ârız', 'Medd-i Lîn'],
  };
  final list = labels[lessonId];
  if (list == null || index < 0 || index >= list.length) return null;
  return list[index];
}

QuranTajweedLesson? quranLearnTajweedById(
  List<QuranTajweedLesson> lessons,
  String id,
) {
  for (final lesson in lessons) {
    if (lesson.id == id) return lesson;
  }
  return null;
}

List<QuranLearnCompareCard> quranLearnCompareCards({
  required String lessonId,
  required List<QuranTajweedLesson> lessons,
}) {
  if (quranLearnNunSakinCompareIds.contains(lessonId)) {
    final cards = <QuranLearnCompareCard>[];
    for (final id in quranLearnNunSakinCompareIds) {
      final examples = quranLearnTajweedById(lessons, id)?.examples;
      if (examples == null || examples.isEmpty) continue;
      cards.add(
        QuranLearnCompareCard(
          label: quranLearnNunSakinCompareLabels[id] ?? id,
          arabic: examples.first.arabic,
          audio: examples.first.audio,
          lessonId: id,
        ),
      );
    }
    return cards;
  }
  if (!quranLearnMaddCompareIds.contains(lessonId)) return const [];
  final lesson = quranLearnTajweedById(lessons, lessonId);
  if (lesson == null) return const [];
  final take = lesson.examples.length < 3 ? lesson.examples.length : 3;
  return [
    for (var i = 0; i < take; i++)
      QuranLearnCompareCard(
        label: quranLearnTajweedExampleLabel(lesson.id, i) ?? 'Örnek',
        arabic: lesson.examples[i].arabic,
        audio: lesson.examples[i].audio,
        lessonId: lesson.id,
        exampleIndex: i,
      ),
  ];
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
