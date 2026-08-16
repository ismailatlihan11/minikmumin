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
    this.order = 0,
    this.description = '',
    this.source = '',
    this.image = '',
    this.surahNumber,
    this.ayahNumber,
  });

  final String id;
  final String title;
  final String type;
  final String arabic;
  final String meaning;
  final String reference;
  final String transliteration;
  final String audio;
  final int order;
  final String description;
  final String source;
  final String image;
  final int? surahNumber;
  final int? ayahNumber;

  String get displayReference {
    if (source.isEmpty) return reference;
    if (reference.isEmpty) return source;
    return '$source • $reference';
  }

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
      order: JsonMap.integer(json['order']),
      description: JsonMap.str(json['description']),
      source: JsonMap.str(json['source']),
      image: JsonMap.str(json['image']),
      surahNumber: json['surahNumber'] == null ? null : JsonMap.integer(json['surahNumber']),
      ayahNumber: json['ayahNumber'] == null ? null : JsonMap.integer(json['ayahNumber']),
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
        'order': order,
        'description': description,
        'source': source,
        'image': image,
        if (surahNumber != null) 'surahNumber': surahNumber,
        if (ayahNumber != null) 'ayahNumber': ayahNumber,
      };
}

class PrayerVerse {
  const PrayerVerse({
    required this.ayahNo,
    required this.arabic,
    required this.meal,
  });

  final int ayahNo;
  final String arabic;
  final String meal;

  factory PrayerVerse.fromJson(Map<String, dynamic> json) {
    return PrayerVerse(
      ayahNo: JsonMap.integer(json['ayahNo']),
      arabic: JsonMap.str(json['arabic']),
      meal: JsonMap.str(json['meal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ayahNo': ayahNo,
        'arabic': arabic,
        'meal': meal,
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
    this.order = 0,
    this.type = '',
    this.usage = '',
    this.surahNumber,
    this.verses = const [],
  });

  final String id;
  final String title;
  final String position;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;
  final int order;
  final String type;
  final String usage;
  final int? surahNumber;
  final List<PrayerVerse> verses;

  bool get isSurah => type == 'surah' || verses.isNotEmpty;

  String get displayArabic {
    if (arabic.trim().isNotEmpty) return arabic;
    return verses.map((verse) => verse.arabic).join('\n');
  }

  String get displayMeaning {
    if (meaning.trim().isNotEmpty) return meaning;
    return verses.map((verse) => verse.meal).join('\n');
  }

  factory PrayerDua.fromJson(Map<String, dynamic> json) {
    final verses = JsonMap.extractList(json['verses']).map(PrayerVerse.fromJson).toList();
    final usage = JsonMap.str(json['usage']);
    final position = JsonMap.str(json['position']);
    return PrayerDua(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      position: position.isNotEmpty ? position : usage,
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
      reference: _referenceFrom(json),
      order: JsonMap.integer(json['order']),
      type: JsonMap.str(json['type']),
      usage: usage.isNotEmpty ? usage : position,
      surahNumber: json['surahNumber'] == null ? null : JsonMap.integer(json['surahNumber']),
      verses: verses,
    );
  }

  static String _referenceFrom(Map<String, dynamic> json) {
    final reference = JsonMap.str(json['reference']);
    if (reference.isNotEmpty) return reference;
    final source = JsonMap.str(json['source']);
    final sourceReference = JsonMap.str(json['sourceReference']);
    if (source.isEmpty) return sourceReference;
    if (sourceReference.isEmpty) return source;
    return '$source • $sourceReference';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'position': position,
        'arabic': arabic,
        'transliteration': transliteration,
        'meaning': meaning,
        'reference': reference,
        'order': order,
        'type': type,
        'usage': usage,
        if (surahNumber != null) 'surahNumber': surahNumber,
        if (verses.isNotEmpty) 'verses': verses.map((verse) => verse.toJson()).toList(),
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
    this.image = '',
    this.order = 0,
    this.verses = const [],
  });

  final String id;
  final String title;
  final String section;
  final String arabic;
  final String meaning;
  final String reference;
  final String transliteration;
  final String audio;
  final String image;
  final int order;
  final List<PrayerVerse> verses;

  String get displayImage =>
      image.isNotEmpty ? image : ContentAssets.duaImage(id);

  factory DuaEntry.fromDua(Dua dua) {
    return DuaEntry(
      id: dua.id,
      title: dua.title,
      section: dua.description.isNotEmpty ? dua.description : 'Kur\'an\'dan Dualar',
      arabic: dua.arabic,
      meaning: dua.meaning,
      reference: dua.displayReference,
      transliteration: dua.transliteration,
      audio: dua.audio.isNotEmpty ? dua.audio : ContentAssets.audioFor(dua.id),
      image: dua.image,
      order: dua.order,
    );
  }

  factory DuaEntry.fromPrayerDua(PrayerDua dua) {
    return DuaEntry(
      id: dua.id,
      title: dua.title,
      section: dua.usage.isNotEmpty ? dua.usage : dua.position,
      arabic: dua.displayArabic,
      meaning: dua.displayMeaning,
      reference: dua.reference,
      transliteration: dua.transliteration,
      audio: ContentAssets.audioFor(dua.id),
      order: dua.order,
      verses: dua.verses,
    );
  }
}
