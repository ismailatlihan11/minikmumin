import '../../core/utils/json_map.dart';

class LessonStep {
  const LessonStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    this.sourceReference = '',
    this.image = '',
    this.animation = '',
    this.audio = '',
    this.interactionType = '',
    this.correctArea = '',
    this.successMessage = '',
    this.retryMessage = '',
    this.duaId = '',
    this.xp = 0,
  });

  final String id;
  final int order;
  final String title;
  final String description;
  final String sourceReference;
  final String image;
  final String animation;
  final String audio;
  final String interactionType;
  final String correctArea;
  final String successMessage;
  final String retryMessage;
  final String duaId;
  final int xp;

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      id: JsonMap.str(json['id']),
      order: JsonMap.integer(json['order']),
      title: JsonMap.str(json['title']),
      description: JsonMap.str(json['description']),
      sourceReference: JsonMap.str(json['sourceReference']),
      image: JsonMap.str(json['image']),
      animation: JsonMap.str(json['animation']),
      audio: JsonMap.str(json['audio']),
      interactionType: JsonMap.str(json['interactionType']),
      correctArea: JsonMap.str(json['correctArea']),
      successMessage: JsonMap.str(json['successMessage']),
      retryMessage: JsonMap.str(json['retryMessage']),
      duaId: JsonMap.str(json['duaId']),
      xp: JsonMap.integer(json['xp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'title': title,
        'description': description,
        'sourceReference': sourceReference,
        'image': image,
        'animation': animation,
        'audio': audio,
        'interactionType': interactionType,
        'correctArea': correctArea,
        'successMessage': successMessage,
        'retryMessage': retryMessage,
        'duaId': duaId,
        'xp': xp,
      };
}

class WuduLesson {
  const WuduLesson({
    required this.id,
    required this.title,
    required this.sourceName,
    required this.verificationRequired,
    required this.steps,
    this.visualSteps = const [],
    this.tips = const [],
    this.farzIds = const [],
  });

  final String id;
  final String title;
  final String sourceName;
  final bool verificationRequired;
  final List<LessonStep> steps;
  final List<Map<String, dynamic>> visualSteps;
  final List<Map<String, dynamic>> tips;
  final List<String> farzIds;

  factory WuduLesson.fromJson(Map<String, dynamic> json) {
    return WuduLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      sourceName: JsonMap.str(json['sourceName']),
      verificationRequired: JsonMap.flag(json['verificationRequired']),
      steps: JsonMap.extractList(json, itemsKey: 'steps')
          .map(LessonStep.fromJson)
          .toList(growable: false),
      visualSteps: JsonMap.extractList(json, itemsKey: 'visualSteps'),
      tips: JsonMap.extractList(json, itemsKey: 'tips'),
      farzIds: JsonMap.strings(json['farzIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sourceName': sourceName,
        'verificationRequired': verificationRequired,
        'steps': steps.map((e) => e.toJson()).toList(),
        'visualSteps': visualSteps,
        'tips': tips,
        'farzIds': farzIds,
      };
}

class PrayerLesson {
  const PrayerLesson({
    required this.id,
    required this.title,
    required this.sourceName,
    required this.steps,
    this.visualSteps = const [],
    this.tips = const [],
    this.farzLabels = const [],
    this.farzIds = const [],
    this.duaList = const [],
    this.rakats = const [],
  });

  final String id;
  final String title;
  final String sourceName;
  final List<LessonStep> steps;
  final List<Map<String, dynamic>> visualSteps;
  final List<Map<String, dynamic>> tips;
  final List<String> farzLabels;
  final List<String> farzIds;
  final List<Map<String, dynamic>> duaList;
  final List<Map<String, dynamic>> rakats;

  factory PrayerLesson.fromJson(Map<String, dynamic> json) {
    return PrayerLesson(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      sourceName: JsonMap.str(json['sourceName']),
      steps: JsonMap.extractList(json, itemsKey: 'steps')
          .map(LessonStep.fromJson)
          .toList(growable: false),
      visualSteps: JsonMap.extractList(json, itemsKey: 'visualSteps'),
      tips: JsonMap.extractList(json, itemsKey: 'tips'),
      farzLabels: JsonMap.strings(json['farzLabels']),
      farzIds: JsonMap.strings(json['farzIds']),
      duaList: JsonMap.extractList(json, itemsKey: 'duaList'),
      rakats: JsonMap.extractList(json, itemsKey: 'rakats'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'sourceName': sourceName,
        'steps': steps.map((e) => e.toJson()).toList(),
        'visualSteps': visualSteps,
        'tips': tips,
        'farzLabels': farzLabels,
        'farzIds': farzIds,
        'duaList': duaList,
        'rakats': rakats,
      };
}

typedef WuduStep = LessonStep;
typedef PrayerStep = LessonStep;

