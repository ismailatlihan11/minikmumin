import '../../app/constants/asset_paths.dart';
import '../../core/utils/daily_seed.dart';
import '../datasources/json_content_datasource.dart';
import '../models/asmaul_husna.dart';

class AsmaRepository {
  AsmaRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<AsmaulHusna>? _cache;

  Future<List<AsmaulHusna>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'asmaulHusna',
      fallbackPath: AssetPaths.asmaulHusna,
    );
    _cache = rows.map(AsmaulHusna.fromJson).toList(growable: false);
    return _cache!;
  }

  Future<AsmaulHusna?> getDaily({DateTime? now}) async {
    final all = await getAll();
    if (all.isEmpty) return null;
    return pickDaily(all, now: now);
  }
}
