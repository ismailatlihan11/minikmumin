import '../../app/constants/asset_paths.dart';
import '../../data/datasources/json_content_datasource.dart';
import '../../data/repositories/quran_learning_repository.dart';
import 'elifba_letter_forms.dart';
import 'elifba_models.dart';

class ElifbaRepository {
  ElifbaRepository({
    JsonContentDatasource? datasource,
    QuranLearningRepository? quranLearning,
  })  : _datasource = datasource ?? JsonContentDatasource(),
        _quranLearning = quranLearning;

  final JsonContentDatasource _datasource;
  final QuranLearningRepository? _quranLearning;
  ElifbaPack? _cache;

  Future<ElifbaPack> load() async {
    if (_cache != null) return _cache!;
    final json = await _datasource.loadObject(
      key: 'elifbaTecvid',
      fallbackPath: AssetPaths.elifbaTecvid,
    );
    _cache = ElifbaPack.fromJson(json, extras: await _extraLessons());
    return _cache!;
  }

  /// Kur'an Öğrenme Serisi'nden alınan ek dersler; içerik JSON'u değişse de
  /// korunurlar. Seri yüklenemezse macera JSON'u tek başına çalışır.
  Future<List<ElifbaExtraLesson>> _extraLessons() async {
    final repository = _quranLearning;
    if (repository == null) return const [];
    try {
      final pack = await repository.load();
      final lesson = ElifbaLetterFormsLesson.build(pack);
      if (lesson == null) return const [];
      return [ElifbaExtraLesson(afterLessonId: 1, json: lesson)];
    } catch (_) {
      return const [];
    }
  }
}
