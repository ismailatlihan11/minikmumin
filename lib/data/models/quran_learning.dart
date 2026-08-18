import '../../core/utils/json_map.dart';

String? _nullableAudio(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;
  return text;
}

class QuranLetterForms {
  const QuranLetterForms({
    required this.isolated,
    required this.initial,
    required this.medial,
    required this.finalForm,
  });

  final String isolated;
  final String initial;
  final String medial;
  final String finalForm;

  factory QuranLetterForms.fromJson(Map<String, dynamic> json) {
    return QuranLetterForms(
      isolated: JsonMap.str(json['isolated']),
      initial: JsonMap.str(json['initial']),
      medial: JsonMap.str(json['medial']),
      finalForm: JsonMap.str(json['final']),
    );
  }
}

class QuranArabicLetter {
  const QuranArabicLetter({
    required this.id,
    required this.order,
    required this.letter,
    required this.name,
    required this.approximateTurkishSound,
    required this.connectionType,
    required this.forms,
    required this.connectsToNext,
    this.audio,
  });

  final String id;
  final int order;
  final String letter;
  final String name;
  final String approximateTurkishSound;
  final String connectionType;
  final QuranLetterForms forms;
  final bool connectsToNext;
  final String? audio;

  bool get joinsBothSides => connectsToNext && connectionType == 'connected';

  factory QuranArabicLetter.fromJson(Map<String, dynamic> json) {
    return QuranArabicLetter(
      id: JsonMap.str(json['id']),
      order: JsonMap.integer(json['order']),
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      approximateTurkishSound: JsonMap.str(json['approximate_turkish_sound']),
      connectionType: JsonMap.str(json['connection_type']),
      forms: QuranLetterForms.fromJson(JsonMap.object(json['forms'])),
      connectsToNext: JsonMap.flag(json['connects_to_next']),
      audio: _nullableAudio(json['audio']),
    );
  }
}

class QuranHarakaExample {
  const QuranHarakaExample({required this.arabic, required this.reading});

  final String arabic;
  final String reading;

  factory QuranHarakaExample.fromJson(Map<String, dynamic> json) {
    return QuranHarakaExample(
      arabic: JsonMap.str(json['arabic']),
      reading: JsonMap.str(json['reading']),
    );
  }
}

class QuranHaraka {
  const QuranHaraka({
    required this.id,
    required this.order,
    required this.name,
    required this.symbol,
    required this.readingRule,
    required this.examples,
    this.audio,
  });

  final String id;
  final int order;
  final String name;
  final String symbol;
  final String readingRule;
  final List<QuranHarakaExample> examples;
  final String? audio;

  factory QuranHaraka.fromJson(Map<String, dynamic> json) {
    return QuranHaraka(
      id: JsonMap.str(json['id']),
      order: JsonMap.integer(json['order']),
      name: JsonMap.str(json['name']),
      symbol: JsonMap.str(json['symbol']),
      readingRule: JsonMap.str(json['reading_rule']),
      examples: JsonMap.extractList(json, itemsKey: 'examples')
          .map(QuranHarakaExample.fromJson)
          .toList(growable: false),
      audio: _nullableAudio(json['audio']),
    );
  }
}

class QuranCombinationExample {
  const QuranCombinationExample({
    required this.parts,
    required this.combined,
    required this.reading,
    this.note,
  });

  final List<String> parts;
  final String combined;
  final String reading;
  final String? note;

  factory QuranCombinationExample.fromJson(Map<String, dynamic> json) {
    final note = json['note'];
    return QuranCombinationExample(
      parts: JsonMap.strings(json['parts']),
      combined: JsonMap.str(json['combined']),
      reading: JsonMap.str(json['reading']),
      note: note == null ? null : JsonMap.str(note),
    );
  }
}

class QuranCombination {
  const QuranCombination({
    required this.id,
    required this.order,
    required this.title,
    required this.examples,
  });

  final String id;
  final int order;
  final String title;
  final List<QuranCombinationExample> examples;

