import '../../core/utils/json_map.dart';

class QuizOption {
  const QuizOption({
    required this.id,
    required this.text,
    required this.correct,
  });

  final String id;
  final String text;
  final bool correct;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: JsonMap.str(json['id']),
      text: JsonMap.str(json['text']),
      correct: JsonMap.flag(json['correct']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'correct': correct,
      };
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.xp,
    this.difficulty = '',
    this.type = '',
    this.explanation = '',
    this.source = '',
  });

  final String id;
  final String category;
  final String question;
  final List<QuizOption> options;
  final int xp;
  final String difficulty;
  final String type;
  final String explanation;
  final String source;

  QuizOption? get correctOption {
    for (final option in options) {
      if (option.correct) return option;
    }
    return null;
  }

  QuizQuestion shuffledOptions() {
    final copy = List<QuizOption>.from(options)..shuffle();
    return copyWith(options: copy);
  }

  QuizQuestion copyWith({List<QuizOption>? options}) {
    return QuizQuestion(
      id: id,
      category: category,
      question: question,
      options: options ?? this.options,
      xp: xp,
      difficulty: difficulty,
      type: type,
      explanation: explanation,
      source: source,
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final correctId = JsonMap.str(json['correctOption']);
    var options = JsonMap.extractList(json['options'], itemsKey: 'options')
        .map(QuizOption.fromJson)
        .toList();
    if (correctId.isNotEmpty && options.every((option) => !option.correct)) {
      options = options
          .map(
            (option) => QuizOption(
              id: option.id,
              text: option.text,
              correct: option.id == correctId,
            ),
          )
          .toList(growable: false);
    }
    return QuizQuestion(
      id: JsonMap.str(json['id']),
      category: JsonMap.str(json['category']),
      question: JsonMap.str(json['question']),
      options: options,
      xp: JsonMap.integer(json['xp']),
      difficulty: JsonMap.str(json['difficulty']),
      type: JsonMap.str(json['type']),
      explanation: JsonMap.str(json['explanation']),
      source: JsonMap.str(json['source']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'options': options.map((e) => e.toJson()).toList(),
        'xp': xp,
        'difficulty': difficulty,
        'type': type,
        'explanation': explanation,
        'source': source,
      };
}

class QuizBank {
  const QuizBank({
    required this.title,
    required this.categories,
    required this.questions,
    required this.questionsPerSession,
    required this.correctFeedback,
    required this.wrongFeedback,
  });

  final String title;
  final List<String> categories;
  final List<QuizQuestion> questions;
  final int questionsPerSession;
  final List<String> correctFeedback;
  final List<String> wrongFeedback;

  List<QuizQuestion> forCategory(String category) {
    return questions.where((question) => question.category == category).toList(growable: false);
  }
}
