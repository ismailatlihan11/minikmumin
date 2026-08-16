import '../../core/utils/json_map.dart';

class MoralityLesson {
  const MoralityLesson({
    required this.id,
    required this.title,
    required this.lesson,
    required this.source,
  });

  final String id;
  final String title;
  final String lesson;
  final String source;

  factory MoralityLesson.fromJson(Map<String, dynamic> json) {
    return MoralityLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      lesson: JsonMap.str(json['lesson']),
      source: JsonMap.str(json['source']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lesson': lesson,
        'source': source,
      };
}

class IlmihalLesson {
  const IlmihalLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourceReference,
  });

  final String id;
  final String title;
  final String summary;
  final String sourceReference;

  factory IlmihalLesson.fromJson(Map<String, dynamic> json) {
    return IlmihalLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      summary: JsonMap.str(json['summary']),
      sourceReference: JsonMap.str(json['sourceReference']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'sourceReference': sourceReference,
      };
}
