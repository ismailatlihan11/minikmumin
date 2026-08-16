import '../../core/utils/json_map.dart';

class MoralityCategory {
  const MoralityCategory({
    required this.id,
    required this.title,
    this.order = 0,
  });

  final String id;
  final String title;
  final int order;

  factory MoralityCategory.fromJson(Map<String, dynamic> json, {int order = 0}) {
    return MoralityCategory(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      order: JsonMap.integer(json['order'], order),
    );
  }
}

class MoralityLesson {
  const MoralityLesson({
    required this.id,
    required this.title,
    required this.lesson,
    required this.source,
    this.order = 0,
    this.category = '',
    this.shortMessage = '',
    this.childExplanation = '',
    this.dailyChallenge = '',
    this.quranReferences = const [],
    this.hadithReference = '',
    this.image = '',
    this.audio = '',
  });

  final String id;
  final String title;
  final String lesson;
  final String source;
  final int order;
  final String category;
  final String shortMessage;
  final String childExplanation;
  final String dailyChallenge;
  final List<String> quranReferences;
  final String hadithReference;
  final String image;
  final String audio;

  factory MoralityLesson.fromJson(Map<String, dynamic> json) {
    final explanation = JsonMap.str(json['childExplanation']);
    final shortMessage = JsonMap.str(json['shortMessage']);
    final lesson = JsonMap.str(json['lesson']);
    final quranReferences = JsonMap.strings(json['quranReferences']);
    final hadithReference = JsonMap.str(json['hadithReference']);
    final source = JsonMap.str(json['source']);
    final sourceParts = [
      ...quranReferences,
      if (hadithReference.isNotEmpty) hadithReference,
    ];
    return MoralityLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      lesson: lesson.isNotEmpty
          ? lesson
          : (explanation.isNotEmpty ? explanation : shortMessage),
      source: source.isNotEmpty ? source : sourceParts.join(' • '),
      order: JsonMap.integer(json['order']),
      category: JsonMap.str(json['category']),
      shortMessage: shortMessage,
      childExplanation: explanation,
      dailyChallenge: JsonMap.str(json['dailyChallenge']),
      quranReferences: quranReferences,
      hadithReference: hadithReference,
      image: JsonMap.str(json['image']),
      audio: JsonMap.str(json['audio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lesson': lesson,
        'source': source,
        'order': order,
        'category': category,
        'shortMessage': shortMessage,
        'childExplanation': childExplanation,
        'dailyChallenge': dailyChallenge,
        'quranReferences': quranReferences,
        'hadithReference': hadithReference,
        'image': image,
        'audio': audio,
      };
}

class IlmihalCategory {
  const IlmihalCategory({
    required this.id,
    required this.title,
    required this.order,
    this.icon = '',
  });

  final String id;
  final String title;
  final int order;
  final String icon;

  factory IlmihalCategory.fromJson(Map<String, dynamic> json) {
    return IlmihalCategory(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      order: JsonMap.integer(json['order']),
      icon: JsonMap.str(json['icon']),
    );
  }
}

class IlmihalLesson {
  const IlmihalLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourceReference,
    this.order = 0,
    this.category = '',
    this.keyPoints = const [],
    this.activity = '',
    this.memorization = '',
    this.linkedModule = '',
    this.adultGuidance = '',
    this.parentGuidance = '',
    this.quranReference = '',
  });

  final String id;
  final String title;
  final String summary;
  final String sourceReference;
  final int order;
  final String category;
  final List<String> keyPoints;
  final String activity;
  final String memorization;
  final String linkedModule;
  final String adultGuidance;
  final String parentGuidance;
  final String quranReference;

  factory IlmihalLesson.fromJson(Map<String, dynamic> json) {
    final source = JsonMap.str(json['source']);
    final sourceReference = JsonMap.str(json['sourceReference']);
    return IlmihalLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      summary: JsonMap.str(json['summary']),
      sourceReference: sourceReference.isNotEmpty ? sourceReference : source,
      order: JsonMap.integer(json['order']),
      category: JsonMap.str(json['category']),
      keyPoints: JsonMap.strings(json['keyPoints']),
      activity: JsonMap.str(json['activity']),
      memorization: JsonMap.str(json['memorization']),
      linkedModule: JsonMap.str(json['linkedModule']),
      adultGuidance: JsonMap.str(json['adultGuidance']),
      parentGuidance: JsonMap.str(json['parentGuidance']),
      quranReference: JsonMap.str(json['quranReference']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'sourceReference': sourceReference,
        'order': order,
        'category': category,
        'keyPoints': keyPoints,
        'activity': activity,
        'memorization': memorization,
        'linkedModule': linkedModule,
        'adultGuidance': adultGuidance,
        'parentGuidance': parentGuidance,
        'quranReference': quranReference,
      };
}
