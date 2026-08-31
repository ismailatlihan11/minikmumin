import '../../app/constants/asset_paths.dart';
import '../../core/utils/json_map.dart';
import '../datasources/json_content_datasource.dart';
import '../models/dhikr.dart';

class DhikrRepository {
  DhikrRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Dhikr>? _catalog;
  DhikrAssetManifest? _manifest;

  Future<List<Dhikr>> loadCatalog() async {
    if (_catalog != null) return _catalog!;
    final rows = await _datasource.loadList(
      key: 'dhikr',
      fallbackPath: AssetPaths.dhikr,
    );
    _catalog = rows.map(Dhikr.fromJson).toList(growable: false);
    return _catalog!;
  }

  Future<DhikrAssetManifest> loadManifest() async {
    if (_manifest != null) return _manifest!;
    final json = JsonMap.object(
      await _datasource.loadRaw(AssetPaths.dhikrAssets),
    );
    _manifest = DhikrAssetManifest.fromJson(json);
    return _manifest!;
  }

  List<Dhikr> merge({
    required List<Dhikr> catalog,
    required List<Dhikr> saved,
  }) {
    final savedById = {for (final item in saved) item.id: item};
    final merged = <Dhikr>[
      for (final item in catalog)
        _withSavedProgress(item, savedById.remove(item.id)),
    ];
    merged.addAll(savedById.values);
    return merged;
  }

  Dhikr _withSavedProgress(Dhikr catalog, Dhikr? saved) {
    if (saved == null) return catalog;
    if (saved.isCustom) return saved;
    return saved.copyWith(
      title: catalog.title,
      arabic: catalog.arabic,
      transliteration: catalog.transliteration,
      meaning: catalog.meaning,
      description: catalog.description,
      category: catalog.category,
      colorTheme: catalog.colorTheme,
      audioAsset: catalog.audioAsset.isEmpty ? saved.audioAsset : catalog.audioAsset,
      imageAsset: catalog.imageAsset.isEmpty ? saved.imageAsset : catalog.imageAsset,
    );
  }
}
