import '../../app/constants/asset_paths.dart';
import '../../data/datasources/json_content_datasource.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/quran_learning_repository.dart';
import 'elifba_cezm_examples.dart';
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
    final source = await _quranPack();
    _cache = ElifbaPack.fromJson(
      json,
      extras: _extraLessons(source),
      patches: _patches(source),
      hiddenTitles: const {ElifbaLetterFormsLesson.replacesTitle},
    );
    return _cache!;
  }

  Future<QuranLearningPack?> _quranPack() async {
    final repository = _quranLearning;
    if (repository == null) return null;
    try {
      return await repository.load();
    } catch (_) {
      return null;
    }
  }

  /// Cezm dersi macera JSON'unda yalnızca birkaç örnek içeriyor; Kur'an
  /// serisindeki sâkin harfler ve gerçek kelimelerle zenginleştirilir.
  List<ElifbaLessonPatch> _patches(QuranLearningPack? pack) {
    final cezm = ElifbaCezmExamples.build(pack);
    return [
      if (cezm != null)
        ElifbaLessonPatch(
          titleContains: ElifbaCezmExamples.lessonTitleContains,
          content: cezm,
        ),
    ];
  }

  /// Kur'an Öğrenme Serisi'nden alınan ek dersler; içerik JSON'u değişse de
  /// korunurlar. Seri yüklenemezse macera JSON'u tek başına çalışır.
  List<ElifbaExtraLesson> _extraLessons(QuranLearningPack? pack) {
    final lesson = ElifbaLetterFormsLesson.build(pack);
    if (lesson == null) return const [];
    return [ElifbaExtraLesson(afterLessonId: 1, json: lesson)];
  }
}
