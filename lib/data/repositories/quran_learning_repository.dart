import 'package:flutter/foundation.dart';

import '../../app/constants/asset_paths.dart';
import '../datasources/json_content_datasource.dart';
import '../models/quran_learning.dart';

class QuranLearningRepository {
  QuranLearningRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  QuranLearningPack? _cache;

  Future<QuranLearningPack> load() async {
    if (_cache != null) return _cache!;
    try {
      final json = await _datasource.loadObject(
        key: 'quranLearning',
        fallbackPath: AssetPaths.quranLearning,
      );
      _cache = QuranLearningPack.fromJson(json);
      return _cache!;
    } catch (error, stack) {
      debugPrint("Kur'an Öğren JSON yüklenemedi: $error\n$stack");
      rethrow;
    }
  }
}
