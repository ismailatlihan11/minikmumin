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
    // Narration files are not bundled; never fake a Dinle button for them.
    if (trimmed.startsWith('assets/audio/prophets/') ||
        trimmed.startsWith('assets/audio/qissalar/')) {
      return false;
    }
    // Show Dinle even if AssetCatalog loaded before a newly bundled folder.
    return trimmed.startsWith('assets/audio/prayer/') ||
        trimmed.startsWith('assets/audio/duas/') ||
        trimmed.startsWith('assets/audio/quran/') ||
        trimmed.startsWith('assets/audio/quran_learn/') ||
        trimmed.startsWith('assets/audio/wudu/') ||
        trimmed.startsWith('assets/audio/dhikr/') ||
        trimmed.startsWith('assets/audio/effects/');
  }
}
