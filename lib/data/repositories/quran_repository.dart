import '../../app/constants/asset_paths.dart';
import '../../app/constants/daily_ayah_pool.dart';
import '../../app/constants/surah_names.dart';
import '../../core/utils/daily_seed.dart';
import '../datasources/json_content_datasource.dart';
import '../models/quran_verse.dart';
import '../models/progress.dart';

class QuranRepository {
  QuranRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<QuranVerse>? _cache;
  List<MushafPageData>? _mushafPages;

  Future<List<QuranVerse>> getAllAyahs() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'quran',
      fallbackPath: AssetPaths.quran,
      itemsKey: 'ayet',
    );
    _cache = rows.map(QuranVerse.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<List<QuranVerse>> getSurah(int surahId) async {
    final all = await getAllAyahs();
    return all.where((verse) => verse.surahId == surahId).toList(growable: false);
  }

  Future<QuranSurah> getSurahBundle(int surahId) async {
    return QuranSurah(id: surahId, verses: await getSurah(surahId));
  }

  Future<QuranVerse?> getByAyahId(int ayahId) async {
    final all = await getAllAyahs();
    for (final verse in all) {
      if (verse.ayahId == ayahId) return verse;
    }
    return null;
  }

  Future<QuranVerse?> getDailyAyah({DateTime? now}) async {
    final all = await getAllAyahs();
    if (all.isEmpty) return null;
    final pool = <QuranVerse>[];
    for (final pair in DailyAyahPool.pairs) {
      for (final verse in all) {
        if (verse.surahId == pair.$1 && verse.ayahNo == pair.$2) {
          pool.add(verse);
          break;
        }
      }
    }
    if (pool.isEmpty) return pickDaily(all, now: now);
    return pickDaily(pool, now: now);
  }

  Future<AyetulKursi> getAyetulKursi() async {
    final json = await _datasource.loadObject(
      key: 'ayetulKursi',
      fallbackPath: AssetPaths.ayetulKursi,
    );
    return AyetulKursi.fromJson(json);
  }

  Future<List<ShortAyah>> getLastTenAyahs() async {
    final rows = await _datasource.loadList(
      key: 'quranLast10',
      fallbackPath: AssetPaths.quranLast10,
    );
    return rows.map(ShortAyah.fromJson).toList(growable: false);
  }

  Future<List<MushafPageData>> getMushafPages() async {
    if (_mushafPages != null) return _mushafPages!;
    _mushafPages = MushafPageData.group(await getAllAyahs());
    return _mushafPages!;
  }

  Future<List<SurahIndexItem>> getSurahIndex() async {
    final all = await getAllAyahs();
    final counts = <int, int>{};
    for (final verse in all) {
      counts[verse.surahId] = (counts[verse.surahId] ?? 0) + 1;
    }
    return [
      for (var id = 1; id <= 114; id++)
        SurahIndexItem(
          id: id,
          name: surahName(id),
          ayahCount: counts[id] ?? 0,
        ),
    ];
  }
}
