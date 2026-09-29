import '../../core/utils/json_map.dart';

class Prophet {
  const Prophet({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.quranReferences,
    required this.illustrationPolicy,
    required this.sourceName,
    required this.summary,
    this.order = 0,
    this.shortTitle = '',
    this.lessons = const [],
    this.image = '',
    this.audio = '',
    this.displayName = '',
    this.roleTitleOverride = '',
  });

  final String id;
  final String name;
  final String arabicName;
  final List<String> quranReferences;
  final String illustrationPolicy;
  final String sourceName;
  final String summary;
  final int order;
  final String shortTitle;
  final List<String> lessons;
  final String image;
  final String audio;
  final String displayName;
  final String roleTitleOverride;

  String get quranReferencesText => quranReferences.join(' • ');

  bool get isMuhammad {
    final key = id.toLowerCase();
    return key == 'muhammed' || key == 'muhammad';
  }

  String get honorificName {
    final fromJson = displayName.trim();
    if (fromJson.isNotEmpty) return fromJson;
    if (isMuhammad) {
      return 'Hz. Muhammed ﷺ';
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.startsWith('Hz.') ? trimmed : 'Hz. $trimmed';
  }

  String get roleTitle {
    final fromJson = roleTitleOverride.trim();
    if (fromJson.isNotEmpty) return fromJson;
    return isMuhammad ? 'Son Peygamber' : shortTitle;
  }

  String get listTitle {
    final label = honorificName;
    return order > 0 ? '$order. $label' : label;
  }

  /// Short quiz label; keeps `name` as the lookup key.
  String get choiceName {
    final trimmed = name.trim();
    final base = trimmed.startsWith('Hz.') ? trimmed : 'Hz. $trimmed';
    return isMuhammad ? '$base ﷺ' : base;
  }

  factory Prophet.fromJson(Map<String, dynamic> json) {
    return Prophet(
      id: JsonMap.str(json['id']),
      name: JsonMap.str(json['name']),
      arabicName: JsonMap.str(json['arabicName']),
      quranReferences: _referencesFrom(json['quranReferences']),
      illustrationPolicy: JsonMap.str(json['illustrationPolicy'], 'symbolic_only'),
      sourceName: JsonMap.str(json['sourceName'], "Kur'an-ı Kerim"),
      summary: JsonMap.str(json['summary']),
      order: JsonMap.integer(json['order']),
      shortTitle: JsonMap.str(json['shortTitle']),
      lessons: JsonMap.strings(json['lessons']),
      image: JsonMap.str(json['image']),
      audio: JsonMap.str(json['audio']),
      displayName: JsonMap.str(json['displayName']),
      roleTitleOverride: JsonMap.str(json['roleTitle']),
    );
  }

  static List<String> _referencesFrom(dynamic value) {
    if (value is List) return JsonMap.strings(value);
    final text = JsonMap.str(value);
    if (text.isEmpty) return const [];
    return text
        .split(RegExp(r'[;,]'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arabicName': arabicName,
        'quranReferences': quranReferences,
        'illustrationPolicy': illustrationPolicy,
        'sourceName': sourceName,
        'summary': summary,
        'order': order,
        'shortTitle': shortTitle,
        'lessons': lessons,
        'image': image,
        'audio': audio,
        if (displayName.isNotEmpty) 'displayName': displayName,
        if (roleTitleOverride.isNotEmpty) 'roleTitle': roleTitleOverride,
      };
}
