import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../app/constants/asset_paths.dart';
import '../../../core/utils/json_map.dart';

/// Shared, prayer-independent description of a single action ("Rükû",
/// "Sübhaneke" …). Prayers only reference these by id.
class PrayerLessonStep {
  const PrayerLessonStep({
    required this.id,
    required this.title,
    required this.emoji,
    required this.visual,
    required this.kind,
    required this.say,
    required this.how,
    this.duaIds = const [],
    this.caption = '',
  });

  final String id;
  final String title;
  final String emoji;

  /// Id of a [PrayerVisualStep] whose images/motion frames are reused.
  final String visual;

  /// sart | farz | vacip | sunnet
  final String kind;
  final String say;
  final String how;
  final List<String> duaIds;
  final String caption;

  bool get isSure => id == 'sure';

  factory PrayerLessonStep.fromJson(String id, Map<String, dynamic> json) {
    return PrayerLessonStep(
      id: id,
      title: JsonMap.str(json['title']),
      emoji: JsonMap.str(json['emoji']),
      visual: JsonMap.str(json['visual']),
      kind: JsonMap.str(json['kind'], 'sunnet'),
      say: JsonMap.str(json['say']),
      how: JsonMap.str(json['how']),
      duaIds: JsonMap.strings(json['duaIds']),
      caption: JsonMap.str(json['caption']),
    );
  }

  String get kindLabel {
    switch (kind) {
      case 'sart':
        return 'Şart';
      case 'farz':
        return 'Farz';
      case 'vacip':
        return 'Vacip';
      default:
        return 'Sünnet';
    }
  }
}

class PrayerStepTip {
  const PrayerStepTip({required this.step, required this.text});

  final String step;
  final String text;

  factory PrayerStepTip.fromJson(Map<String, dynamic> json) => PrayerStepTip(
        step: JsonMap.str(json['step']),
        text: JsonMap.str(json['text']),
      );
}

class PrayerStepWhy {
  const PrayerStepWhy({
    required this.step,
    required this.question,
    required this.answer,
  });

  final String step;
  final String question;
  final String answer;

  factory PrayerStepWhy.fromJson(Map<String, dynamic> json) => PrayerStepWhy(
        step: JsonMap.str(json['step']),
        question: JsonMap.str(json['question']),
        answer: JsonMap.str(json['answer']),
      );
}

class PrayerRakah {
  const PrayerRakah({
    required this.number,
    required this.steps,
    this.surah,
    this.banner = const [],
    this.tips = const [],
    this.whys = const [],
  });

  final int number;
  final List<String> steps;

  /// Surah read as zamm-ı sûre in this rakah, if any.
  final int? surah;
  final List<String> banner;
  final List<PrayerStepTip> tips;
  final List<PrayerStepWhy> whys;

  factory PrayerRakah.fromJson(Map<String, dynamic> json) {
    final surah = JsonMap.integer(json['surah']);
    return PrayerRakah(
      number: JsonMap.integer(json['rakah']),
      steps: JsonMap.strings(json['steps']),
      surah: surah > 0 ? surah : null,
      banner: JsonMap.strings(json['banner']),
      tips: [
        for (final row in JsonMap.extractList(json['tips']))
          PrayerStepTip.fromJson(row),
      ],
      whys: [
        for (final row in JsonMap.extractList(json['whys']))
          PrayerStepWhy.fromJson(row),
      ],
    );
  }
}

class PrayerPlan {
  const PrayerPlan({
    required this.id,
    required this.group,
    required this.name,
    required this.shortName,
    required this.part,
    required this.type,
    required this.typeLabel,
    required this.notice,
    required this.rakats,
    required this.madhhab,
    required this.niyet,
    required this.intro,
    required this.info,
    required this.rakahs,
  });

  final String id;
  final String group;
  final String name;
  final String shortName;
  final String part;

  /// sunnet | farz | vacip
  final String type;
  final String typeLabel;
  final String notice;
  final int rakats;
  final String madhhab;
  final String niyet;
  final String intro;
  final List<String> info;
  final List<PrayerRakah> rakahs;

