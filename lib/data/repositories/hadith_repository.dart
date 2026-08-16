import '../../app/constants/asset_paths.dart';
import '../../core/utils/daily_seed.dart';
import '../datasources/json_content_datasource.dart';
import '../models/hadith.dart';

class HadithRepository {
  HadithRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Hadith>? _cache;

  Future<List<Hadith>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'hadith',
      fallbackPath: AssetPaths.hadith,
    );
    _cache = rows.map(Hadith.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<Hadith?> getById(String id) async {
    final all = await getAll();
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<List<Hadith>> getShort({int maxChars = 420}) async {
    final all = await getAll();
    final short = all.where((item) => item.plainTurkish.length <= maxChars).toList();
    return short.isEmpty ? all : short;
  }

  Future<Hadith?> getDaily({DateTime? now}) async {
    final all = await getShort();
    if (all.isEmpty) return null;
    return pickDaily(all, now: now);
  }
}
