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
    this.category = '',
    this.when = '',
    this.repeat = 1,
    this.note = '',
    this.responses = const [],
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
  final String category;

  /// When the dua is read, e.g. "Yemeğe başlamadan önce".
  final String when;
  final int repeat;
  final String note;
  final List<DuaResponse> responses;

  String get displayReference {
    if (source.isEmpty) return reference;
    if (reference.isEmpty) return source;
    return '$source • $reference';
  }

  factory Dua.fromJson(Map<String, dynamic> json, {int order = 0}) {
    final type = JsonMap.str(json['type']);
    final repeat = JsonMap.integer(json['repeat'], 1);
    final responses = json['response'];
    return Dua(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      type: type.isNotEmpty ? type : JsonMap.str(json['source_type']),
      arabic: JsonMap.str(json['arabic']),
      meaning: JsonMap.str(json['meaning']),
      reference: JsonMap.str(json['reference']),
      transliteration: JsonMap.str(json['transliteration']),
      audio: JsonMap.str(json['audio']),
      order: JsonMap.integer(json['order'], order),
      description: JsonMap.str(json['description']),
      source: JsonMap.str(json['source']),
      image: JsonMap.str(json['image']),
      surahNumber: json['surahNumber'] == null ? null : JsonMap.integer(json['surahNumber']),
      ayahNumber: json['ayahNumber'] == null ? null : JsonMap.integer(json['ayahNumber']),
      category: JsonMap.str(json['category']),
      when: JsonMap.str(json['when']),
      repeat: repeat < 1 ? 1 : repeat,
      note: JsonMap.str(json['note']),
      responses: responses is Map
          ? [
              for (final entry in responses.entries)
                DuaResponse.fromJson('${entry.key}', JsonMap.object(entry.value)),
            ]
          : const [],
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
        if (category.isNotEmpty) 'category': category,
        if (when.isNotEmpty) 'when': when,
        if (repeat != 1) 'repeat': repeat,
        if (note.isNotEmpty) 'note': note,
      };
}

/// A line said back and forth, e.g. after sneezing.
class DuaResponse {
  const DuaResponse({
    required this.label,
    required this.arabic,
    this.transliteration = '',
    this.meaning = '',
  });

  final String label;
  final String arabic;
  final String transliteration;
  final String meaning;

  static const _labels = {
    'other_person': 'Duyan kişi der ki',
    'sneezer_reply': 'Aksıran kişi cevap verir',
  };

  factory DuaResponse.fromJson(String key, Map<String, dynamic> json) {
    return DuaResponse(
      label: _labels[key] ?? key,
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
    );
  }
}

class PrayerVerse {
  const PrayerVerse({
    required this.ayahNo,
    required this.arabic,
    required this.meal,
    this.transliteration = '',
    this.mealRange = '',
  });

  final int ayahNo;
  final String arabic;
  final String meal;
  final String transliteration;

  /// Meal birden fazla ayeti birlikte karşılıyorsa (ör. "2-4"); boşsa tek ayet.
  final String mealRange;

  String get mealLabel => mealRange.isNotEmpty ? mealRange : '$ayahNo';

  factory PrayerVerse.fromJson(Map<String, dynamic> json) {
    final meal = JsonMap.str(json['meal']);
    return PrayerVerse(
      ayahNo: JsonMap.integer(json['ayahNo']),
      arabic: JsonMap.str(json['arabic']),
      meal: meal.isNotEmpty ? meal : JsonMap.str(json['meaning']),
      transliteration: JsonMap.str(json['transliteration']),
      mealRange: JsonMap.str(json['mealRange']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ayahNo': ayahNo,
        'arabic': arabic,
        if (transliteration.isNotEmpty) 'transliteration': transliteration,
        'meal': meal,
        if (mealRange.isNotEmpty) 'mealRange': mealRange,
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
    this.repeat = 1,
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
  final int repeat;

  bool get isSurah => type == 'surah' || verses.isNotEmpty;

  String get displayArabic {
    if (arabic.trim().isNotEmpty) return arabic;
    return verses.map((verse) => verse.arabic).join('\n');
  }

  String get displayMeaning {
    if (meaning.trim().isNotEmpty) return meaning;
    return verses
        .map((verse) => verse.meal)
        .where((meal) => meal.isNotEmpty)
        .join('\n');
  }

  factory PrayerDua.fromJson(Map<String, dynamic> json) {
    final verses = JsonMap.extractList(json['verses']).map(PrayerVerse.fromJson).toList();
    final usage = JsonMap.str(json['usage']);
    final position = JsonMap.str(json['position']);
    final repeat = JsonMap.integer(json['repeat'], 1);
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
      repeat: repeat < 1 ? 1 : repeat,
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
        if (repeat != 1) 'repeat': repeat,
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
    this.surahNumber,
    this.when = '',
    this.repeat = 1,
    this.audioRepeat,
    this.note = '',
    this.responses = const [],
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
  final int? surahNumber;
  final String when;
  final int repeat;
  final String note;
  final List<DuaResponse> responses;

  /// How many times "Dinle" plays the clip; prayer duas carry it apart from
  /// [repeat] because their section title already says how often to recite.
  final int? audioRepeat;

  int get playRepeat => audioRepeat ?? repeat;

  bool get isSurah => surahNumber != null || verses.isNotEmpty;

  String get displayImage =>
      image.isNotEmpty ? image : ContentAssets.duaImage(id);

  String get fullArabic {
    if (verses.isNotEmpty) {
      return verses
          .map((verse) => verse.arabic.trim())
          .where((line) => line.isNotEmpty)
          .join('\n');
    }
    return arabic.trim();
  }

  String get fullReading {
    if (verses.isNotEmpty) {
      final joined = verses
          .map((verse) => verse.transliteration.trim())
          .where((line) => line.isNotEmpty)
          .join('\n');
      if (joined.isNotEmpty) return joined;
    }
    return transliteration.trim();
  }

  String get fullMeaning {
    if (verses.isNotEmpty) {
      final numbered = verses.length > 1;
      return verses
          .map((verse) {
            final meal = verse.meal.trim();
            if (meal.isEmpty) return '';
            return numbered ? '${verse.mealLabel}. $meal' : meal;
          })
          .where((line) => line.isNotEmpty)
          .join('\n\n');
    }
    return meaning.trim();
  }

  factory DuaEntry.fromDua(Dua dua) {
    return DuaEntry(
      id: dua.id,
      title: dua.title,
      section: dua.description.isNotEmpty ? dua.description : 'Günlük Dualar',
      arabic: dua.arabic,
      meaning: dua.meaning,
      reference: dua.displayReference,
      transliteration: dua.transliteration,
      audio: dua.audio,
      image: dua.image,
      order: dua.order,
      when: dua.when,
      repeat: dua.repeat,
      note: dua.note,
      responses: dua.responses,
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
      surahNumber: dua.surahNumber,
      audioRepeat: dua.repeat,
    );
  }
}