  factory PrayerPlan.fromJson(Map<String, dynamic> json) {
    return PrayerPlan(
      id: JsonMap.str(json['id']),
      group: JsonMap.str(json['group']),
      name: JsonMap.str(json['name']),
      shortName: JsonMap.str(json['shortName']),
      part: JsonMap.str(json['part']),
      type: JsonMap.str(json['type']),
      typeLabel: JsonMap.str(json['typeLabel']),
      notice: JsonMap.str(json['notice']),
      rakats: JsonMap.integer(json['rakats']),
      madhhab: JsonMap.str(json['madhhab'], 'hanafi'),
      niyet: JsonMap.str(json['niyet']),
      intro: JsonMap.str(json['intro']),
      info: JsonMap.strings(json['info']),
      rakahs: [
        for (final row in JsonMap.extractList(json['rakahDetails']))
          PrayerRakah.fromJson(row),
      ],
    );
  }
}

class PrayerGroup {
  const PrayerGroup({
    required this.id,
    required this.title,
    required this.emoji,
  });

  final String id;
  final String title;
  final String emoji;

  factory PrayerGroup.fromJson(Map<String, dynamic> json) => PrayerGroup(
        id: JsonMap.str(json['id']),
        title: JsonMap.str(json['title']),
        emoji: JsonMap.str(json['emoji']),
      );
}

/// One screen of the guided flow: a step inside a specific rakah.
class PrayerFlowItem {
  const PrayerFlowItem({
    required this.rakah,
    required this.step,
    required this.indexInRakah,
    required this.tips,
    required this.whys,
    required this.duaIds,
    this.surahNumber,
  });

  final PrayerRakah rakah;
  final PrayerLessonStep step;
  final int indexInRakah;
  final List<String> tips;
  final List<PrayerStepWhy> whys;
  final List<String> duaIds;
  final int? surahNumber;

  bool get opensRakah => indexInRakah == 0;
}

class PrayerLearningData {
  const PrayerLearningData({
    required this.groups,
    required this.steps,
    required this.prayers,
  });

  final List<PrayerGroup> groups;
  final Map<String, PrayerLessonStep> steps;
  final List<PrayerPlan> prayers;

  static PrayerLearningData? _cache;

  static Future<PrayerLearningData> load([AssetBundle? bundle]) async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw =
        await (bundle ?? rootBundle).loadString(AssetPaths.prayerLearning);
    return _cache = PrayerLearningData.fromJson(
      JsonMap.object(jsonDecode(raw)),
    );
  }

  factory PrayerLearningData.fromJson(Map<String, dynamic> json) {
    final stepsJson = JsonMap.object(json['steps']);
    return PrayerLearningData(
      groups: [
        for (final row in JsonMap.extractList(json['groups']))
          PrayerGroup.fromJson(row),
      ],
      steps: {
        for (final entry in stepsJson.entries)
          entry.key:
              PrayerLessonStep.fromJson(entry.key, JsonMap.object(entry.value)),
      },
      prayers: [
        for (final row in JsonMap.extractList(json['prayers']))
          PrayerPlan.fromJson(row),
      ],
    );
  }

  PrayerPlan? byId(String id) {
    for (final prayer in prayers) {
      if (prayer.id == id) return prayer;
    }
    return null;
  }

  List<PrayerPlan> inGroup(String group) => [
        for (final prayer in prayers)
          if (prayer.group == group) prayer
      ];

  /// Unknown step ids are skipped so a typo in the data cannot crash the flow.
  List<PrayerFlowItem> flow(PrayerPlan prayer) {
    final items = <PrayerFlowItem>[];
    for (final rakah in prayer.rakahs) {
      var index = 0;
      for (final id in rakah.steps) {
        final step = steps[id];
        if (step == null) continue;
        final surah = step.isSure ? rakah.surah : null;
        items.add(
          PrayerFlowItem(
            rakah: rakah,
            step: step,
            indexInRakah: index++,
            tips: [
              for (final tip in rakah.tips)
                if (tip.step == id) tip.text,
            ],
            whys: [
              for (final why in rakah.whys)
                if (why.step == id) why,
            ],
            duaIds: surah != null ? ['surah_$surah'] : step.duaIds,
            surahNumber: surah,
          ),
        );
      }
    }
    return items;
  }
}
