import '../../core/utils/json_map.dart';

class AsmaulHusna {
  const AsmaulHusna({
    required this.id,
    required this.arabic,
    required this.name,
    required this.meaning,
    required this.childExplanation,
    this.audio = '',
  });

  final int id;
  final String arabic;
  final String name;
  final String meaning;
  final String childExplanation;
  final String audio;

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      id: JsonMap.integer(json['id']),
      arabic: JsonMap.str(json['arabic']),
      name: JsonMap.str(json['name']),
      meaning: JsonMap.str(json['meaning']),
      childExplanation: JsonMap.str(json['childExplanation']),
      audio: JsonMap.str(json['audio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'name': name,
        'meaning': meaning,
        'childExplanation': childExplanation,
        'audio': audio,
      };
}
