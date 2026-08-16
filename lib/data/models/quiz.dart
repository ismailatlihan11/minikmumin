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
  });

  final String id;
  final String category;
  final String question;
  final List<QuizOption> options;
  final int xp;

  QuizOption? get correctOption {
    for (final option in options) {
      if (option.correct) return option;
    }
    return null;
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: JsonMap.str(json['id']),
      category: JsonMap.str(json['category']),
      question: JsonMap.str(json['question']),
      options: JsonMap.extractList(json['options'], itemsKey: 'options')
          .map(QuizOption.fromJson)
          .toList(growable: false),
      xp: JsonMap.integer(json['xp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'options': options.map((e) => e.toJson()).toList(),
        'xp': xp,
      };
}
