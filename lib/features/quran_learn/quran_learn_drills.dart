import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_practice.dart';
import 'quran_learn_progress.dart';

List<String> quranLearnLetterNameLines(QuranArabicLetter letter) {
  return [
    'Bu harfin adı ${letter.name}.',
    'Harfi göster, adını söyle, sonra Dinle ile kontrol et.',
  ];
}

List<String> quranLearnLetterSoundLines(QuranArabicLetter letter) {
  return [
    'Yaklaşık sesi: ${letter.approximateTurkishSound}.',
    if (letter.isHeavySound) 'Bu harf kalın okunur.',
    if (!letter.isHeavySound) 'Bu harf ince okunur.',
    'Dinle, sonra sen de aynı sesi çıkar.',
  ];
}

List<String> quranLearnLetterShapeLines(QuranArabicLetter letter) {
  if (letter.joinsBothSides) {
    return [
      'Bu harf sonraki harfe bağlanır.',
      'Kelimenin başında, ortasında ve sonunda şekli değişir.',
      'Dört şekli tek tek bak, sonra boyayarak pekiştir.',
    ];
  }
  return [
    'Bu harf sonraki harfe bağlanmaz.',
    'Tek başına ve sonda çoğu zaman aynı görünür.',
    'Şekilleri karşılaştırıp farkı görelim.',
  ];
}

List<String> quranLearnPickOptions({
  required String correct,
  required Iterable<String> pool,
  int count = 3,
  Random? random,
}) {
  final rng = random ?? Random();
  final unique = <String>{};
  for (final item in pool) {
    final value = item.trim();
    if (value.isNotEmpty) unique.add(value);
  }
  unique.remove(correct);
  final others = unique.toList()..shuffle(rng);
  final picked = [correct, ...others.take(max(0, count - 1))]..shuffle(rng);
  return picked;
}

({String question, String correct, List<String> options})?
    quranLearnFormDrill(QuranArabicLetter letter, {Random? random}) {
  final pairs = <(String, String)>[
    ('Tek başına', letter.forms.isolated),
    ('Başta', letter.forms.initial),
    ('Ortada', letter.forms.medial),
    ('Sonda', letter.forms.finalForm),
  ];
  final byLabel = <String, String>{
    for (final pair in pairs)
      if (pair.$2.trim().isNotEmpty) pair.$1: pair.$2,
  };
  final glyphs = byLabel.values.toSet();
  if (glyphs.length < 2) return null;

  String label;
  if (byLabel['Başta'] != null &&
      byLabel['Başta'] != byLabel['Tek başına']) {
    label = 'Başta';
  } else if (byLabel['Ortada'] != null &&
      byLabel['Ortada'] != byLabel['Tek başına']) {
    label = 'Ortada';
  } else {
    label = byLabel.keys.firstWhere(
      (key) => byLabel[key] != byLabel['Tek başına'],
      orElse: () => byLabel.keys.first,
    );
  }
  final correct = byLabel[label]!;
  return (
    question: 'Hangisi $label şekli?',
    correct: correct,
    options: quranLearnPickOptions(
      correct: correct,
      pool: glyphs,
      random: random,
    ),
  );
}