  factory QuranCombination.fromJson(Map<String, dynamic> json) {
    return QuranCombination(
      id: JsonMap.str(json['id']),
      order: JsonMap.integer(json['order']),
      title: JsonMap.str(json['title']),
      examples: JsonMap.extractList(json, itemsKey: 'examples')
          .map(QuranCombinationExample.fromJson)
          .toList(growable: false),
    );
  }
}

class QuranWord {
  const QuranWord({
    required this.id,
    required this.arabic,
    required this.reading,
    required this.meaningTr,
    required this.quranReference,
    this.teachingNote = '',
    this.audio,
  });

  final String id;
  final String arabic;
  final String reading;
  final String meaningTr;
  final String quranReference;
  final String teachingNote;
  final String? audio;

  factory QuranWord.fromJson(Map<String, dynamic> json) {
    return QuranWord(
      id: JsonMap.str(json['id']),
      arabic: JsonMap.str(json['arabic']),
      reading: JsonMap.str(json['reading']),
      meaningTr: JsonMap.str(json['meaning_tr']),
      quranReference: JsonMap.str(json['quran_reference']),
      teachingNote: JsonMap.str(json['teaching_note']),
      audio: _nullableAudio(json['audio']),
    );
  }
}

class QuranTajweedExample {
  const QuranTajweedExample({
    required this.arabic,
    required this.reference,
    required this.focus,
  });

  final String arabic;
  final String reference;
  final String focus;

  factory QuranTajweedExample.fromJson(Map<String, dynamic> json) {
    return QuranTajweedExample(
      arabic: JsonMap.str(json['arabic']),
      reference: JsonMap.str(json['reference']),
      focus: JsonMap.str(json['focus']),
    );
  }
}

class QuranTajweedLesson {
  const QuranTajweedLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.shortDescription,
    required this.explanation,
    required this.examples,
    this.qalqalaLetters = const [],
    this.audio,
  });

  final String id;
  final int order;
  final String title;
  final String shortDescription;
  final String explanation;
  final List<QuranTajweedExample> examples;
  final List<String> qalqalaLetters;
  final String? audio;

  factory QuranTajweedLesson.fromJson(Map<String, dynamic> json) {
    return QuranTajweedLesson(
      id: JsonMap.str(json['id']),
      order: JsonMap.integer(json['order']),
      title: JsonMap.str(json['title']),
      shortDescription: JsonMap.str(json['short_description']),
      explanation: JsonMap.str(json['explanation']),
      examples: JsonMap.extractList(json, itemsKey: 'examples')
          .map(QuranTajweedExample.fromJson)
          .toList(growable: false),
      qalqalaLetters: JsonMap.strings(json['qalqala_letters']),
      audio: _nullableAudio(json['audio']),
    );
  }
}

class QuranLearningGame {
  const QuranLearningGame({
    required this.id,
    required this.type,
    required this.level,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.feedbackCorrect,
    required this.feedbackWrong,
    this.parts = const [],
    this.correctOrder = const [],
    this.result = '',
  });

  final String id;
  final String type;
  final int level;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String feedbackCorrect;
  final String feedbackWrong;
  final List<String> parts;
  final List<String> correctOrder;
  final String result;

  bool get isBuildWord => type == 'build_word';

  factory QuranLearningGame.fromJson(Map<String, dynamic> json) {
    return QuranLearningGame(
      id: JsonMap.str(json['id']),
      type: JsonMap.str(json['type']),
      level: JsonMap.integer(json['level']),
      question: JsonMap.str(json['question']),
      options: JsonMap.strings(json['options']),
      correctAnswer: JsonMap.str(json['correct_answer']),
      feedbackCorrect: JsonMap.str(json['feedback_correct'], 'Harika!'),
      feedbackWrong: JsonMap.str(json['feedback_wrong'], 'Bir daha deneyelim.'),
      parts: JsonMap.strings(json['parts']),
      correctOrder: JsonMap.strings(json['correct_order']),
      result: JsonMap.str(json['result']),
    );
  }
}

