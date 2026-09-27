import '../../core/utils/json_map.dart';

enum DhikrVibrationIntensity { light, normal, strong }

class Dhikr {
  const Dhikr({
    required this.id,
    required this.title,
    this.arabic = '',
    this.transliteration = '',
    this.meaning = '',
    this.description = '',
    this.category = 'tesbih',
    this.targetCount = 33,
    this.currentCount = 0,
    this.totalCount = 0,
    this.dailyCount = 0,
    this.dailyDate = '',
    this.isFavorite = false,
    this.isCompleted = false,
    this.isPaused = false,
    this.lastUsedAt,
    this.createdAt,
    this.updatedAt,
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.vibrationEvery = 1,
    this.soundEvery = 33,
    this.incrementStep = 1,
    this.colorTheme = 'green',
    this.audioAsset = '',
    this.imageAsset = '',
    this.dailySessionTarget = 0,
    this.sessionStartedAt,
    this.isCustom = false,
    this.contentEdited = false,
  });

  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String description;
  final String category;
  final int targetCount;
  final int currentCount;
  final int totalCount;
  final int dailyCount;
  final String dailyDate;
  final bool isFavorite;
  final bool isCompleted;
  final bool isPaused;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final int vibrationEvery;
  final int soundEvery;
  final int incrementStep;
  final String colorTheme;
  final String audioAsset;
  final String imageAsset;
  final int dailySessionTarget;
  final DateTime? sessionStartedAt;
  final bool isCustom;
  /// User edited title/text/target; catalog merge must not overwrite.
  final bool contentEdited;

  double get uiProgress {
    if (targetCount <= 0) return 0;
    return (currentCount / targetCount).clamp(0, 1);
  }

  Dhikr copyWith({
    String? title,
    String? arabic,
    String? transliteration,
    String? meaning,
    String? description,
    String? category,
    int? targetCount,
    int? currentCount,
    int? totalCount,
    int? dailyCount,
    String? dailyDate,
    bool? isFavorite,
    bool? isCompleted,
    bool? isPaused,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? vibrationEnabled,
    bool? soundEnabled,
    int? vibrationEvery,
    int? soundEvery,
    int? incrementStep,
    String? colorTheme,
    String? audioAsset,
    String? imageAsset,
    int? dailySessionTarget,
    DateTime? sessionStartedAt,
    bool clearSessionStartedAt = false,
    bool? isCustom,
    bool? contentEdited,
  }) {
    return Dhikr(
      id: id,
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      description: description ?? this.description,
      category: category ?? this.category,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      totalCount: totalCount ?? this.totalCount,
      dailyCount: dailyCount ?? this.dailyCount,
      dailyDate: dailyDate ?? this.dailyDate,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      isPaused: isPaused ?? this.isPaused,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEvery: vibrationEvery ?? this.vibrationEvery,
      soundEvery: soundEvery ?? this.soundEvery,
      incrementStep: incrementStep ?? this.incrementStep,
      colorTheme: colorTheme ?? this.colorTheme,
      audioAsset: audioAsset ?? this.audioAsset,
      imageAsset: imageAsset ?? this.imageAsset,
      dailySessionTarget: dailySessionTarget ?? this.dailySessionTarget,
      sessionStartedAt: clearSessionStartedAt
          ? null
          : (sessionStartedAt ?? this.sessionStartedAt),
      isCustom: isCustom ?? this.isCustom,
      contentEdited: contentEdited ?? this.contentEdited,
    );
  }

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
      description: JsonMap.str(json['description']),
      category: JsonMap.str(json['category'], 'tesbih'),
      targetCount: JsonMap.integer(json['targetCount'], 33).clamp(1, 100000),
      currentCount: JsonMap.integer(json['currentCount']).clamp(0, 100000000),
      totalCount: JsonMap.integer(json['totalCount']).clamp(0, 100000000),
      dailyCount: JsonMap.integer(json['dailyCount']).clamp(0, 100000000),
      dailyDate: JsonMap.str(json['dailyDate']),
      isFavorite: JsonMap.flag(json['isFavorite']),
      isCompleted: JsonMap.flag(json['isCompleted']),
      isPaused: JsonMap.flag(json['isPaused']),
      lastUsedAt: _date(json['lastUsedAt']),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      vibrationEnabled: JsonMap.flag(json['vibrationEnabled'], true),
      soundEnabled: JsonMap.flag(json['soundEnabled'], true),
      vibrationEvery: JsonMap.integer(json['vibrationEvery'], 1).clamp(1, 100000),
      soundEvery: JsonMap.integer(json['soundEvery'], 33).clamp(1, 100000),
      incrementStep: JsonMap.integer(json['incrementStep'], 1).clamp(1, 1000),
      colorTheme: JsonMap.str(json['colorTheme'], 'green'),
      audioAsset: JsonMap.str(json['audioAsset']),
      imageAsset: JsonMap.str(json['imageAsset']),
      dailySessionTarget: JsonMap.integer(json['dailySessionTarget']).clamp(0, 1000),
      sessionStartedAt: _date(json['sessionStartedAt']),
      isCustom: JsonMap.flag(json['isCustom']),
      contentEdited: JsonMap.flag(json['contentEdited']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'arabic': arabic,
        'transliteration': transliteration,
        'meaning': meaning,
        'description': description,
        'category': category,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'totalCount': totalCount,
        'dailyCount': dailyCount,
        'dailyDate': dailyDate,
        'isFavorite': isFavorite,
        'isCompleted': isCompleted,
        'isPaused': isPaused,
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'vibrationEnabled': vibrationEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEvery': vibrationEvery,
        'soundEvery': soundEvery,
        'incrementStep': incrementStep,
        'colorTheme': colorTheme,
        'audioAsset': audioAsset,
        'imageAsset': imageAsset,
        'dailySessionTarget': dailySessionTarget,
        'sessionStartedAt': sessionStartedAt?.toIso8601String(),
        'isCustom': isCustom,
        'contentEdited': contentEdited,
      };

