import 'dart:convert';

import 'package:flutter/services.dart';

class JsonAssetLoader {
  JsonAssetLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, dynamic> _cache = {};

  Future<dynamic> load(String path) async {
    final cached = _cache[path];
    if (cached != null) return cached;
    final raw = await _bundle.loadString(path);
    final decoded = jsonDecode(raw);
    _cache[path] = decoded;
    return decoded;
  }

  void clearCache([String? path]) {
    if (path == null) {
      _cache.clear();
    } else {
      _cache.remove(path);
    }
  }
}