class QuranLearningBadge {
  const QuranLearningBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.ruleType,
    required this.ruleValue,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final String ruleType;
  final int ruleValue;

  factory QuranLearningBadge.fromJson(Map<String, dynamic> json) {
    final rule = JsonMap.object(json['rule']);
    return QuranLearningBadge(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      description: JsonMap.str(json['description']),
      icon: JsonMap.str(json['icon']),
      ruleType: JsonMap.str(rule['type']),
      ruleValue: JsonMap.integer(rule['value']),
    );
  }
}

class QuranLearningLevel {
  const QuranLearningLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonCount,
    required this.unlockRule,
    this.prerequisiteLevel,
  });

  final int id;
  final String title;
  final String description;
  final int lessonCount;
  final String unlockRule;
  final int? prerequisiteLevel;

  factory QuranLearningLevel.fromJson(Map<String, dynamic> json) {
    final prereq = json['prerequisite_level'];
    return QuranLearningLevel(
      id: JsonMap.integer(json['id']),
      title: JsonMap.str(json['title']),
      description: JsonMap.str(json['description']),
      lessonCount: JsonMap.integer(json['lesson_count']),
      unlockRule: JsonMap.str(json['unlock_rule'], 'level_completed'),
      prerequisiteLevel: prereq == null ? null : JsonMap.integer(prereq),
    );
  }
}

class QuranLearningSurah {
  const QuranLearningSurah({
    required this.surahNumber,
    required this.nameAr,
    required this.nameTr,
    required this.ayahCount,
    required this.priority,
  });

  final int surahNumber;
  final String nameAr;
  final String nameTr;
  final int ayahCount;
  final int priority;

  String get id => '$surahNumber';

  factory QuranLearningSurah.fromJson(Map<String, dynamic> json) {
    return QuranLearningSurah(
      surahNumber: JsonMap.integer(json['surah_number']),
      nameAr: JsonMap.str(json['name_ar']),
      nameTr: JsonMap.str(json['name_tr']),
      ayahCount: JsonMap.integer(json['ayah_count']),
      priority: JsonMap.integer(json['priority']),
    );
  }
}

class QuranLearnProgressItem {
  const QuranLearnProgressItem({required this.kind, required this.id});

  final String kind;
  final String id;

  String get key => '$kind|$id';
}

class QuranLearningPack {
  const QuranLearningPack({
    required this.letters,
    required this.harakat,
    required this.combinations,
    required this.words,
    required this.tajweed,
    required this.games,
    required this.levels,
    required this.surahs,
    required this.badges,
  });

  final List<QuranArabicLetter> letters;
  final List<QuranHaraka> harakat;
  final List<QuranCombination> combinations;
  final List<QuranWord> words;
  final List<QuranTajweedLesson> tajweed;
  final List<QuranLearningGame> games;
  final List<QuranLearningLevel> levels;
  final List<QuranLearningSurah> surahs;
  final List<QuranLearningBadge> badges;

  QuranArabicLetter? letterById(String id) {
    for (final letter in letters) {
      if (letter.id == id) return letter;
    }
    return null;
  }

  QuranHaraka? harakaById(String id) {
    for (final item in harakat) {
      if (item.id == id) return item;
    }
    return null;
  }

  QuranWord? wordById(String id) {
    for (final word in words) {
      if (word.id == id) return word;
    }
    return null;
  }

