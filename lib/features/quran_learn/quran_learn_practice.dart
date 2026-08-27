import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_widgets.dart';

class QuranLearnPracticeItem {
  const QuranLearnPracticeItem({
    required this.letter,
    required this.arabic,
    required this.audio,
    this.compareArabic,
    this.compareAudio,
  });

  final QuranArabicLetter letter;
  final String arabic;
  final String? audio;
  final String? compareArabic;
  final String? compareAudio;
}

bool quranLearnHarakaUsesElif(String harakaId) {
  return harakaId == 'fatha' || harakaId == 'kasra' || harakaId == 'damma';
}

String quranLearnTeachingGlyph(String harakaId) {
  switch (harakaId) {
    case 'fatha':
      return 'أَ';
    case 'kasra':
      return 'إِ';
    case 'damma':
      return 'أُ';
    case 'fatha_madd':
      return 'بَا';
    case 'kasra_madd':
      return 'بِي';
    case 'damma_madd':
      return 'بُو';
    case 'tanwin_fath':
      return 'بًا';
    case 'tanwin_kasr':
      return 'بٍ';
    case 'tanwin_damm':
      return 'بٌ';
    case 'sukun':
      return 'بْ';
    case 'shadda':
      return 'بَّ';
    default:
      return '';
  }
}

String? quranLearnTeachingAudio(
  List<QuranArabicLetter> letters,
  String harakaId,
) {
  final wantElif = quranLearnHarakaUsesElif(harakaId);
  for (final letter in letters) {
    if (wantElif && letter.letter == 'ا') {
      return QuranLearnAudio.practicePath(letter.audio, harakaId);
    }
    if (!wantElif && letter.letter == 'ب') {
      return QuranLearnAudio.practicePath(letter.audio, harakaId);
    }
  }
  return null;
}

String quranLearnPracticeGlyph(QuranArabicLetter letter, String harakaId) {
  final base = letter.letter;
  if (base == 'ا') {
    switch (harakaId) {
      case 'fatha':
        return 'أَ';
      case 'kasra':
        return 'إِ';
      case 'damma':
        return 'أُ';
    }
  }
  switch (harakaId) {
    case 'fatha':
      return '$baseَ';
    case 'kasra':
      return '$baseِ';
    case 'damma':
      return '$baseُ';
    case 'fatha_madd':
      return '$baseَا';
    case 'kasra_madd':
      return '$baseِي';
    case 'damma_madd':
      return '$baseُو';
    case 'tanwin_fath':
      return '$baseً';
    case 'tanwin_kasr':
      return '$baseٍ';
    case 'tanwin_damm':
      return '$baseٌ';
    case 'sukun':
      return '$baseْ';
    case 'shadda':
      return '$baseَّ';
    default:
      return base;
  }
}

String? quranLearnCompareGlyph(QuranArabicLetter letter, String harakaId) {
  switch (harakaId) {
    case 'fatha_madd':
    case 'tanwin_fath':
      return quranLearnPracticeGlyph(letter, 'fatha');
    case 'kasra_madd':
    case 'tanwin_kasr':
      return quranLearnPracticeGlyph(letter, 'kasra');
    case 'damma_madd':
    case 'tanwin_damm':
      return quranLearnPracticeGlyph(letter, 'damma');
    default:
      return null;
  }
}

bool quranLearnHasComparison(String harakaId) {
  return harakaId.endsWith('_madd') || harakaId.startsWith('tanwin_');
}

/// Teaching line under a hareke title. Extra fetha contrast comes from JSON
/// examples (`e / a` and `(kalın)`), not invented fıkıh.
String quranLearnHarakatTeachLine(QuranHaraka haraka) {
  final rule = haraka.readingRule.trim();
  if (haraka.id != 'fatha') return rule;
  final hasEa = haraka.examples.any((item) => item.reading.contains('e / a'));
  final hasHeavy = haraka.examples.any((item) => item.reading.contains('kalın'));
  if (hasEa && hasHeavy) {
    return "$rule İnce harfleri 'e' sesine yakın, kalın harfleri 'a' sesine yakın okutur.";
  }
  return rule;
}

bool quranLearnIsSukunLetter(QuranArabicLetter letter) {
  return letter.letter != 'ا' && letter.letter != 'لا';
}

/// Elifba cezm kartı: harekeli elif + sakin harf, üç hareke ile.
String quranLearnSukunTriplet(QuranArabicLetter letter) {
  final consonant = letter.letter;
  return 'أَ$consonantْ إِ$consonantْ أُ$consonantْ';
}

/// JSON kuralı: ilk bölüm sakin, ikinci bölüm harekeli.
String quranLearnShaddaUnfold(String letter) {
  return '$letterْ + $letterَ';
}

List<QuranArabicLetter> quranLearnSukunLetters(List<QuranArabicLetter> letters) {
  return [
    for (final letter in letters)
      if (quranLearnIsSukunLetter(letter)) letter,
  ];
}

List<QuranLearnPracticeItem> quranLearnPracticeItems({
  required List<QuranArabicLetter> letters,
  required String harakaId,
}) {
  final items = <QuranLearnPracticeItem>[];
  for (final letter in letters) {
    if (letter.letter == 'ا' && !quranLearnHarakaUsesElif(harakaId)) {
      continue;
    }
    final audio = QuranLearnAudio.practicePath(letter.audio, harakaId);
    items.add(
      QuranLearnPracticeItem(
        letter: letter,
        arabic: quranLearnPracticeGlyph(letter, harakaId),
        audio: audio,
        compareArabic: quranLearnCompareGlyph(letter, harakaId),
        compareAudio: QuranLearnAudio.shortPairPath(letter.audio, harakaId),
      ),
    );
  }
  return items;
}