  static DateTime? _date(dynamic value) {
    final raw = JsonMap.str(value);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

class DhikrSession {
  const DhikrSession({
    required this.id,
    required this.dhikrId,
    required this.target,
    required this.completedAt,
    required this.count,
    this.durationSeconds = 0,
  });

  final String id;
  final String dhikrId;
  final int target;
  final DateTime completedAt;
  final int count;
  final int durationSeconds;

  factory DhikrSession.fromJson(Map<String, dynamic> json) {
    return DhikrSession(
      id: JsonMap.str(json['id']),
      dhikrId: JsonMap.str(json['dhikrId']),
      target: JsonMap.integer(json['target']),
      completedAt: DateTime.tryParse(JsonMap.str(json['completedAt'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      count: JsonMap.integer(json['count']),
      durationSeconds: JsonMap.integer(json['durationSeconds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dhikrId': dhikrId,
        'target': target,
        'completedAt': completedAt.toIso8601String(),
        'count': count,
        'durationSeconds': durationSeconds,
      };
}

class DhikrDailyStat {
  const DhikrDailyStat({
    required this.date,
    required this.dhikrId,
    this.count = 0,
    this.completedSessions = 0,
  });

  final String date;
  final String dhikrId;
  final int count;
  final int completedSessions;

  DhikrDailyStat copyWith({int? count, int? completedSessions}) {
    return DhikrDailyStat(
      date: date,
      dhikrId: dhikrId,
      count: count ?? this.count,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }

  factory DhikrDailyStat.fromJson(Map<String, dynamic> json) {
    return DhikrDailyStat(
      date: JsonMap.str(json['date']),
      dhikrId: JsonMap.str(json['dhikrId']),
      count: JsonMap.integer(json['count']),
      completedSessions: JsonMap.integer(json['completedSessions']),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'dhikrId': dhikrId,
        'count': count,
        'completedSessions': completedSessions,
      };
}

class DhikrSettings {
  const DhikrSettings({
    this.vibrationEnabled = true,
    this.soundEnabled = true,
    this.vibrationIntensity = DhikrVibrationIntensity.normal,
    this.reminderEnabled = false,
    this.reminderMorningHour = 8,
    this.reminderEveningHour = 21,
  });

  final bool vibrationEnabled;
  final bool soundEnabled;
  final DhikrVibrationIntensity vibrationIntensity;
  final bool reminderEnabled;
  final int reminderMorningHour;
  final int reminderEveningHour;

  DhikrSettings copyWith({
    bool? vibrationEnabled,
    bool? soundEnabled,
    DhikrVibrationIntensity? vibrationIntensity,
    bool? reminderEnabled,
    int? reminderMorningHour,
    int? reminderEveningHour,
  }) {
    return DhikrSettings(
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMorningHour: reminderMorningHour ?? this.reminderMorningHour,
      reminderEveningHour: reminderEveningHour ?? this.reminderEveningHour,
    );
  }

  factory DhikrSettings.fromJson(Map<String, dynamic> json) {
    return DhikrSettings(
      vibrationEnabled: JsonMap.flag(json['vibrationEnabled'], true),
      soundEnabled: JsonMap.flag(json['soundEnabled'], true),
      vibrationIntensity: switch (JsonMap.str(json['vibrationIntensity'], 'normal')) {
        'light' => DhikrVibrationIntensity.light,
        'strong' => DhikrVibrationIntensity.strong,
        _ => DhikrVibrationIntensity.normal,
      },
      reminderEnabled: JsonMap.flag(json['reminderEnabled']),
      reminderMorningHour: JsonMap.integer(json['reminderMorningHour'], 8).clamp(0, 23),
      reminderEveningHour: JsonMap.integer(json['reminderEveningHour'], 21).clamp(0, 23),
    );
  }

  Map<String, dynamic> toJson() => {
        'vibrationEnabled': vibrationEnabled,
        'soundEnabled': soundEnabled,
        'vibrationIntensity': vibrationIntensity.name,
        'reminderEnabled': reminderEnabled,
        'reminderMorningHour': reminderMorningHour,
        'reminderEveningHour': reminderEveningHour,
      };
}

class DhikrProgress {
  const DhikrProgress({
    required this.dhikrId,
    required this.target,
    required this.current,
    this.lastUsedAt,
    this.status = 'paused',
  });

  final String dhikrId;
  final int target;
  final int current;
  final DateTime? lastUsedAt;
  final String status;

  factory DhikrProgress.fromJson(Map<String, dynamic> json) {
    return DhikrProgress(
      dhikrId: JsonMap.str(json['dhikrId']),
      target: JsonMap.integer(json['target']),
      current: JsonMap.integer(json['current']),
      lastUsedAt: DateTime.tryParse(JsonMap.str(json['lastUsedAt'])),
      status: JsonMap.str(json['status'], 'paused'),
    );
  }

  Map<String, dynamic> toJson() => {
        'dhikrId': dhikrId,
        'target': target,
        'current': current,
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'status': status,
      };
}

class DhikrFavorite {
  const DhikrFavorite({required this.dhikrId});

  final String dhikrId;

  factory DhikrFavorite.fromJson(Map<String, dynamic> json) {
    return DhikrFavorite(dhikrId: JsonMap.str(json['dhikrId'] ?? json['id']));
  }

  Map<String, dynamic> toJson() => {'dhikrId': dhikrId};
}

class DhikrAssetManifest {
  const DhikrAssetManifest({
    required this.click,
    required this.complete,
    required this.fallbackImage,
    required this.items,
  });

  final String click;
  final String complete;
  final String fallbackImage;
  final Map<String, DhikrAssetItem> items;

  static const empty = DhikrAssetManifest(
    click: 'assets/audio/effects/tesbih_click.wav',
    complete: 'assets/audio/effects/ders_tamamlandi.mp3',
    fallbackImage: 'assets/images/home/circle_zikr.jpg',
    items: {},
  );

  String imageFor(Dhikr dhikr) {
    final mapped = items[dhikr.id]?.image ?? '';
    if (mapped.isNotEmpty) return mapped;
    if (dhikr.imageAsset.isNotEmpty) return dhikr.imageAsset;
    return fallbackImage;
  }

  String audioFor(Dhikr dhikr) {
    final mapped = items[dhikr.id]?.audio ?? '';
    if (mapped.isNotEmpty) return mapped;
    return dhikr.audioAsset;
  }

  factory DhikrAssetManifest.fromJson(Map<String, dynamic> json) {
    final rows = JsonMap.extractList(json, itemsKey: 'items');
    return DhikrAssetManifest(
      click: JsonMap.str(json['click'], empty.click),
      complete: JsonMap.str(json['complete'], empty.complete),
      fallbackImage: JsonMap.str(json['fallbackImage'], empty.fallbackImage),
      items: {
        for (final row in rows)
          JsonMap.str(row['id']): DhikrAssetItem.fromJson(row),
      },
    );
  }
}

class DhikrAssetItem {
  const DhikrAssetItem({required this.id, this.image = '', this.audio = ''});

  final String id;
  final String image;
  final String audio;

  factory DhikrAssetItem.fromJson(Map<String, dynamic> json) {
    return DhikrAssetItem(
      id: JsonMap.str(json['id']),
      image: JsonMap.str(json['image']),
      audio: JsonMap.str(json['audio']),
    );
  }
}

class DhikrTapResult {
  const DhikrTapResult({
    required this.dhikr,
    this.vibrated = false,
    this.sounded = false,
    this.completed = false,
    this.session,
  });

  final Dhikr dhikr;
  final bool vibrated;
  final bool sounded;
  final bool completed;
  final DhikrSession? session;
}

class DhikrOverview {
  const DhikrOverview({
    required this.todayCount,
    required this.weekCount,
    required this.monthCount,
    required this.totalCount,
    required this.todayCompleted,
    required this.activeCount,
    required this.pausedCount,
    required this.favoriteCount,
    required this.weekBars,
  });

  final int todayCount;
  final int weekCount;
  final int monthCount;
  final int totalCount;
  final int todayCompleted;
  final int activeCount;
  final int pausedCount;
  final int favoriteCount;
  final List<int> weekBars;
}
