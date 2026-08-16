import '../../app/constants/asset_paths.dart';
import '../../core/data/json_asset_loader.dart';
import '../../core/utils/json_map.dart';
import '../models/app_config.dart';

class JsonContentDatasource {
  JsonContentDatasource({
    JsonAssetLoader? loader,
    AppConfig? config,
  })  : _loader = loader ?? JsonAssetLoader(),
        _config = config;

  final JsonAssetLoader _loader;
  AppConfig? _config;

  JsonAssetLoader get loader => _loader;

  Future<AppConfig> loadConfig() async {
    if (_config != null) return _config!;
    final raw = JsonMap.object(await _loader.load(AssetPaths.appConfig));
    _config = AppConfig.fromJson(raw);
    return _config!;
  }

  Future<String> pathFor(String key, String fallback) async {
    final config = await loadConfig();
    final configured = config.contentPath(key, fallback);
    return configured.isEmpty ? fallback : configured;
  }

  Future<dynamic> loadRaw(String assetPath) => _loader.load(assetPath);

  Future<List<Map<String, dynamic>>> loadList({
    required String key,
    required String fallbackPath,
    String itemsKey = 'items',
  }) async {
    final path = await pathFor(key, fallbackPath);
    final data = await _loader.load(path);
    return JsonMap.extractList(data, itemsKey: itemsKey);
  }

  Future<Map<String, dynamic>> loadObject({
    required String key,
    required String fallbackPath,
  }) async {
    final path = await pathFor(key, fallbackPath);
    return JsonMap.object(await _loader.load(path));
  }
}
