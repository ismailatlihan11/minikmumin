import '../../core/utils/json_map.dart';

class QuranVerse {
  const QuranVerse({
    required this.ayahId,
    required this.surahId,
    required this.ayahNo,
    required this.page,
    required this.arabic,
    required this.meal,
  });

  final int ayahId;
  final int surahId;
  final int ayahNo;
  final int page;
  final String arabic;
  final String meal;

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    final text = JsonMap.object(json['metin']);
    return QuranVerse(
      ayahId: JsonMap.integer(json['ayet_id']),
      surahId: JsonMap.integer(json['sure_id']),
      ayahNo: JsonMap.integer(json['ayet_no']),
      page: JsonMap.integer(json['sayfa']),
      arabic: JsonMap.str(text['arapca']),
      meal: JsonMap.str(text['meal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'ayet_id': ayahId,
        'sure_id': surahId,
        'ayet_no': ayahNo,
        'sayfa': page,
        'metin': {'arapca': arabic, 'meal': meal},
      };
}

class QuranSurah {
  const QuranSurah({
    required this.id,
    required this.verses,
  });

  final int id;
  final List<QuranVerse> verses;

  int get ayahCount => verses.length;
}

class SurahIndexItem {
  const SurahIndexItem({
    required this.id,
    required this.name,
    required this.ayahCount,
  });

  final int id;
  final String name;
  final int ayahCount;
}

class ShortAyah {
  const ShortAyah({
    required this.surah,
    required this.surahName,
    required this.ayah,
    required this.arabic,
    required this.meaning,
  });

  final int surah;
  final String surahName;
  final int ayah;
  final String arabic;
  final String meaning;

  factory ShortAyah.fromJson(Map<String, dynamic> json) {
    return ShortAyah(
      surah: JsonMap.integer(json['surah']),
      surahName: JsonMap.str(json['surahName']),
      ayah: JsonMap.integer(json['ayah']),
      arabic: JsonMap.str(json['arabic']),
      meaning: JsonMap.str(json['meaning']),
    );
  }
}
