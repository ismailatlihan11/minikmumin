import '../../core/utils/json_map.dart';

class ElifbaPack {
  const ElifbaPack({
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String title;
  final String description;
  final List<ElifbaLesson> lessons;

  ElifbaLesson? byId(int id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  /// Prefer the 28-letter table whose marked forms match a haraka/cezm/shadda.
  List<ElifbaLetterRow> tableMatchingMark(String mark) {
    if (mark.isEmpty) return const [];
    List<ElifbaLetterRow> best = const [];
    var bestScore = 0;
    for (final lesson in lessons) {
      final table = lesson.letterTable;
      if (table.length < 20) continue;
      final score = table.where((row) => row.marked.contains(mark)).length;
      if (score > bestScore) {
        bestScore = score;
        best = table;
      }
    }
    return bestScore >= 20 ? best : const [];
  }

  List<ElifbaLetterRow> teachingTableFor(ElifbaLesson lesson) {
    final mark = lesson.rule?.symbol ?? '';
    final matched = tableMatchingMark(mark);
    if (matched.isNotEmpty) return matched;
    if (_tableFitsLesson(lesson, lesson.letterTable)) {
      return lesson.letterTable;
    }
    for (final other in lessons) {
      final table = other.letterTable;
      if (table.isEmpty) continue;
      if (table.first.marked.isNotEmpty) continue;
      if (_tableFitsLesson(lesson, table)) return table;
    }
    return const [];
  }

  bool _tableFitsLesson(ElifbaLesson lesson, List<ElifbaLetterRow> table) {
    if (table.isEmpty) return false;
    final cat = _fold(table.first.category);
    if (cat.isEmpty) return true;
    final title = _fold(lesson.title);
    if (cat.contains('izhar')) return title.contains('izhar');
    if (cat.contains('idgam')) return title.contains('idgam');
    if (cat.contains('ihfa')) return title.contains('ihfa');
    if (cat.contains('iklab')) return title.contains('iklab');
    return true;
  }

  static String _fold(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u')
        .replaceAll('ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('\u0307', '');
  }

  ElifbaLesson? lessonOwningMark(String mark) {
    if (mark.isEmpty) return null;
    ElifbaLesson? best;
    var bestScore = 0;
    for (final lesson in lessons) {
      final table = lesson.letterTable;
      if (table.length < 20) continue;
      final score = table.where((row) => row.marked.contains(mark)).length;
      if (score > bestScore) {
        bestScore = score;
        best = lesson;
      }
    }
    return bestScore >= 20 ? best : null;
  }

  String teachingTitleFor(ElifbaLesson lesson) {
    final owner = lessonOwningMark(lesson.rule?.symbol ?? '');
    final title = owner?.tableTitle ?? '';
    if (title.isNotEmpty) return title;
    return lesson.tableTitle;
  }

  String teachingInstructionFor(ElifbaLesson lesson) {
    final owner = lessonOwningMark(lesson.rule?.symbol ?? '');
    final instruction = owner?.tableInstruction ?? '';
    if (instruction.isNotEmpty) return instruction;
    return lesson.tableInstruction;
  }

  factory ElifbaPack.fromJson(Map<String, dynamic> json) {
    final lessons = JsonMap.extractList(json, itemsKey: 'lessons')
        .map(ElifbaLesson.fromJson)
        .toList(growable: false);
    return ElifbaPack(
      title: JsonMap.str(json['title'], "Elifbâ + Tecvid Macerası"),
      description: JsonMap.str(
        json['description'],
        "Kur'an okumayı eğlenerek öğren!",
      ),
      lessons: lessons,
    );
  }
}

class ElifbaLesson {
  const ElifbaLesson({
    required this.id,
    required this.title,
    required this.level,
    required this.goal,
    required this.explanation,
    required this.raw,
    required this.quiz,
  });

  final int id;
  final String title;
  final String level;
  final String goal;
  final String explanation;
  final Map<String, dynamic> raw;
  final List<ElifbaQuizItem> quiz;

  bool has(String key) {
    final value = raw[key];
    if (value == null) return false;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  List<ElifbaLetter> get letters {
    final value = raw['letters'];
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is String) {
            return ElifbaLetter(letter: item, name: '');
          }
          return ElifbaLetter.fromJson(JsonMap.object(item));
        })
        .where((item) => item.letter.isNotEmpty)
        .toList(growable: false);
  }

  List<String> get letterGlyphs {
    final named = letters;
    if (named.isNotEmpty) {
      return [for (final item in named) item.letter];
    }
    return JsonMap.strings(raw['letters']);
  }

  List<ElifbaExample> get examples =>
      _maps('examples').map(ElifbaExample.fromJson).toList(growable: false);

  List<ElifbaExample> get practice =>
      _maps('practice').map(ElifbaExample.fromJson).toList(growable: false);

  List<ElifbaExample> get comparison =>
      _maps('comparison')
          .where((item) => JsonMap.str(item['text']).isNotEmpty)
          .map(ElifbaExample.fromJson)
          .toList(growable: false);

  List<ElifbaComparePair> get comparePairs => _maps('comparison')
      .where((item) => JsonMap.str(item['group']).isNotEmpty)
      .map(ElifbaComparePair.fromJson)
      .toList(growable: false);

  List<ElifbaLetterRow> get letterTable =>
      _maps('letter_table').map(ElifbaLetterRow.fromJson).toList(growable: false);

  String get tableTitle => JsonMap.str(raw['table_title']);

  String get tableInstruction => JsonMap.str(raw['table_instruction']);

  String get importantNote => JsonMap.str(raw['important_note']);

  List<String> get decisionTree => JsonMap.strings(raw['decision_tree']);

  ElifbaUiPattern get uiPattern =>
      ElifbaUiPattern.fromJson(JsonMap.object(raw['ui_learning_pattern']));

  ElifbaRich get rich =>
      ElifbaRich.fromJson(JsonMap.object(raw['rich_content']));

  List<ElifbaLetter> get specialLetters {
    final value = raw['special_letters'];
    if (value is! List) return const [];
    return value
        .map((item) => ElifbaLetter.fromJson(JsonMap.object(item)))
        .toList(growable: false);
  }

  Map<String, List<ElifbaLetterRow>> get categoryTables {
    final value = raw['category_tables'];
    if (value is! Map) return const {};
    return {
      for (final entry in JsonMap.object(value).entries)
        if (entry.value is List)
          entry.key: (entry.value as List)
              .map((item) => ElifbaLetterRow.fromJson(JsonMap.object(item)))
              .toList(growable: false),
    };
  }

  List<ElifbaMedRow> get medTable =>
      _maps('med_table').map(ElifbaMedRow.fromJson).toList(growable: false);

  List<ElifbaExample> get blending =>
      _maps('blending').map(ElifbaExample.fromJson).toList(growable: false);

  List<String> get activities => JsonMap.strings(raw['activities']);

  List<String> get summaryPoints => JsonMap.strings(raw['summary_points']);

  String get characterMessage => JsonMap.str(raw['character_message']);

  ElifbaRule? get rule {
    final value = raw['rule'];
    if (value is! Map) return null;
    return ElifbaRule.fromJson(JsonMap.object(value));
  }

  ElifbaFocusLetter? get focusLetter {
    final value = raw['focus_letter'];
    if (value is! Map) return null;
    return ElifbaFocusLetter.fromJson(JsonMap.object(value));
  }

  List<ElifbaType> get types =>
      _maps('types').map(ElifbaType.fromJson).toList(growable: false);

  List<ElifbaMedLetter> get medLetters =>
      _maps('med_letters').map(ElifbaMedLetter.fromJson).toList(growable: false);

  List<ElifbaCategory> get categories =>
      _maps('categories').map(ElifbaCategory.fromJson).toList(growable: false);

  List<ElifbaNamed> get rulesSummary =>
      _maps('rules_summary').map(ElifbaNamed.fromJson).toList(growable: false);

  List<ElifbaNamed> get rules =>
      _maps('rules').map(ElifbaNamed.fromJson).toList(growable: false);

  List<ElifbaNamed> get basicRules =>
      _maps('basic_rules').map(ElifbaNamed.fromJson).toList(growable: false);

  List<ElifbaNamed> get concepts =>
      _maps('concepts').map(ElifbaNamed.fromJson).toList(growable: false);

  List<ElifbaNamed> get signs =>
      _maps('signs').map(ElifbaNamed.fromJson).toList(growable: false);

  List<ElifbaGroup> get groups =>
      _maps('groups').map(ElifbaGroup.fromJson).toList(growable: false);

  List<ElifbaPair> get pairs =>
      _maps('pairs').map(ElifbaPair.fromJson).toList(growable: false);

  List<ElifbaVerse> get verses =>
      _maps('verses').map(ElifbaVerse.fromJson).toList(growable: false);

  List<ElifbaSurah> get surahs =>
      _maps('surahs').map(ElifbaSurah.fromJson).toList(growable: false);

  String get memoryPhrase => JsonMap.str(raw['memory_phrase']);

  String get noteForApp => JsonMap.str(raw['note_for_app']);

  ElifbaStepExample? get stepExample {
    final value = raw['step_example'];
    if (value is! Map) return null;
    return ElifbaStepExample.fromJson(JsonMap.object(value));
  }

  ElifbaCompletion? get completion {
    final value = raw['completion_rule'];
    if (value is! Map) return null;
    return ElifbaCompletion.fromJson(JsonMap.object(value));
  }

  List<String> get practiceFlow => JsonMap.strings(raw['practice_flow']);

  bool get isFinal =>
      has('completion_rule') || title.toLowerCase().contains('final');

  List<Map<String, dynamic>> _maps(String key) {
    final value = raw[key];
    if (value is! List) return const [];
    return value.map(JsonMap.object).toList(growable: false);
  }

  factory ElifbaLesson.fromJson(Map<String, dynamic> json) {
    return ElifbaLesson(
      id: JsonMap.integer(json['id']),
      title: JsonMap.str(json['title']),
      level: JsonMap.str(json['level']),
      goal: JsonMap.str(json['goal']),
      explanation: JsonMap.str(json['explanation']),
      raw: json,
      quiz: JsonMap.extractList(json, itemsKey: 'quiz')
          .map(ElifbaQuizItem.fromJson)
          .toList(growable: false),
    );
  }
}

class ElifbaLetter {
  const ElifbaLetter({required this.letter, required this.name, this.note = ''});

  final String letter;
  final String name;
  final String note;

  factory ElifbaLetter.fromJson(Map<String, dynamic> json) {
    return ElifbaLetter(
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      note: JsonMap.str(json['note']),
    );
  }
}

class ElifbaExample {
  const ElifbaExample({
    required this.text,
    this.reading = '',
    this.note = '',
    this.focus = '',
    this.rule = '',
    this.audio = '',
  });

  final String text;
  final String reading;
  final String note;
  final String focus;
  final String rule;
  final String audio;

  String get subtitle {
    if (reading.isNotEmpty) return reading;
    if (rule.isNotEmpty) return rule;
    if (note.isNotEmpty) return note;
    return '';
  }

  factory ElifbaExample.fromJson(Map<String, dynamic> json) {
    return ElifbaExample(
      text: JsonMap.str(json['text']),
      reading: JsonMap.str(json['reading']),
      note: JsonMap.str(json['note']),
      focus: JsonMap.str(json['focus']),
      rule: JsonMap.str(json['rule']),
      audio: JsonMap.str(
        json['audio'] ?? json['audio_example'] ?? json['audio_word'],
      ),
    );
  }
}

class ElifbaQuizItem {
  const ElifbaQuizItem({
    required this.question,
    required this.options,
    required this.answer,
    this.id = 0,
  });

  final int id;
  final String question;
  final List<String> options;
  final String answer;

  factory ElifbaQuizItem.fromJson(Map<String, dynamic> json) {
    return ElifbaQuizItem(
      id: JsonMap.integer(json['id']),
      question: JsonMap.str(json['question']),
      options: JsonMap.strings(json['options']),
      answer: JsonMap.str(json['answer']),
    );
  }
}

class ElifbaRule {
  const ElifbaRule({
    this.symbol = '',
    this.name = '',
    this.sound = '',
    this.concept = '',
    this.letter = '',
    this.transformation = '',
    this.note = '',
  });

  final String symbol;
  final String name;
  final String sound;
  final String concept;
  final String letter;
  final String transformation;
  final String note;

  factory ElifbaRule.fromJson(Map<String, dynamic> json) {
    return ElifbaRule(
      symbol: JsonMap.str(json['symbol']),
      name: JsonMap.str(json['name']),
      sound: JsonMap.str(json['sound']),
      concept: JsonMap.str(json['concept']),
      letter: JsonMap.str(json['letter']),
      transformation: JsonMap.str(json['transformation']),
      note: JsonMap.str(json['note']),
    );
  }
}

class ElifbaFocusLetter {
  const ElifbaFocusLetter({required this.letter, required this.forms});

  final String letter;
  final Map<String, String> forms;

  factory ElifbaFocusLetter.fromJson(Map<String, dynamic> json) {
    final formsRaw = JsonMap.object(json['forms']);
    return ElifbaFocusLetter(
      letter: JsonMap.str(json['letter']),
      forms: {
        for (final entry in formsRaw.entries)
          entry.key: JsonMap.str(entry.value),
      },
    );
  }
}

class ElifbaType {
  const ElifbaType({
    required this.symbol,
    required this.name,
    required this.reading,
  });

  final String symbol;
  final String name;
  final String reading;

  factory ElifbaType.fromJson(Map<String, dynamic> json) {
    return ElifbaType(
      symbol: JsonMap.str(json['symbol']),
      name: JsonMap.str(json['name']),
      reading: JsonMap.str(json['reading']),
    );
  }
}

class ElifbaMedLetter {
  const ElifbaMedLetter({
    required this.letter,
    required this.condition,
    required this.sound,
    required this.example,
    required this.reading,
  });

  final String letter;
  final String condition;
  final String sound;
  final String example;
  final String reading;

  factory ElifbaMedLetter.fromJson(Map<String, dynamic> json) {
    return ElifbaMedLetter(
      letter: JsonMap.str(json['letter']),
      condition: JsonMap.str(json['condition']),
      sound: JsonMap.str(json['sound']),
      example: JsonMap.str(json['example']),
      reading: JsonMap.str(json['reading']),
    );
  }
}

class ElifbaCategory {
  const ElifbaCategory({
    required this.name,
    required this.letters,
    this.note = '',
    this.arabicName = '',
    this.memoryPhrase = '',
    this.meaning = '',
    this.examples = const [],
  });

  final String name;
  final List<String> letters;
  final String note;
  final String arabicName;
  final String memoryPhrase;
  final String meaning;
  final List<ElifbaExample> examples;

  factory ElifbaCategory.fromJson(Map<String, dynamic> json) {
    return ElifbaCategory(
      name: JsonMap.str(json['name']),
      letters: JsonMap.strings(json['letters']),
      note: JsonMap.str(json['note']),
      arabicName: JsonMap.str(json['arabic_name']),
      memoryPhrase: JsonMap.str(json['memory_phrase']),
      meaning: JsonMap.str(json['meaning']),
      examples: json['examples'] is List
          ? (json['examples'] as List)
              .map((item) => ElifbaExample.fromJson(JsonMap.object(item)))
              .toList(growable: false)
          : const [],
    );
  }
}

class ElifbaLetterRow {
  const ElifbaLetterRow({
    required this.letter,
    required this.name,
    this.marked = '',
    this.reading = '',
    this.note = '',
    this.category = '',
    this.type = '',
    this.memory = '',
    this.example = '',
    this.audioLetter = '',
    this.audioExample = '',
  });

  final String letter;
  final String name;
  final String marked;
  final String reading;
  final String note;
  final String category;
  final String type;
  final String memory;
  final String example;
  final String audioLetter;
  final String audioExample;

  String get markedCaption {
    if (marked.contains('ّ')) return 'Şeddeli hali';
    if (marked.contains('ْ')) return 'Cezmli hali';
    if (marked.contains('ُ')) return 'Ötreli hali';
    if (marked.contains('ِ')) return 'Esreli hali';
    if (marked.contains('َ')) return 'Fethalı hali';
    if (marked.contains('ٌ') || marked.contains('ٍ') || marked.contains('ً')) {
      return 'Tenvinli hali';
    }
    return 'İşaretli hali';
  }

  factory ElifbaLetterRow.fromJson(Map<String, dynamic> json) {
    return ElifbaLetterRow(
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      marked: JsonMap.str(json['marked']),
      reading: JsonMap.str(json['reading']),
      note: JsonMap.str(json['note']),
      category: JsonMap.str(json['category']),
      type: JsonMap.str(json['type']),
      memory: JsonMap.str(json['memory']),
      example: JsonMap.str(json['example']),
      audioLetter: JsonMap.str(json['audio_letter']),
      audioExample: JsonMap.str(
        json['audio_example'] ?? json['audio'] ?? json['audio_word'],
      ),
    );
  }
}

class ElifbaComparePair {
  const ElifbaComparePair({
    required this.group,
    required this.difference,
    required this.examples,
  });

  final String group;
  final String difference;
  final List<String> examples;

  List<String> get glyphs {
    return group
        .split('/')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  factory ElifbaComparePair.fromJson(Map<String, dynamic> json) {
    return ElifbaComparePair(
      group: JsonMap.str(json['group']),
      difference: JsonMap.str(json['difference']),
      examples: JsonMap.strings(json['examples']),
    );
  }
}

class ElifbaMedRow {
  const ElifbaMedRow({
    required this.letter,
    required this.name,
    required this.formula,
    required this.pattern,
    required this.reading,
    required this.examples,
  });

  final String letter;
  final String name;
  final String formula;
  final String pattern;
  final String reading;
  final List<String> examples;

  factory ElifbaMedRow.fromJson(Map<String, dynamic> json) {
    return ElifbaMedRow(
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      formula: JsonMap.str(json['formula']),
      pattern: JsonMap.str(json['pattern']),
      reading: JsonMap.str(json['reading']),
      examples: JsonMap.strings(json['examples']),
    );
  }
}

class ElifbaUiPattern {
  const ElifbaUiPattern({
    this.showLargeArabic = true,
    this.showLetterName = true,
    this.showReading = true,
    this.showAudio = true,
    this.showRepeat = true,
    this.allowFavorite = true,
  });

  final bool showLargeArabic;
  final bool showLetterName;
  final bool showReading;
  final bool showAudio;
  final bool showRepeat;
  final bool allowFavorite;

  factory ElifbaUiPattern.fromJson(Map<String, dynamic> json) {
    return ElifbaUiPattern(
      showLargeArabic: JsonMap.flag(json['show_large_arabic'], true),
      showLetterName: JsonMap.flag(json['show_letter_name'], true),
      showReading: JsonMap.flag(json['show_reading'], true),
      showAudio: JsonMap.flag(json['show_audio_button'], true),
      showRepeat: JsonMap.flag(json['show_repeat_button'], true),
      allowFavorite: JsonMap.flag(json['allow_favorite_example'], true),
    );
  }
}

class ElifbaRich {
  const ElifbaRich({
    this.objective = '',
    this.teacherNote = '',
    this.repeatInstruction = '',
    this.sequence = const [],
    this.ruleCards = const [],
    this.wordExamples = const [],
  });

  final String objective;
  final String teacherNote;
  final String repeatInstruction;
  final List<String> sequence;
  final List<ElifbaNamed> ruleCards;
  final List<ElifbaExample> wordExamples;

  factory ElifbaRich.fromJson(Map<String, dynamic> json) {
    final words = json['examples_with_words'];
    return ElifbaRich(
      objective: JsonMap.str(json['lesson_objective']),
      teacherNote: JsonMap.str(json['teacher_note']),
      repeatInstruction: JsonMap.str(json['repeat_instruction']),
      sequence: JsonMap.strings(json['learning_sequence']),
      ruleCards: json['rule_cards'] is List
          ? (json['rule_cards'] as List)
              .map((item) => ElifbaNamed.fromJson(JsonMap.object(item)))
              .toList(growable: false)
          : const [],
      wordExamples: words is List
          ? words.map((item) {
              if (item is List && item.isNotEmpty) {
                return ElifbaExample(
                  text: JsonMap.str(item[0]),
                  reading: item.length > 1 ? JsonMap.str(item[1]) : '',
                );
              }
              return ElifbaExample.fromJson(JsonMap.object(item));
            }).toList(growable: false)
          : const [],
    );
  }
}

class ElifbaNamed {
  const ElifbaNamed({
    required this.title,
    required this.detail,
    this.extra = '',
  });

  final String title;
  final String detail;
  final String extra;

  factory ElifbaNamed.fromJson(Map<String, dynamic> json) {
    return ElifbaNamed(
      title: JsonMap.str(
        json['name'] ?? json['term'] ?? json['symbol'] ?? json['pattern'],
      ),
      detail: JsonMap.str(
        json['meaning'] ??
            json['reading'] ??
            json['condition'] ??
            json['note'] ??
            json['example'],
      ),
      extra: JsonMap.str(json['example'] ?? json['condition']),
    );
  }
}

class ElifbaGroup {
  const ElifbaGroup({required this.name, required this.letters});

  final String name;
  final List<String> letters;

  factory ElifbaGroup.fromJson(Map<String, dynamic> json) {
    return ElifbaGroup(
      name: JsonMap.str(json['name']),
      letters: JsonMap.strings(json['letters']),
    );
  }
}

class ElifbaPair {
  const ElifbaPair({required this.group, required this.details});

  final String group;
  final String details;

  factory ElifbaPair.fromJson(Map<String, dynamic> json) {
    return ElifbaPair(
      group: JsonMap.str(json['group']),
      details: JsonMap.str(json['details']),
    );
  }
}

class ElifbaVerse {
  const ElifbaVerse({required this.text, required this.focus});

  final String text;
  final List<String> focus;

  factory ElifbaVerse.fromJson(Map<String, dynamic> json) {
    final focusRaw = json['focus'];
    return ElifbaVerse(
      text: JsonMap.str(json['text']),
      focus: focusRaw is List
          ? JsonMap.strings(focusRaw)
          : [if (JsonMap.str(focusRaw).isNotEmpty) JsonMap.str(focusRaw)],
    );
  }
}

class ElifbaSurah {
  const ElifbaSurah({required this.name, required this.focus});

  final String name;
  final List<String> focus;

  factory ElifbaSurah.fromJson(Map<String, dynamic> json) {
    return ElifbaSurah(
      name: JsonMap.str(json['name']),
      focus: JsonMap.strings(json['focus']),
    );
  }
}

class ElifbaStepExample {
  const ElifbaStepExample({required this.text, required this.explanation});

  final String text;
  final String explanation;

  factory ElifbaStepExample.fromJson(Map<String, dynamic> json) {
    return ElifbaStepExample(
      text: JsonMap.str(json['text']),
      explanation: JsonMap.str(json['explanation']),
    );
  }
}

class ElifbaCompletion {
  const ElifbaCompletion({
    required this.passPercent,
    required this.success,
    required this.retry,
  });

  final int passPercent;
  final String success;
  final String retry;

  factory ElifbaCompletion.fromJson(Map<String, dynamic> json) {
    return ElifbaCompletion(
      passPercent: JsonMap.integer(json['suggested_pass_score_percent'], 70),
      success: JsonMap.str(json['message_success']),
      retry: JsonMap.str(json['message_retry']),
    );
  }
}