  QuranTajweedLesson? tajweedById(String id) {
    for (final lesson in tajweed) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  QuranLearningGame? gameById(String id) {
    for (final game in games) {
      if (game.id == id) return game;
    }
    return null;
  }

  QuranLearningSurah? surahByNumber(int number) {
    for (final surah in surahs) {
      if (surah.surahNumber == number) return surah;
    }
    return null;
  }

  List<QuranLearningGame> gamesForLevel(int level) {
    return games.where((game) => game.level == level).toList(growable: false);
  }

  List<QuranLearnProgressItem> itemsForLevel(int levelId) {
    switch (levelId) {
      case 1:
        return [
          for (final letter in letters)
            QuranLearnProgressItem(kind: 'ql_letter', id: letter.id),
        ];
      case 2:
        return [
          for (final item in harakat)
            QuranLearnProgressItem(kind: 'ql_haraka', id: item.id),
        ];
      case 3:
        return [
          for (final item in combinations)
            QuranLearnProgressItem(kind: 'ql_comb', id: item.id),
        ];
      case 4:
        return [
          for (final word in words)
            QuranLearnProgressItem(kind: 'ql_word', id: word.id),
        ];
      case 5:
        return [
          for (final surah in surahs)
            QuranLearnProgressItem(kind: 'ql_surah', id: surah.id),
        ];
      case 6:
        return [
          for (final lesson in tajweed)
            QuranLearnProgressItem(kind: 'ql_tajweed', id: lesson.id),
        ];
      case 7:
        return [
          for (final surah in surahs)
            QuranLearnProgressItem(kind: 'ql_practice', id: surah.id),
        ];
      case 8:
        return [
          for (final surah in surahs)
            QuranLearnProgressItem(kind: 'ql_tajweed_read', id: surah.id),
        ];
      default:
        return const [];
    }
  }

  int realLessonCount(int levelId) => itemsForLevel(levelId).length;

  factory QuranLearningPack.fromJson(Map<String, dynamic> json) {
    final letters = JsonMap.extractList(
      JsonMap.object(json['quran_arabic_letters']),
      itemsKey: 'letters',
    ).map(QuranArabicLetter.fromJson).toList();
    letters.sort((a, b) => a.order.compareTo(b.order));

    final harakat = JsonMap.extractList(
      JsonMap.object(json['quran_harakat']),
      itemsKey: 'items',
    ).map(QuranHaraka.fromJson).toList();
    harakat.sort((a, b) => a.order.compareTo(b.order));

    final combinations = JsonMap.extractList(
      JsonMap.object(json['quran_combinations']),
      itemsKey: 'lessons',
    ).map(QuranCombination.fromJson).toList();
    combinations.sort((a, b) => a.order.compareTo(b.order));

    final words = JsonMap.extractList(
      JsonMap.object(json['quran_words']),
      itemsKey: 'words',
    ).map(QuranWord.fromJson).toList(growable: false);

    final tajweed = JsonMap.extractList(
      JsonMap.object(json['quran_tajweed']),
      itemsKey: 'lessons',
    ).map(QuranTajweedLesson.fromJson).toList();
    tajweed.sort((a, b) => a.order.compareTo(b.order));

    final games = JsonMap.extractList(
      JsonMap.object(json['quran_learning_games']),
      itemsKey: 'games',
    ).map(QuranLearningGame.fromJson).toList(growable: false);

    final levels = JsonMap.extractList(
      JsonMap.object(json['quran_learning_levels']),
      itemsKey: 'levels',
    ).map(QuranLearningLevel.fromJson).toList();
    levels.sort((a, b) => a.id.compareTo(b.id));

    final surahs = JsonMap.extractList(
      JsonMap.object(json['quran_learning_surahs']),
      itemsKey: 'surahs',
    ).map(QuranLearningSurah.fromJson).toList();
    surahs.sort((a, b) => a.priority.compareTo(b.priority));

    final badges = JsonMap.extractList(
      JsonMap.object(json['quran_learning_badges']),
      itemsKey: 'badges',
    ).map(QuranLearningBadge.fromJson).toList(growable: false);

    return QuranLearningPack(
      letters: List<QuranArabicLetter>.unmodifiable(letters),
      harakat: List<QuranHaraka>.unmodifiable(harakat),
      combinations: List<QuranCombination>.unmodifiable(combinations),
      words: words,
      tajweed: List<QuranTajweedLesson>.unmodifiable(tajweed),
      games: games,
      levels: List<QuranLearningLevel>.unmodifiable(levels),
      surahs: List<QuranLearningSurah>.unmodifiable(surahs),
      badges: badges,
    );
  }
}
