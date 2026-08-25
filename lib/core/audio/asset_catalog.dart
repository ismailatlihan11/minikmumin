import 'package:flutter/services.dart';

abstract final class AssetCatalog {
  static final Set<String> _assets = <String>{};

  static Future<void> load() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _assets
        ..clear()
        ..addAll(manifest.listAssets());
    } catch (_) {
      _assets.clear();
    }
  }

  static bool contains(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return false;
    if (_assets.contains(trimmed)) return true;
    // Show Dinle even if AssetCatalog loaded before a newly bundled folder.
    return trimmed.startsWith('assets/audio/wudu/');
  }
}
