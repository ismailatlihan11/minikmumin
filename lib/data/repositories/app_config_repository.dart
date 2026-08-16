import '../datasources/json_content_datasource.dart';
import '../models/app_config.dart';

class AppConfigRepository {
  AppConfigRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  AppConfig? _cache;

  Future<AppConfig> load() async {
    _cache ??= await _datasource.loadConfig();
    return _cache!;
  }
}
