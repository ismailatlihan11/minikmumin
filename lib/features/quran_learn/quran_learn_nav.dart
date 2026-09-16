import 'package:flutter/material.dart';

import '../../data/models/quran_learning.dart';
import 'quran_learn_combine.dart';
import 'quran_learn_exam.dart';
import 'quran_learn_games.dart';
import 'quran_learn_harakat.dart';
import 'quran_learn_heavy.dart';
import 'quran_learn_letters.dart';
import 'quran_learn_mahraj.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_review.dart';
import 'quran_learn_surahs.dart';
import 'quran_learn_syllables.dart';
import 'quran_learn_tajweed.dart';
import 'quran_learn_theme.dart';
import 'quran_learn_words.dart';

export 'quran_learn_theme.dart';

const elifbaPathIds = <int>[1, 9, 2, 5];
const elifbaDrillIds = <int>[3, 4, 11, 12, 13];
const elifbaTajweedIds = <int>[6];
const elifbaReadIds = <int>[7, 8];

String elifbaStepTitle(QuranLearningLevel level) {
  switch (level.id) {
    case 1:
      return 'Harfler';
    case 9:
      return 'Harfler ve şekilleri';
    case 10:
      return 'Pekiştirme';
    case 2:
      return 'Harekeler';
    case 3:
      return 'Birleştirme';
    case 4:
      return 'Kelimeler';
    case 5:
      return 'Kısa sureler';
    case 6:
      return 'Kurallar';
    case 7:
      return 'Ayet parçaları';
    case 8:
      return 'Tecvidli okuma';
    case 11:
      return 'Kalın ve ince';
    case 12:
      return 'Mahreçler';
    case 13:
      return 'Mini oyunlar';
    default:
      return level.title;
  }
}

String elifbaStepCue(QuranLearningLevel level) {
  switch (level.id) {
    case 1:
      return 'Dokun, dinle';
    case 9:
      return 'Başta, ortada, sonda';
    case 10:
      return 'Kelimede tanı';
    case 2:
      return 'Üstün, esre, ötre';
    case 3:
      return 'Harfleri birleştir';
    case 4:
      return 'Kelimede oku';
    case 5:
      return 'Fâtiha ve İhlâs';
    case 6:
      return 'İzhâr, ihfâ, idğâm';
    case 7:
      return 'Bakara ve Kürsî';
    case 8:
      return 'Surede kuralı gör';
    case 11:
      return 'Kalın ses, ince ses';
    case 12:
      return 'Boğaz, dil, dudak';
    case 13:
      return 'Bul, eşleştir, boya';
    default:
      return 'Sırada';
  }
}

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
    'letter_review' => QuranLearnReviewPage(pack: pack, levelId: levelId),
    'harakat' => QuranLearnHarakatPage(pack: pack, levelId: levelId),
    'combine' => QuranLearnCombinePage(pack: pack, levelId: levelId),
    'words' => QuranLearnWordsPage(pack: pack, levelId: levelId),
    'mahraj' => QuranLearnMahrajPage(pack: pack, levelId: levelId),
    'heavy_light' => QuranLearnHeavyPage(pack: pack, levelId: levelId),
    'tajweed' => QuranLearnTajweedPage(pack: pack, levelId: levelId),
    'syllables' => QuranLearnSyllablesPage(pack: pack, levelId: levelId),
    'games' => QuranLearnDrillGamesPage(pack: pack, levelId: levelId),
    'surahs' => QuranLearnSurahsPage(pack: pack, levelId: levelId),
    'practice' => QuranLearnSurahsPage(
        pack: pack,
        levelId: levelId,
        mode: QuranLearnReadMode.practice,
      ),
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
        9 => QuranLearnLettersPage(
            pack: pack,
            levelId: levelId,
            formsFocus: true,
          ),
        10 => QuranLearnReviewPage(pack: pack, levelId: levelId),
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
    quranLearnRoute(quranLearnPageFor(pack: pack, levelId: levelId)),
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
        quranLearnRoute(
          QuranLearnLetterDetailPage(
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
        quranLearnRoute(
          QuranLearnHarakaDetailPage(
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
        quranLearnRoute(
          QuranLearnCombineDetailPage(
            pack: pack,
            lesson: combination,
          ),
        ),
      );
    case 'ql_word':
    case 'ql_letter_review':
      final word = pack.wordById(item.id);
      if (word == null) break;
      return Navigator.push(
        context,
        quranLearnRoute(
          QuranLearnWordDetailPage(pack: pack, word: word),
        ),
      );
    case 'ql_tajweed':
      final tajweed = pack.tajweedById(item.id);
      if (tajweed == null) break;
      return Navigator.push(
        context,
        quranLearnRoute(
          QuranLearnTajweedDetailPage(pack: pack, lesson: tajweed),
        ),
      );
    case 'ql_mahraj':
      final group = pack.mahrajById(item.id);
      if (group == null) break;
      return Navigator.push(
        context,
        quranLearnRoute(
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
    case 'ql_game':
      final game = pack.gameById(item.id);
      if (game == null) {
        return openQuranLearnLevel(
          context,
          pack: pack,
          levelId: lesson.level?.id ?? 13,
        );
      }
      return openQuranLearnGame(context, game);
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
        quranLearnRoute(
          QuranLearnSurahReaderPage(
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
