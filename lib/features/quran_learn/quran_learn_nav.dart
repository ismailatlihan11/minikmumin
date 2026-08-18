import 'package:flutter/material.dart';

import '../../data/models/quran_learning.dart';
import 'quran_learn_combine.dart';
import 'quran_learn_harakat.dart';
import 'quran_learn_letters.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_surahs.dart';
import 'quran_learn_tajweed.dart';
import 'quran_learn_words.dart';

Future<void> openQuranLearnLevel(
  BuildContext context, {
  required QuranLearningPack pack,
  required int levelId,
}) {
  final Widget page = switch (levelId) {
    1 => QuranLearnLettersPage(pack: pack),
    2 => QuranLearnHarakatPage(pack: pack),
    3 => QuranLearnCombinePage(pack: pack),
    4 => QuranLearnWordsPage(pack: pack),
    5 => QuranLearnSurahsPage(pack: pack),
    6 => QuranLearnTajweedPage(pack: pack),
    7 => QuranLearnSurahsPage(
        pack: pack,
        mode: QuranLearnReadMode.practice,
      ),
    8 => QuranLearnSurahsPage(
        pack: pack,
        mode: QuranLearnReadMode.tajweedRead,
      ),
    _ => QuranLearnLettersPage(pack: pack),
  };
  return Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
      final letter = pack.letterById(item.id);
      if (letter == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuranLearnLetterDetailPage(pack: pack, letter: letter),
        ),
      );
    case 'ql_haraka':
      final haraka = pack.harakaById(item.id);
      if (haraka == null) break;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QuranLearnHarakaDetailPage(pack: pack, haraka: haraka),
        ),
      );
    case 'ql_comb':
      return openQuranLearnLevel(context, pack: pack, levelId: 3);
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
    case 'ql_surah':
    case 'ql_practice':
    case 'ql_tajweed_read':
      final number = int.tryParse(item.id) ?? 0;
      final surah = pack.surahByNumber(number);
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
