import '../../core/utils/json_map.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.conditionType,
    required this.conditionValue,
  });

  final String id;
  final String title;
  final String conditionType;
  final int conditionValue;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final condition = JsonMap.object(json['condition']);
    return Achievement(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      conditionType: JsonMap.str(condition['type']),
      conditionValue: JsonMap.integer(condition['value']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'condition': {
          'type': conditionType,
          'value': conditionValue,
        },
      };
}

class UserProgress {
  const UserProgress({
    this.nickname = '',
    this.ageGroup = '',
    this.xp = 0,
    this.onboardingDone = false,
    this.completedLessons = const [],
    this.learnedDuas = const [],
    this.badges = const [],
  });

  final String nickname;
  final String ageGroup;
  final int xp;
  final bool onboardingDone;
  final List<String> completedLessons;
  final List<String> learnedDuas;
  final List<String> badges;

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'ageGroup': ageGroup,
        'xp': xp,
        'onboardingDone': onboardingDone,
        'completedLessons': completedLessons,
        'learnedDuas': learnedDuas,
        'badges': badges,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic value) => value is List
        ? value.map((e) => e.toString()).toList(growable: false)
        : const [];
    return UserProgress(
      nickname: JsonMap.str(json['nickname']),
      ageGroup: JsonMap.str(json['ageGroup']),
      xp: JsonMap.integer(json['xp']),
      onboardingDone: JsonMap.flag(json['onboardingDone']),
      completedLessons: strings(json['completedLessons']),
      learnedDuas: strings(json['learnedDuas']),
      badges: strings(json['badges']),
    );
  }
}

class AyetulKursi {
  const AyetulKursi({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.sourceName,
    required this.sourceReference,
  });

  final String id;
  final int surah;
  final int ayah;
  final String title;
  final String arabic;
  final String meaning;
  final String sourceName;
  final String sourceReference;

  factory AyetulKursi.fromJson(Map<String, dynamic> json) {
    return AyetulKursi(
      id: JsonMap.str(json['id']),
      surah: JsonMap.integer(json['surah']),
      ayah: JsonMap.integer(json['ayah']),
      title: JsonMap.str(json['title']),
      arabic: JsonMap.str(json['arabic']),
      meaning: JsonMap.str(json['meaning']),
      sourceName: JsonMap.str(json['sourceName']),
      sourceReference: JsonMap.str(json['sourceReference']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'surah': surah,
        'ayah': ayah,
        'title': title,
        'arabic': arabic,
        'meaning': meaning,
        'sourceName': sourceName,
        'sourceReference': sourceReference,
      };
}
