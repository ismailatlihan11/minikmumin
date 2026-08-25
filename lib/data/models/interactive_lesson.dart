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

class WuduCompletionDua {
  const WuduCompletionDua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.audio = '',
    this.source = '',
  });

  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String audio;
  final String source;

  bool get hasAudio => audio.trim().isNotEmpty;

  factory WuduCompletionDua.fromJson(Map<String, dynamic> json) {
    return WuduCompletionDua(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
      audio: JsonMap.str(json['audio']),
      source: JsonMap.str(json['source']),
    );
  }
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
    this.completionDua,
  });

  final String id;
  final String title;
  final String sourceName;
  final bool verificationRequired;
  final List<LessonStep> steps;
  final List<Map<String, dynamic>> visualSteps;
  final List<Map<String, dynamic>> tips;
  final List<String> farzIds;
  final WuduCompletionDua? completionDua;

  factory WuduLesson.fromJson(Map<String, dynamic> json) {
    final duaJson = JsonMap.object(json['completionDua']);
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
      completionDua: duaJson.isEmpty ? null : WuduCompletionDua.fromJson(duaJson),
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
        if (completionDua != null)
          'completionDua': {
            'id': completionDua!.id,
            'title': completionDua!.title,
            'arabic': completionDua!.arabic,
            'transliteration': completionDua!.transliteration,
            'meaning': completionDua!.meaning,
            'audio': completionDua!.audio,
            'source': completionDua!.source,
          },
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
    this.teachingNote = '',
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
  final String teachingNote;

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
      teachingNote: JsonMap.str(json['teachingNote']),
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
        'teachingNote': teachingNote,
      };
}

typedef WuduStep = LessonStep;
typedef PrayerStep = LessonStep;

