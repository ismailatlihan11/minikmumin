import '../../core/utils/json_map.dart';
import 'elifba_reading.dart';

/// Hareke, şedde, cezm ve uzatma işaretlerini ayıklar.
String elifbaStripMarks(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final isMark = (rune >= 0x064B && rune <= 0x0652) ||
        rune == 0x0670 ||
        rune == 0x0640;
    if (!isMark) buffer.writeCharCode(rune);
  }
  return buffer.toString().trim();
}

/// JSON'da cevap bazen harekesiz (ص), şıklar harekeli (صَ) yazılmış.
/// Doğru şıkkı işaretlerden bağımsız eşleştirir; eşleşme yoksa cevabı korur.
String elifbaResolveAnswer(List<String> options, String answer) {
  if (options.contains(answer)) return answer;
  final target = elifbaStripMarks(answer);
  if (target.isEmpty) return answer;
  for (final option in options) {
    if (elifbaStripMarks(option) == target) return option;
  }
  final partial = [
    for (final option in options)
      if (elifbaStripMarks(option).contains(target)) option,
  ];
  return partial.length == 1 ? partial.first : answer;
}

class ElifbaPack {
  const ElifbaPack({
    required this.title,
    required this.description,
    required this.lessons,
    this.hidden = const [],
  });

  final String title;
  final String description;
  final List<ElifbaLesson> lessons;

  /// Haritadan çıkarılan ama tabloları hâlâ kaynak olan dersler. JSON'da
  /// bazı tablolar yanlış derse bağlı olduğu için içerik burada korunur.
  final List<ElifbaLesson> hidden;

  List<ElifbaLesson> get contentLessons => [...lessons, ...hidden];