class QlPracticeTable extends StatelessWidget {
  const QlPracticeTable({
    super.key,
    required this.audio,
    required this.items,
    required this.compare,
  });

  final AudioPlayerService audio;
  final List<QuranLearnPracticeItem> items;
  final bool compare;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final item in items)
          MinikCard(
            child: compare
                ? Row(
                    children: [
                      Expanded(
                        child: _PracticeCell(
                          audio: audio,
                          arabic: item.compareArabic ?? item.arabic,
                          path: item.compareAudio,
                          caption: item.letter.name,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: MinikColors.gold),
                      Expanded(
                        child: _PracticeCell(
                          audio: audio,
                          arabic: item.arabic,
                          path: item.audio,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      QlBigArabic(
                        item.arabic,
                        fontSize: 36,
                        onTap: QuranLearnAudio.resolve(item.audio) == null
                            ? null
                            : () => QuranLearnAudio.play(
                                  audio,
                                  context.read<LocalProgressStore>(),
                                  item.audio,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.letter.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      QlListenIcon(audio: audio, path: item.audio),
                    ],
                  ),
          ),
      ],
    );
  }
}

class _PracticeCell extends StatelessWidget {
  const _PracticeCell({
    required this.audio,
    required this.arabic,
    required this.path,
    this.caption,
  });

  final AudioPlayerService audio;
  final String arabic;
  final String? path;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QlBigArabic(
          arabic,
          fontSize: 32,
          onTap: QuranLearnAudio.resolve(path) == null
              ? null
              : () => QuranLearnAudio.play(
                    audio,
                    context.read<LocalProgressStore>(),
                    path,
                  ),
        ),
        if (caption != null)
          Text(
            caption!,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: MinikColors.darkGreen,
            ),
          ),
        QlListenIcon(audio: audio, path: path),
      ],
    );
  }
}

class QlPracticeGrid extends StatelessWidget {
  const QlPracticeGrid({
    super.key,
    required this.audio,
    required this.items,
    this.columns = 5,
    this.fontSize = 22,
    this.aspect = 1,
    this.checkerboard = false,
    this.captionOf,
  });

  final AudioPlayerService audio;
  final List<QuranLearnPracticeItem> items;
  final int columns;
  final double fontSize;
  final double aspect;
  final bool checkerboard;
  final String? Function(QuranLearnPracticeItem item)? captionOf;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final store = context.read<LocalProgressStore>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: aspect,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return QlDashTile(
            arabic: item.arabic,
            caption: captionOf?.call(item),
            heavy: item.letter.isHeavySound,
            fontSize: fontSize,
            fillColor: checkerboard && index.isOdd
                ? const Color(0xFFEAF4F8)
                : Colors.white,
            onTap: QuranLearnAudio.resolve(item.audio) == null
                ? null
                : () => QuranLearnAudio.play(audio, store, item.audio),
          );
        },
      ),
    );
  }
}

class QlSukunTripletGrid extends StatelessWidget {
  const QlSukunTripletGrid({
    super.key,
    required this.audio,
    required this.letters,
  });

  final AudioPlayerService audio;
  final List<QuranArabicLetter> letters;

  @override
  Widget build(BuildContext context) {
    final items = quranLearnSukunLetters(letters);
    if (items.isEmpty) return const SizedBox.shrink();
    final store = context.read<LocalProgressStore>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final letter = items[index];
          final audioPath = QuranLearnAudio.practicePath(letter.audio, 'sukun');
          return QlDashTile(
            arabic: quranLearnSukunTriplet(letter),
            heavy: letter.isHeavySound,
            fontSize: 15,
            fillColor: index.isOdd ? const Color(0xFFF7EBC4) : Colors.white,
            onTap: QuranLearnAudio.resolve(audioPath) == null
                ? null
                : () => QuranLearnAudio.play(audio, store, audioPath),
          );
        },
      ),
    );
  }
}

class QlExampleListenGrid extends StatelessWidget {
  const QlExampleListenGrid({
    super.key,
    required this.audio,
    required this.examples,
    this.columns = 3,
    this.aspect = 1.15,
  });

  final AudioPlayerService audio;
  final List<QuranHarakaExample> examples;
  final int columns;
  final double aspect;

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) return const SizedBox.shrink();
    final store = context.read<LocalProgressStore>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: examples.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: aspect,
        ),
        itemBuilder: (context, index) {
          final example = examples[index];
          return QlDashTile(
            arabic: example.arabic,
            caption: example.reading,
            fontSize: 22,
            fillColor: index.isOdd ? const Color(0xFFEAF4F8) : Colors.white,
            onTap: QuranLearnAudio.resolve(example.audio) == null
                ? null
                : () => QuranLearnAudio.play(audio, store, example.audio),
          );
        },
      ),
    );
  }
}

class QlPracticeSection extends StatelessWidget {
  const QlPracticeSection({
    super.key,
    required this.audio,
    required this.letters,
    required this.harakaId,
    this.examples = const [],
  });

  final AudioPlayerService audio;
  final List<QuranArabicLetter> letters;
  final String harakaId;
  final List<QuranHarakaExample> examples;

  @override
  Widget build(BuildContext context) {
    if (harakaId == 'sukun') {
      return QlSukunTripletGrid(audio: audio, letters: letters);
    }
    final items = quranLearnPracticeItems(letters: letters, harakaId: harakaId);
    if (items.isEmpty && examples.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (examples.isNotEmpty) ...[
          QlExampleListenGrid(audio: audio, examples: examples),
          const SizedBox(height: 10),
        ],
        QlPracticeGrid(
          audio: audio,
          items: items,
          columns: harakaId == 'shadda' ? 4 : 5,
          fontSize: harakaId == 'shadda' ? 24 : 22,
        ),
      ],
    );
  }
}