class QlTeachCard extends StatelessWidget {
  const QlTeachCard({
    super.key,
    required this.lines,
    this.color = MinikColors.sky,
  });

  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clean = [
      for (final line in lines)
        if (line.trim().isNotEmpty) line.trim(),
    ];
    if (clean.isEmpty) return const SizedBox.shrink();
    return MinikCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < clean.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Text(
              clean[i],
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: MinikColors.darkGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class QlPickDrill extends StatefulWidget {
  const QlPickDrill({
    super.key,
    required this.question,
    required this.options,
    required this.correct,
    this.arabic = false,
  });

  final String question;
  final List<String> options;
  final String correct;
  final bool arabic;

  @override
  State<QlPickDrill> createState() => _QlPickDrillState();
}

class _QlPickDrillState extends State<QlPickDrill> {
  String? _picked;
  bool _done = false;

  Future<void> _pick(String option) async {
    if (_done) return;
    final right = option == widget.correct;
    setState(() {
      _picked = option;
      if (right) _done = true;
    });
    if (right) {
      await context.read<LocalProgressStore>().addCounter(quranLearnCorrectAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.length < 2) return const SizedBox.shrink();
    return MinikCard(
      color: _done ? MinikColors.mint : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftBadge(label: 'Alıştırma'),
          const SizedBox(height: 8),
          Text(
            widget.question,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in widget.options)
                _DrillChip(
                  label: option,
                  arabic: widget.arabic,
                  selected: _picked == option,
                  correct: _done && option == widget.correct,
                  wrong: _picked == option && option != widget.correct,
                  onTap: () => _pick(option),
                ),
            ],
          ),
          if (_picked != null) ...[
            const SizedBox(height: 8),
            Text(
              _done ? 'Aferin, doğru buldun.' : 'Bir daha bakalım.',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w700,
                color: _done ? MinikColors.green : MinikColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrillChip extends StatelessWidget {
  const _DrillChip({
    required this.label,
    required this.arabic,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool arabic;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? MinikColors.mint
        : wrong
            ? MinikColors.peach
            : selected
                ? MinikColors.sky
                : const Color(0xFFF4F7F2);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: arabic
              ? Text(
                  label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: 28,
                    height: 1.1,
                    color: MinikColors.darkGreen,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
        ),
      ),
    );
  }
}

class QlLetterFindDrill extends StatelessWidget {
  const QlLetterFindDrill({
    super.key,
    required this.letter,
    required this.letters,
  });

  final QuranArabicLetter letter;
  final List<QuranArabicLetter> letters;

  @override
  Widget build(BuildContext context) {
    final options = quranLearnPickOptions(
      correct: letter.letter,
      pool: letters.map((item) => item.letter),
      random: Random(letter.id.hashCode),
    );
    return QlPickDrill(
      question: '${letter.name} harfini bul.',
      options: options,
      correct: letter.letter,
      arabic: true,
    );
  }
}

class QlLetterFormDrill extends StatelessWidget {
  const QlLetterFormDrill({super.key, required this.letter});

  final QuranArabicLetter letter;

  @override
  Widget build(BuildContext context) {
    final drill = quranLearnFormDrill(letter, random: Random(letter.id.hashCode));
    if (drill == null) return const SizedBox.shrink();
    return QlPickDrill(
      question: drill.question,
      options: drill.options,
      correct: drill.correct,
      arabic: true,
    );
  }
}

class QlHarakaFindDrill extends StatelessWidget {
  const QlHarakaFindDrill({
    super.key,
    required this.haraka,
    required this.harakat,
  });

  final QuranHaraka haraka;
  final List<QuranHaraka> harakat;

  @override
  Widget build(BuildContext context) {
    final glyphs = [
      for (final item in harakat) quranLearnTeachingGlyph(item.id),
    ].where((item) => item.isNotEmpty).toList();
    final correct = quranLearnTeachingGlyph(haraka.id);
    if (correct.isEmpty || glyphs.length < 2) return const SizedBox.shrink();
    return QlPickDrill(
      question: '${haraka.name} işaretini bul.',
      options: quranLearnPickOptions(
        correct: correct,
        pool: glyphs,
        random: Random(haraka.id.hashCode),
      ),
      correct: correct,
      arabic: true,
    );
  }
}

class QlWordReadingDrill extends StatelessWidget {
  const QlWordReadingDrill({
    super.key,
    required this.word,
    required this.words,
  });

  final QuranWord word;
  final List<QuranWord> words;

  @override
  Widget build(BuildContext context) {
    return QlPickDrill(
      question: '${word.arabic} nasıl okunur?',
      options: quranLearnPickOptions(
        correct: word.reading,
        pool: words.map((item) => item.reading),
        random: Random(word.id.hashCode),
      ),
      correct: word.reading,
    );
  }
}

class QlMahrajFindDrill extends StatelessWidget {
  const QlMahrajFindDrill({
    super.key,
    required this.group,
    required this.pack,
  });

  final QuranMahrajGroup group;
  final QuranLearningPack pack;

  @override
  Widget build(BuildContext context) {
    final inside = [
      for (final id in group.letterIds)
        if (pack.letterById(id) != null) pack.letterById(id)!.letter,
    ];
    if (inside.isEmpty) return const SizedBox.shrink();
    final correct = inside.first;
    final pool = [
      ...inside,
      for (final letter in pack.letters) letter.letter,
    ];
    return QlPickDrill(
      question: '${group.title} grubunda hangisi var?',
      options: quranLearnPickOptions(
        correct: correct,
        pool: pool,
        random: Random(group.id.hashCode),
      ),
      correct: correct,
      arabic: true,
    );
  }
}

class QlHeavyFindDrill extends StatelessWidget {
  const QlHeavyFindDrill({
    super.key,
    required this.heavy,
    required this.letters,
  });

  final bool heavy;
  final List<QuranArabicLetter> letters;

  @override
  Widget build(BuildContext context) {
    final want = [
      for (final letter in letters)
        if (letter.isHeavySound == heavy) letter.letter,
    ];
    if (want.isEmpty) return const SizedBox.shrink();
    final correct = want.first;
    return QlPickDrill(
      question: heavy ? 'Hangisi kalın harf?' : 'Hangisi ince harf?',
      options: quranLearnPickOptions(
        correct: correct,
        pool: letters.map((item) => item.letter),
        random: Random(heavy ? 7 : 11),
      ),
      correct: correct,
      arabic: true,
    );
  }
}