  ElifbaLesson? byId(int id) {
    for (final lesson in contentLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  /// Kaydedilmiş ilerleme haritadan çıkarılmış bir dersi gösterebilir;
  /// bu durumda macera ilk dersten devam eder.
  ElifbaLesson resumeFrom(int id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return lessons.first;
  }

  /// Ders id'leri JSON'dan gelir ve araya ders eklenince artık ardışık
  /// olmayabilir; sıra, ekranda gösterilen numara ve kilit için kullanılır.
  int orderOf(int id) => lessons.indexWhere((lesson) => lesson.id == id) + 1;

  ElifbaLesson? previousOf(int id) {
    final index = lessons.indexWhere((lesson) => lesson.id == id);
    return index > 0 ? lessons[index - 1] : null;
  }

  ElifbaLesson? nextOf(int id) {
    final index = lessons.indexWhere((lesson) => lesson.id == id);
    if (index < 0 || index >= lessons.length - 1) return null;
    return lessons[index + 1];
  }

  /// Şedde asla tek başına öğretilmez; harekesiz şeddeli tablolar gizlenir.
  static bool isStandaloneShaddaTable(List<ElifbaLetterRow> table) {
    if (table.isEmpty) return false;
    final marked = table.first.marked;
    if (!marked.contains('ّ')) return false;
    return !marked.contains('َ') &&
        !marked.contains('ِ') &&
        !marked.contains('ُ');
  }

  /// Prefer the 28-letter table whose marked forms match a haraka/cezm.
  ///
  /// Kaynak JSON'da bu tablolar bir ders erken bağlanmış durumda
  /// (fetha tablosu "harf şekilleri" dersinde vb.), bu yüzden tablo
  /// ders sırasına göre değil, işaretin kendisine göre eşleştirilir.
  List<ElifbaLetterRow> tableMatchingMark(String mark) {
    if (mark.isEmpty) return const [];
    List<ElifbaLetterRow> best = const [];
    var bestScore = 0;
    for (final lesson in contentLessons) {
      final table = lesson.letterTable;
      if (table.length < 20) continue;
      if (isStandaloneShaddaTable(table)) continue;
      final score = table.where((row) => row.marked.contains(mark)).length;
      if (score > bestScore) {
        bestScore = score;
        best = table;
      }
    }
    return bestScore >= 20 ? best : const [];
  }

  List<ElifbaLetterRow> teachingTableFor(ElifbaLesson lesson) {
    // Şedde dersi kendi harake_tables bölümlerini kullanır.
    if (lesson.harakeTables.isNotEmpty) return const [];
    final mark = lesson.rule?.symbol ?? '';
    final matched = tableMatchingMark(mark);
    if (matched.isNotEmpty) return matched;
    final byCategory = categoryTableFor(lesson);
    if (byCategory.isNotEmpty) return byCategory;
    final own = lesson.letterTable;
    if (isStandaloneShaddaTable(own)) return const [];
    // Üçlü hareke sütunlu tablolar ayrı bir bileşenle gösterilir.
    if (own.isNotEmpty && own.first.hasTriple) return const [];
    // Başka bir dersin konusu olan işaretin tablosunu burada gösterme.
    final ownMark = own.isEmpty ? '' : _markOf(own.first.marked);
    if (ownMark.isNotEmpty && _lessonTeaching(ownMark)?.id != lesson.id) {
      return const [];
    }
    if (_tableFitsLesson(lesson, own)) {
      return own;
    }
    for (final other in contentLessons) {
      final table = other.letterTable;
      if (table.isEmpty) continue;
      if (table.first.marked.isNotEmpty) continue;
      if (_tableFitsLesson(lesson, table)) return table;
    }
    return const [];
  }

  /// İzhâr/İdğam/İhfâ harf tabloları da bir ders erken bağlanmış durumda;
  /// tablo, satırlarındaki kategori etiketiyle doğru derse yönlendirilir.
  List<ElifbaLetterRow> categoryTableFor(ElifbaLesson lesson) {
    final title = _fold(lesson.title);
    if (title.isEmpty) return const [];
    for (final other in contentLessons) {
      final table = other.letterTable;
      if (table.isEmpty) continue;
      final category = _fold(table.first.category);
      if (category.isEmpty) continue;
      final keyword = category.split(' ').first;
      if (keyword.length > 2 && title.contains(keyword)) return table;
    }
    return const [];
  }

  /// Med tablosu JSON'da tenvin dersine iliştirilmiş; med dersine taşınır.
  List<ElifbaMedRow> medTableFor(ElifbaLesson lesson) {
    if (!_teachesMed(lesson)) return const [];
    if (lesson.medTable.isNotEmpty) return lesson.medTable;
    for (final other in contentLessons) {
      if (other.medTable.isNotEmpty) return other.medTable;
    }
    return const [];
  }

  bool _teachesMed(ElifbaLesson lesson) =>
      lesson.medLetters.isNotEmpty || _fold(lesson.title).contains('med');

  /// Kural ağacı, nun sâkin/tenvin giriş dersine aittir.
  List<String> decisionTreeFor(ElifbaLesson lesson) {
    if (!_teachesNunSakin(lesson)) return const [];
    if (lesson.decisionTree.isNotEmpty) return lesson.decisionTree;
    for (final other in contentLessons) {
      if (other.decisionTree.isNotEmpty) return other.decisionTree;
    }
    return const [];
  }

  bool _teachesNunSakin(ElifbaLesson lesson) =>
      lesson.rulesSummary.isNotEmpty ||
      _fold(lesson.title).contains('nun sakin');

  /// Bu işareti asıl konu olarak işleyen ders (rule.symbol üzerinden).
  ElifbaLesson? _lessonTeaching(String mark) {
    for (final lesson in contentLessons) {
      if ((lesson.rule?.symbol ?? '') == mark) return lesson;
    }
    return null;
  }

  static String _markOf(String marked) {
    for (final mark in const ['ّ', 'ْ', 'ُ', 'ِ', 'َ']) {
      if (marked.contains(mark)) return mark;
    }
    return '';
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
    for (final lesson in contentLessons) {
      final table = lesson.letterTable;
      if (table.length < 20) continue;
      if (isStandaloneShaddaTable(table)) continue;
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

  factory ElifbaPack.fromJson(
    Map<String, dynamic> json, {
    List<ElifbaExtraLesson> extras = const [],
    Set<String> hiddenTitles = const {},
  }) {
    final lessons = JsonMap.extractList(json, itemsKey: 'lessons')
        .map(ElifbaLesson.fromJson)
        .toList();
    final folded = hiddenTitles.map(_fold).toSet();
    final hidden = [
      for (final lesson in lessons)
        if (folded.contains(_fold(lesson.title))) lesson,
    ];
    lessons.removeWhere(hidden.contains);
    for (final extra in extras) {
      if (lessons.any((lesson) => lesson.id == extra.lesson.id)) continue;
      final anchor =
          lessons.indexWhere((lesson) => lesson.id == extra.afterLessonId);
      lessons.insert(anchor < 0 ? lessons.length : anchor + 1, extra.lesson);
    }
    return ElifbaPack(
      title: JsonMap.str(json['title'], "Elifbâ + Tecvid Macerası"),
      description: JsonMap.str(
        json['description'],
        "Kur'an okumayı eğlenerek öğren!",
      ),
      lessons: List.unmodifiable(lessons),
      hidden: List.unmodifiable(hidden),
    );
  }
}

/// Macera JSON'una dışarıdan eklenen ders (ör. Kur'an serisinden alınan
/// "Harfler ve Şekilleri"). Ders, verilen id'nin hemen ardına yerleşir.
class ElifbaExtraLesson {
  ElifbaExtraLesson({
    required this.afterLessonId,
    required Map<String, dynamic> json,
  }) : lesson = ElifbaLesson.fromJson(json);

  final int afterLessonId;
  final ElifbaLesson lesson;
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

  /// Rows that carry fetha/esre/ötre columns at once (kalın, ince, peltek dersleri).
  List<ElifbaLetterRow> get tripleFormTable =>
      [for (final row in letterTable) if (row.hasTriple) row];

  /// Şedde dersi: hareke ile birlikte üç ayrı tablo.
  Map<String, List<ElifbaLetterRow>> get harakeTables {
    final value = raw['harake_tables'];
    if (value is! Map) return const {};
    return {
      for (final entry in JsonMap.object(value).entries)
        if (entry.value is List)
          entry.key: (entry.value as List)
              .map((item) => ElifbaLetterRow.fromJson(JsonMap.object(item)))
              .toList(growable: false),
    };
  }

  List<ElifbaWordExample> get wordExamples => _maps('word_examples')
      .map(ElifbaWordExample.fromJson)
      .where((item) => item.text.isNotEmpty)
      .toList(growable: false);

  List<ElifbaExample> get coreExamples =>
      _maps('core_examples').map(ElifbaExample.fromJson).toList(growable: false);

  /// comparison_pairs ve comparison_game aynı soru-cevap kalıbını paylaşır.
  List<ElifbaAskPair> get askPairs => [
        ..._maps('comparison_pairs').map(ElifbaAskPair.fromJson),
        ..._maps('comparison_game').map(ElifbaAskPair.fromJson),
      ].where((item) => item.question.isNotEmpty).toList(growable: false);

  List<ElifbaExample> get specialPreview => _maps('special_preview')
      .map(
        (item) => ElifbaExample(
          text: JsonMap.str(item['form']),
          reading: JsonMap.str(item['reading']),
          note: JsonMap.str(item['note']),
        ),
      )
      .toList(growable: false);

  List<ElifbaRaRow> get raTable =>
      _maps('ra_table').map(ElifbaRaRow.fromJson).toList(growable: false);

  List<ElifbaGroup> get reviewGroups =>
      _maps('review_groups').map(ElifbaGroup.fromJson).toList(growable: false);

  List<ElifbaFormRow> get letterForms =>
      _maps('letter_forms').map(ElifbaFormRow.fromJson).toList(growable: false);

  List<ElifbaActivity> get interactiveActivities => _maps('interactive_activities')
      .map(ElifbaActivity.fromJson)
      .where((item) => item.title.isNotEmpty)
      .toList(growable: false);

  int get passPercent {
    final mastery = JsonMap.object(raw['mastery']);
    final value = JsonMap.integer(mastery['quiz_pass_percent'], 70);
    return value <= 0 ? 70 : value;
  }

  String get tableTitle => JsonMap.str(raw['table_title']);

  String get tableInstruction => JsonMap.str(raw['table_instruction']);

  String get wordSectionTitle => JsonMap.str(raw['word_section_title']);

  String get wordSectionInstruction =>
      JsonMap.str(raw['word_section_instruction']);

  String get classificationNote => JsonMap.str(raw['classification_note']);

  String get manyExampleRule => JsonMap.str(raw['many_example_rule']);

  String get pronunciationTip => JsonMap.str(raw['pronunciation_tip']);

  List<String> get practiceRule => JsonMap.strings(raw['practice_rule']);

  /// Bazı derslerde `rule` düz metindir (kalın/ince/peltek dersleri).
  String get ruleText => raw['rule'] is String ? JsonMap.str(raw['rule']) : '';

  String get importantNote => JsonMap.str(raw['important_note']);

  List<String> get decisionTree => JsonMap.strings(raw['decision_tree']);

  ElifbaUiPattern get uiPattern =>
      ElifbaUiPattern.fromJson(JsonMap.object(raw['ui_learning_pattern']));

  ElifbaRich get rich =>
      ElifbaRich.fromJson(JsonMap.object(raw['rich_content']));

  List<ElifbaSpecialLetter> get specialLetters => _maps('special_letters')
      .map(ElifbaSpecialLetter.fromJson)
      .where((item) => item.letter.isNotEmpty)
      .toList(growable: false);

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
      goal: ElifbaReading.fixSoundText(JsonMap.str(json['goal'])),
      explanation:
          ElifbaReading.fixSoundText(JsonMap.str(json['explanation'])),
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
    final question = JsonMap.str(json['question']);
    var options = JsonMap.strings(json['options']);
    var answer = elifbaResolveAnswer(options, JsonMap.str(json['answer']));
    // "بَ nasıl okunur?" tipi sorularda şıklar kalın/ince kuralına göre
    // yeniden üretilir; doğru cevap sorudaki harekeden gelir.
    final asked = _askedSyllables(question);
    if (asked.isNotEmpty) {
      final fixed = [
        for (final option in options) _retuneOption(option, asked),
      ];
      if (fixed.toSet().length == options.length) {
        final correct = asked
            .map((syllable) => ElifbaReading.of(
                  ElifbaReading.letterOf(syllable),
                  ElifbaReading.markOf(syllable),
                  withTag: false,
                ))
            .join('-');
        if (fixed.contains(correct)) {
          options = fixed;
          answer = correct;
        }
      }
    }
    return ElifbaQuizItem(
      id: JsonMap.integer(json['id']),
      question: question,
      options: options,
      answer: answer,
    );
  }

  /// Şıktaki her heceyi, kendi ünlüsünün işaret ettiği harekeye göre üretir.
  static String _retuneOption(String option, List<String> asked) {
    final parts = option.split('-');
    if (parts.length != asked.length) return option;
    return [
      for (var i = 0; i < parts.length; i++)
        ElifbaReading.forOption(ElifbaReading.letterOf(asked[i]), parts[i]),
    ].join('-');
  }

  /// Soru metnindeki harf + hareke parçaları (ör. "بَ", "بَ + تَ").
  static List<String> _askedSyllables(String question) {
    if (!question.toLowerCase().contains('okunur')) return const [];
    final clusters = <String>[];
    final buffer = StringBuffer();
    for (final rune in question.runes) {
      if (rune >= 0x0600 && rune <= 0x06FF) {
        buffer.writeCharCode(rune);
      } else if (buffer.isNotEmpty) {
        clusters.add(buffer.toString());
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) clusters.add(buffer.toString());
    if (clusters.isEmpty) return const [];
    // Uzatmalı ya da cezmli parçalar üretecin dışındadır.
    if (!clusters.every(ElifbaReading.isShortSyllable)) return const [];
    return clusters;
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
    final symbol = JsonMap.str(json['symbol']);
    // Hareke kartında tek ses yazılıydı ("a"); iki sesi birden gösteriyoruz.
    final described = ElifbaReading.describeMark(symbol);
    return ElifbaRule(
      symbol: symbol,
      name: JsonMap.str(json['name']),
      sound: described.isNotEmpty ? described : JsonMap.str(json['sound']),
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
    this.vowel = '',
    this.fatha = '',
    this.kasra = '',
    this.damma = '',
    this.fathaReading = '',
    this.kasraReading = '',
    this.dammaReading = '',
    this.compare = '',
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
  final String vowel;
  final String fatha;
  final String kasra;
  final String damma;
  final String fathaReading;
  final String kasraReading;
  final String dammaReading;
  final String compare;

  bool get hasTriple =>
      fatha.isNotEmpty || kasra.isNotEmpty || damma.isNotEmpty;

  String get markedCaption {
    if (marked.contains('ّ')) {
      final label = vowel.isNotEmpty
          ? vowel
          : marked.contains('َ')
              ? 'Üstün'
              : marked.contains('ِ')
                  ? 'Esre'
                  : marked.contains('ُ')
                      ? 'Ötre'
                      : '';
      return label.isEmpty ? 'Şeddeli hali' : 'Şedde + $label';
    }
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
    final letter = JsonMap.str(json['letter']);
    final marked = JsonMap.str(json['marked']);
    return ElifbaLetterRow(
      letter: letter,
      name: JsonMap.str(json['name']),
      marked: marked,
      reading: ElifbaReading.forMarked(marked, JsonMap.str(json['reading'])),
      note: JsonMap.str(json['note']),
      category: JsonMap.str(json['category']),
      type: JsonMap.str(json['type']),
      memory: JsonMap.str(json['memory']),
      example: JsonMap.str(json['example']),
      audioLetter: JsonMap.str(json['audio_letter']),
      audioExample: JsonMap.str(
        json['audio_example'] ?? json['audio'] ?? json['audio_word'],
      ),
      vowel: JsonMap.str(json['vowel']),
      fatha: JsonMap.str(json['fatha']),
      kasra: JsonMap.str(json['kasra']),
      damma: JsonMap.str(json['damma']),
      fathaReading: ElifbaReading.forMarked(
        '$letter${ElifbaReading.fatha}',
        JsonMap.str(json['fatha_reading'] ?? json['reading_fatha']),
      ),
      kasraReading: ElifbaReading.forMarked(
        '$letter${ElifbaReading.kasra}',
        JsonMap.str(json['kasra_reading'] ?? json['reading_kasra']),
      ),
      dammaReading: ElifbaReading.forMarked(
        '$letter${ElifbaReading.damma}',
        JsonMap.str(json['damma_reading'] ?? json['reading_damma']),
      ),
      compare: JsonMap.str(json['compare']),
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
      objective:
          ElifbaReading.fixSoundText(JsonMap.str(json['lesson_objective'])),
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
  const ElifbaGroup({
    required this.name,
    required this.letters,
    this.note = '',
  });

  final String name;
  final List<String> letters;
  final String note;

  factory ElifbaGroup.fromJson(Map<String, dynamic> json) {
    return ElifbaGroup(
      name: JsonMap.str(json['name'] ?? json['group']),
      letters: JsonMap.strings(json['letters']),
      note: JsonMap.str(json['note']),
    );
  }
}

/// Kelime kartı verisi: Arapça + okunuş + anlam + dikkat edilecek kural.
class ElifbaWordExample {
  const ElifbaWordExample({
    required this.text,
    this.reading = '',
    this.meaning = '',
    this.focus = '',
    this.audio = '',
  });

  final String text;
  final String reading;
  final String meaning;
  final String focus;
  final String audio;

  factory ElifbaWordExample.fromJson(Map<String, dynamic> json) {
    return ElifbaWordExample(
      text: JsonMap.str(json['word'] ?? json['text']),
      reading: JsonMap.str(json['reading']),
      meaning: JsonMap.str(json['meaning']),
      focus: JsonMap.str(json['focus'] ?? json['rule'] ?? json['note']),
      audio: JsonMap.str(json['audio_word'] ?? json['audio']),
    );
  }
}

/// İki seçenekli karşılaştırma sorusu (comparison_pairs / comparison_game).
class ElifbaAskPair {
  const ElifbaAskPair({
    required this.question,
    required this.answer,
    required this.options,
    this.label = '',
  });

  final String question;
  final String answer;
  final List<String> options;
  final String label;

  factory ElifbaAskPair.fromJson(Map<String, dynamic> json) {
    final left = JsonMap.str(json['left']);
    final right = JsonMap.str(json['right']);
    final answers = JsonMap.strings(json['answers']);
    final options = answers.isNotEmpty
        ? answers
        : [
            if (left.isNotEmpty) left,
            if (right.isNotEmpty) right,
          ];
    return ElifbaAskPair(
      question: JsonMap.str(json['question']),
      answer: elifbaResolveAnswer(
        options,
        JsonMap.str(json['answer'] ?? json['correct']),
      ),
      options: options,
      label: JsonMap.str(json['pair']),
    );
  }
}

/// Ra gibi duruma göre kalın/ince okunan harfler.
class ElifbaSpecialLetter {
  const ElifbaSpecialLetter({
    required this.letter,
    required this.name,
    this.classification = '',
    this.thickWhen = const [],
    this.thinWhen = const [],
    this.note = '',
  });

  final String letter;
  final String name;
  final String classification;
  final List<String> thickWhen;
  final List<String> thinWhen;
  final String note;

  factory ElifbaSpecialLetter.fromJson(Map<String, dynamic> json) {
    return ElifbaSpecialLetter(
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      classification: JsonMap.str(json['classification']),
      thickWhen: JsonMap.strings(json['thick_when']),
      thinWhen: JsonMap.strings(json['thin_when']),
      note: JsonMap.str(json['note']),
    );
  }
}

class ElifbaRaRow {
  const ElifbaRaRow({
    required this.form,
    required this.name,
    required this.reading,
    this.reason = '',
  });

  final String form;
  final String name;
  final String reading;
  final String reason;

  bool get isThick => reading.contains('kalın');

  factory ElifbaRaRow.fromJson(Map<String, dynamic> json) {
    return ElifbaRaRow(
      form: JsonMap.str(json['form']),
      name: JsonMap.str(json['name']),
      reading: JsonMap.str(json['reading']),
      reason: JsonMap.str(json['reason']),
    );
  }
}

/// Harfin kelimedeki dört şekli (Kur'an serisindeki letter_forms verisi).
class ElifbaFormRow {
  const ElifbaFormRow({
    required this.letter,
    required this.name,
    required this.sound,
    required this.isolated,
    required this.initial,
    required this.medial,
    required this.finalForm,
    required this.connects,
    required this.audio,
  });

  final String letter;
  final String name;
  final String sound;
  final String isolated;
  final String initial;
  final String medial;
  final String finalForm;
  final bool connects;
  final String audio;

  factory ElifbaFormRow.fromJson(Map<String, dynamic> json) {
    return ElifbaFormRow(
      letter: JsonMap.str(json['letter']),
      name: JsonMap.str(json['name']),
      sound: JsonMap.str(json['sound']),
      isolated: JsonMap.str(json['isolated']),
      initial: JsonMap.str(json['initial']),
      medial: JsonMap.str(json['medial']),
      finalForm: JsonMap.str(json['final']),
      connects: json['connects'] == true,
      audio: JsonMap.str(json['audio']),
    );
  }
}

class ElifbaActivity {
  const ElifbaActivity({
    required this.type,
    required this.title,
    this.count = 0,
  });

  final String type;
  final String title;
  final int count;

  String get emoji {
    switch (type) {
      case 'listen_repeat':
        return '🔊';
      case 'read_aloud':
        return '🗣';
      case 'multiple_choice':
        return '🎯';
      case 'find_rule':
        return '🔍';
      default:
        return '⭐';
    }
  }

  factory ElifbaActivity.fromJson(Map<String, dynamic> json) {
    return ElifbaActivity(
      type: JsonMap.str(json['type']),
      title: JsonMap.str(json['title']),
      count: JsonMap.integer(json['count']),
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
