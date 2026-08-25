import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
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

class QlPracticeSection extends StatelessWidget {
  const QlPracticeSection({
    super.key,
    required this.audio,
    required this.letters,
    required this.harakaId,
  });

  final AudioPlayerService audio;
  final List<QuranArabicLetter> letters;
  final String harakaId;

  @override
  Widget build(BuildContext context) {
    final items = quranLearnPracticeItems(letters: letters, harakaId: harakaId);
    if (items.isEmpty) return const SizedBox.shrink();
    final compare = quranLearnHasComparison(harakaId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compare) ...[
          const SectionLabel('Karşılaştırma'),
          QlPracticeTable(
            audio: audio,
            items: items.take(6).toList(growable: false),
            compare: true,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SectionLabel('Uygulama'),
        QlPracticeTable(audio: audio, items: items, compare: false),
      ],
    );
  }
}
