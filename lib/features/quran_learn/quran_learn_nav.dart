import 'package:flutter/material.dart';

import '../../data/models/quran_learning.dart';
import 'quran_learn_combine.dart';
import 'quran_learn_exam.dart';
import 'quran_learn_harakat.dart';
import 'quran_learn_heavy.dart';
import 'quran_learn_letters.dart';
import 'quran_learn_mahraj.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_surahs.dart';
import 'quran_learn_syllables.dart';
import 'quran_learn_tajweed.dart';
import 'quran_learn_words.dart';

Widget quranLearnPageFor({
  required QuranLearningPack pack,
  required int levelId,
}) {
  final screen = pack.levelById(levelId)?.screen.trim() ?? '';
  return switch (screen) {
    'letters' => QuranLearnLettersPage(pack: pack, levelId: levelId),
    'letter_forms' => QuranLearnLettersPage(
        pack: pack,
        levelId: levelId,
        formsFocus: true,
      ),
    'harakat' => QuranLearnHarakatPage(pack: pack, levelId: levelId),
    'mahraj' => QuranLearnMahrajPage(pack: pack, levelId: levelId),
    'heavy_light' => QuranLearnHeavyPage(pack: pack, levelId: levelId),
    'tajweed' => QuranLearnTajweedPage(pack: pack, levelId: levelId),
    'syllables' => QuranLearnSyllablesPage(pack: pack, levelId: levelId),
    'surahs' => QuranLearnSurahsPage(pack: pack, levelId: levelId),
    'tajweed_read' => QuranLearnSurahsPage(
        pack: pack,
        levelId: levelId,
        mode: QuranLearnReadMode.tajweedRead,
      ),
    'exam' => QuranLearnExamPage(pack: pack, levelId: levelId),
    _ => switch (levelId) {
        1 => QuranLearnLettersPage(pack: pack, levelId: levelId),
        2 => QuranLearnHarakatPage(pack: pack, levelId: levelId),
        3 => QuranLearnCombinePage(pack: pack, levelId: levelId),
        4 => QuranLearnWordsPage(pack: pack, levelId: levelId),
        5 => QuranLearnSurahsPage(pack: pack, levelId: levelId),
        6 => QuranLearnTajweedPage(pack: pack, levelId: levelId),
        7 => QuranLearnSurahsPage(
            pack: pack,
            levelId: levelId,
            mode: QuranLearnReadMode.practice,
          ),
        8 => QuranLearnSurahsPage(
            pack: pack,
            levelId: levelId,
            mode: QuranLearnReadMode.tajweedRead,
          ),
        _ => QuranLearnLettersPage(pack: pack, levelId: levelId),
      },
  };
}

Future<void> openQuranLearnLevel(
  BuildContext context, {
  required QuranLearningPack pack,
  required int levelId,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => quranLearnPageFor(pack: pack, levelId: levelId),
    ),
  );
}

Future<void> openQuranLearnDaily(
  BuildContext context, {
  required QuranLearningPack pack,
  required QuranLearnDailyLesson lesson,
}) {
  final item = lesson.item;
  if (item == null) {
    return openQuranLearnLevel(
      context,
      pack: pack,
      levelId: lesson.level?.id ?? 1,
    );
  }
  switch (item.kind) {
    case 'ql_letter':
    case 'ql_letter_form':
      final letter = pack.letterById(item.id);
      if (letter == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranLearnLetterDetailPage(
            pack: pack,
            letter: letter,
            levelId: lesson.level?.id,
            formsFocus: item.kind == 'ql_letter_form',
          ),
        ),
      );
    case 'ql_haraka':
      final haraka = pack.harakaById(item.id);
      if (haraka == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranLearnHarakaDetailPage(
            pack: pack,
            haraka: haraka,
            levelId: lesson.level?.id,
          ),
        ),
      );
    case 'ql_comb':
      final combination = pack.combinationById(item.id);
      if (combination == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranLearnCombineDetailPage(
            pack: pack,
            lesson: combination,
          ),
        ),
      );
    case 'ql_word':
      final word = pack.wordById(item.id);
      if (word == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranLearnWordDetailPage(pack: pack, word: word),
        ),
      );
    case 'ql_tajweed':
      final tajweed = pack.tajweedById(item.id);
      if (tajweed == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuranLearnTajweedDetailPage(pack: pack, lesson: tajweed),
        ),
      );
    case 'ql_mahraj':
      final group = pack.mahrajById(item.id);
      if (group == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuranLearnMahrajDetailPage(pack: pack, group: group),
        ),
      );
    case 'ql_heavy':
    case 'ql_exam':
      return openQuranLearnLevel(
        context,
        pack: pack,
        levelId: lesson.level?.id ?? 1,
      );
    case 'ql_surah':
    case 'ql_practice':
    case 'ql_tajweed_read':
      final surah = pack.surahById(item.id);
      if (surah == null) break;
      final mode = switch (item.kind) {
        'ql_practice' => QuranLearnReadMode.practice,
        'ql_tajweed_read' => QuranLearnReadMode.tajweedRead,
        _ => QuranLearnReadMode.surah,
      };
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranLearnSurahReaderPage(
            pack: pack,
            surah: surah,
            mode: mode,
          ),
        ),
      );
  }
  return openQuranLearnLevel(
    context,
    pack: pack,
    levelId: lesson.level?.id ?? 1,
  );
}
