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
  });

  final String id;
  final String name;
  final String arabicName;
  final String quranReferences;
  final String illustrationPolicy;
  final String sourceName;
  final String summary;

  factory Prophet.fromJson(Map<String, dynamic> json) {
    return Prophet(
      id: JsonMap.str(json['id']),
      name: JsonMap.str(json['name']),
      arabicName: JsonMap.str(json['arabicName']),
      quranReferences: JsonMap.str(json['quranReferences']),
      illustrationPolicy: JsonMap.str(json['illustrationPolicy']),
      sourceName: JsonMap.str(json['sourceName']),
      summary: JsonMap.str(json['summary']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arabicName': arabicName,
        'quranReferences': quranReferences,
        'illustrationPolicy': illustrationPolicy,
        'sourceName': sourceName,
        'summary': summary,
      };
}
