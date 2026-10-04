import '../../core/utils/json_map.dart';
import '../../core/utils/quran_font.dart';

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

  bool get hasMeal => meal.trim().isNotEmpty;
  int get displayPage => page;
  bool get isSajdahAyah => mushafIsSajdahAyah(surahId, ayahNo);

  factory QuranVerse.fromJson(Map<String, dynamic> json) {
    final text = JsonMap.object(json['metin']);
    return QuranVerse(
      ayahId: JsonMap.integer(json['ayet_id']),
      surahId: JsonMap.integer(json['sure_id']),
      ayahNo: JsonMap.integer(json['ayet_no']),
      page: JsonMap.integer(json['sayfa']),
      arabic: QuranFont.format(JsonMap.str(text['arapca'])),
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

class MushafPageData {
  const MushafPageData({
    required this.index,
    required this.jsonPage,
    required this.verses,
  });

  final int index;
  final int jsonPage;
  final List<QuranVerse> verses;

  int get displayNumber => jsonPage;

  /// Cüz 1 is pages 0–20; later juzes are 20 pages (21–40, 41–60, …).
  int get juzNumber => mushafJuzForPage(jsonPage);

  Set<int> get surahIds => {for (final verse in verses) verse.surahId};

  static List<MushafPageData> group(List<QuranVerse> verses) {
    final map = <int, List<QuranVerse>>{};
    for (final verse in verses) {
      map.putIfAbsent(verse.page, () => []).add(verse);
    }
    final keys = map.keys.toList()..sort();
    return [
      for (var i = 0; i < keys.length; i++)
        MushafPageData(
          index: i,
          jsonPage: keys[i],
          verses: List<QuranVerse>.unmodifiable(map[keys[i]]!),
        ),
    ];
  }
}

/// Secde ayetleri (14): 7:206, 13:15, 16:49, 17:107, 19:58, 22:18,
/// 38:24, 25:60, 27:25, 32:15, 41:37, 53:62, 84:21, 96:19.
const mushafSajdahAyahs = <(int, int)>[
  (7, 206),
  (13, 15),
  (16, 49),
  (17, 107),
  (19, 58),
  (22, 18),
  (38, 24),
  (25, 60),
  (27, 25),
  (32, 15),
  (41, 37),
  (53, 62),
  (84, 21),
  (96, 19),
];

bool mushafIsSajdahAyah(int surahId, int ayahNo) {
  for (final ayah in mushafSajdahAyahs) {
    if (ayah.$1 == surahId && ayah.$2 == ayahNo) return true;
  }
  return false;
}

/// Cüz 1: 0–20. Cüz 2: 21–40. Cüz 3: 41–60. Last pages stay in cüz 30.
int mushafJuzForPage(int jsonPage) {
  if (jsonPage <= 20) return 1;
  return ((jsonPage - 1) ~/ 20 + 1).clamp(1, 30);
}

int mushafFirstPageForJuz(int juz) {
  final j = juz.clamp(1, 30);
  if (j <= 1) return 0;
  return (j - 1) * 20 + 1;
}

(int start, int end) mushafPageRangeForJuz(int juz, {int lastPage = 603}) {
  final j = juz.clamp(1, 30);
  final start = mushafFirstPageForJuz(j);
  if (j >= 30) return (start, lastPage < start ? start : lastPage);
  if (j == 1) return (0, 20);
  return (start, j * 20);
}

/// Cüz no (1–30), ilk sayfa (0) veya "0-20" gibi sayfa aralığı.
int? mushafJuzFromInput(String raw) {
  final compact = raw
      .trim()
      .replaceAll(RegExp(r'[–—−]'), '-')
      .replaceAll(' ', '');
  if (compact.isEmpty) return null;
  final range = RegExp(r'^(\d+)-(\d+)$').firstMatch(compact);
  if (range != null) {
    return mushafJuzForPage(int.parse(range[1]!));
  }
  final n = int.tryParse(compact);
  if (n == null) return null;
  if (n == 0) return 1;
  if (n >= 1 && n <= 30) return n;
  return null;
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
