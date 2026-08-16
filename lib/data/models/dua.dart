import '../../app/constants/content_assets.dart';
import '../../core/utils/json_map.dart';

class Dua {
  const Dua({
    required this.id,
    required this.title,
    required this.type,
    required this.arabic,
    required this.meaning,
    required this.reference,
    this.transliteration = '',
    this.audio = '',
  });

  final String id;
  final String title;
  final String type;
  final String arabic;
  final String meaning;
  final String reference;
  final String transliteration;
  final String audio;

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      type: JsonMap.str(json['type']),
      arabic: JsonMap.str(json['arabic']),
      meaning: JsonMap.str(json['meaning']),
      reference: JsonMap.str(json['reference']),
      transliteration: JsonMap.str(json['transliteration']),
      audio: JsonMap.str(json['audio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'arabic': arabic,
        'meaning': meaning,
        'reference': reference,
        'transliteration': transliteration,
        'audio': audio,
      };
}

class PrayerDua {
  const PrayerDua({
    required this.id,
    required this.title,
    required this.position,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
  });

  final String id;
  final String title;
  final String position;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;

  factory PrayerDua.fromJson(Map<String, dynamic> json) {
    return PrayerDua(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      position: JsonMap.str(json['position']),
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
      reference: JsonMap.str(json['reference']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'position': position,
        'arabic': arabic,
        'transliteration': transliteration,
        'meaning': meaning,
        'reference': reference,
      };
}

class DuaEntry {
  const DuaEntry({
    required this.id,
    required this.title,
    required this.section,
    required this.arabic,
    required this.meaning,
    required this.reference,
    this.transliteration = '',
    this.audio = '',
  });

  final String id;
  final String title;
  final String section;
  final String arabic;
  final String meaning;
  final String reference;
  final String transliteration;
  final String audio;

  factory DuaEntry.fromDua(Dua dua) {
    return DuaEntry(
      id: dua.id,
      title: dua.title,
      section: 'Kur\'an Duaları',
      arabic: dua.arabic,
      meaning: dua.meaning,
      reference: dua.reference,
      transliteration: dua.transliteration,
      audio: dua.audio.isNotEmpty ? dua.audio : (ContentAssets.audioFor(dua.id) ?? ''),
    );
  }

  factory DuaEntry.fromPrayerDua(PrayerDua dua) {
    return DuaEntry(
      id: dua.id,
      title: dua.title,
      section: dua.position,
      arabic: dua.arabic,
      meaning: dua.meaning,
      reference: dua.reference,
      transliteration: dua.transliteration,
      audio: ContentAssets.audioFor(dua.id) ?? '',
    );
  }
}
