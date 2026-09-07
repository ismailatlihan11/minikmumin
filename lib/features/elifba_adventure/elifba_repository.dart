import '../../app/constants/asset_paths.dart';
import '../../data/datasources/json_content_datasource.dart';
import 'elifba_models.dart';

class ElifbaRepository {
  ElifbaRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  ElifbaPack? _cache;

  Future<ElifbaPack> load() async {
    if (_cache != null) return _cache!;
    final json = await _datasource.loadObject(
      key: 'elifbaTecvid',
      fallbackPath: AssetPaths.elifbaTecvid,
    );
    _cache = ElifbaPack.fromJson(json);
    return _cache!;
  }
}
