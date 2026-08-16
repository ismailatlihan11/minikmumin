import '../../app/constants/asset_paths.dart';
import '../datasources/json_content_datasource.dart';
import '../models/prophet.dart';
import '../models/lessons.dart';
import '../models/quiz.dart';
import '../models/interactive_lesson.dart';
import '../models/progress.dart';

class ProphetRepository {
  ProphetRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Prophet>? _cache;

  Future<List<Prophet>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'prophets',
      fallbackPath: AssetPaths.prophets,
    );
    _cache = rows.map(Prophet.fromJson).toList(growable: false);
    return _cache!;
  }
}

class MoralityRepository {
  MoralityRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<MoralityLesson>? _cache;

  Future<List<MoralityLesson>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'morality',
      fallbackPath: AssetPaths.morality,
    );
    _cache = rows.map(MoralityLesson.fromJson).toList(growable: false);
    return _cache!;
  }
}

class IlmihalRepository {
  IlmihalRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<IlmihalLesson>? _cache;

  Future<List<IlmihalLesson>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'ilmihal',
      fallbackPath: AssetPaths.ilmihal,
    );
    _cache = rows.map(IlmihalLesson.fromJson).toList(growable: false);
    return _cache!;
  }
}

class QuizRepository {
  QuizRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<QuizQuestion>? _cache;

  Future<List<QuizQuestion>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'quiz',
      fallbackPath: AssetPaths.quiz,
    );
    _cache = rows.map(QuizQuestion.fromJson).toList(growable: false);
    return _cache!;
  }
}

class WuduRepository {
  WuduRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  WuduLesson? _cache;

  Future<WuduLesson> getLesson() async {
    if (_cache != null) return _cache!;
    final json = await _datasource.loadObject(
      key: 'wudu',
      fallbackPath: AssetPaths.wudu,
    );
    _cache = WuduLesson.fromJson(json);
    return _cache!;
  }
}

class PrayerRepository {
  PrayerRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  PrayerLesson? _cache;

  Future<PrayerLesson> getLesson() async {
    if (_cache != null) return _cache!;
    final json = await _datasource.loadObject(
      key: 'prayer',
      fallbackPath: AssetPaths.prayer,
    );
    _cache = PrayerLesson.fromJson(json);
    return _cache!;
  }
}

class AchievementRepository {
  AchievementRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Achievement>? _cache;

  Future<List<Achievement>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _datasource.loadList(
      key: 'achievements',
      fallbackPath: AssetPaths.achievements,
    );
    _cache = rows.map(Achievement.fromJson).toList(growable: false);
    return _cache!;
  }
}
