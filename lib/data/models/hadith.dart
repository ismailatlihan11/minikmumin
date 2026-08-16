import '../../core/utils/json_map.dart';

class Hadith {
  const Hadith({
    required this.id,
    required this.arabic,
    required this.turkish,
  });

  final String id;
  final String arabic;
  final String turkish;

  String get plainTurkish =>
      turkish.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: JsonMap.str(json['hadith_id']),
      arabic: JsonMap.str(json['arabic']),
      turkish: JsonMap.str(json['turkish']),
    );
  }

  Map<String, dynamic> toJson() => {
        'hadith_id': id,
        'arabic': arabic,
        'turkish': turkish,
      };
}
