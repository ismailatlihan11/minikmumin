import '../../app/constants/asset_paths.dart';
import '../../core/utils/daily_seed.dart';
import '../../core/utils/json_map.dart';
import '../datasources/json_content_datasource.dart';
import '../models/prophet.dart';
import '../models/lessons.dart';
import '../models/quiz.dart';
import '../models/interactive_lesson.dart';
import '../models/progress.dart';
import '../models/story.dart';

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
    final parsed = rows.map(Prophet.fromJson).toList();
    parsed.sort((a, b) => a.order.compareTo(b.order));
    _cache = List<Prophet>.unmodifiable(parsed);
    return _cache!;
  }
}

class MoralityCatalog {
  const MoralityCatalog({
    required this.categories,
    required this.lessons,
    required this.quiz,
  });

  final List<MoralityCategory> categories;
  final List<MoralityLesson> lessons;
  final List<QuizQuestion> quiz;

  List<MoralityLesson> lessonsFor(String categoryId) {
    return lessons.where((lesson) => lesson.category == categoryId).toList(growable: false);
  }
}

class MoralityRepository {
  MoralityRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  MoralityCatalog? _catalog;

  Future<MoralityCatalog> load() async {
    if (_catalog != null) return _catalog!;
    final json = await _datasource.loadObject(
      key: 'morality',
      fallbackPath: AssetPaths.morality,
    );
    final categoryRows = JsonMap.extractList(json, itemsKey: 'categories');
    final categories = <MoralityCategory>[];
    for (var i = 0; i < categoryRows.length; i++) {
      categories.add(MoralityCategory.fromJson(categoryRows[i], order: i + 1));
    }
    categories.sort((a, b) => a.order.compareTo(b.order));
    final lessons = JsonMap.extractList(json, itemsKey: 'items')
        .map(MoralityLesson.fromJson)
        .toList();
    lessons.sort((a, b) => a.order.compareTo(b.order));
    final quiz = JsonMap.extractList(json, itemsKey: 'quiz')
        .map(QuizQuestion.fromJson)
        .toList(growable: false);
    _catalog = MoralityCatalog(
      categories: List<MoralityCategory>.unmodifiable(categories),
      lessons: List<MoralityLesson>.unmodifiable(lessons),
      quiz: quiz,
    );
    return _catalog!;
  }

  Future<List<MoralityLesson>> getAll() async => (await load()).lessons;
}

class IlmihalCatalog {
  const IlmihalCatalog({
    required this.categories,
    required this.lessons,
    required this.quiz,
  });

  final List<IlmihalCategory> categories;
  final List<IlmihalLesson> lessons;
  final List<QuizQuestion> quiz;

  List<IlmihalLesson> lessonsFor(String categoryId) {
    return lessons.where((lesson) => lesson.category == categoryId).toList(growable: false);
  }
}

class IlmihalRepository {
  IlmihalRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  IlmihalCatalog? _catalog;

  Future<IlmihalCatalog> load() async {
    if (_catalog != null) return _catalog!;
    final json = await _datasource.loadObject(
      key: 'ilmihal',
      fallbackPath: AssetPaths.ilmihal,
    );
    final categories = JsonMap.extractList(json, itemsKey: 'categories')
        .map(IlmihalCategory.fromJson)
        .toList();
    categories.sort((a, b) => a.order.compareTo(b.order));
    final lessons = JsonMap.extractList(json, itemsKey: 'lessons')
        .map(IlmihalLesson.fromJson)
        .toList();
    lessons.sort((a, b) => a.order.compareTo(b.order));
    final quiz = JsonMap.extractList(json, itemsKey: 'quiz')
        .map(QuizQuestion.fromJson)
        .toList(growable: false);
    _catalog = IlmihalCatalog(
      categories: List<IlmihalCategory>.unmodifiable(categories),
      lessons: List<IlmihalLesson>.unmodifiable(lessons),
      quiz: quiz,
    );
    return _catalog!;
  }

  Future<List<IlmihalLesson>> getAll() async => (await load()).lessons;
}

class QuizRepository {
  QuizRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  QuizBank? _bank;

  Future<QuizBank> load() async {
    if (_bank != null) return _bank!;
    final json = await _datasource.loadObject(
      key: 'quiz',
      fallbackPath: AssetPaths.quiz,
    );
    final algorithm = JsonMap.object(json['quizAlgorithm']);
    final feedback = JsonMap.object(json['feedback']);
    final questions = JsonMap.extractList(json, itemsKey: 'questions')
        .map(QuizQuestion.fromJson)
        .toList(growable: false);
    _bank = QuizBank(
      title: JsonMap.str(json['title'], 'Mini Testler'),
      categories: JsonMap.strings(json['categories']),
      questions: questions,
      questionsPerSession: JsonMap.integer(algorithm['questionsPerSession'], 10),
      correctFeedback: JsonMap.strings(feedback['correct']),
      wrongFeedback: JsonMap.strings(feedback['wrong']),
    );
    return _bank!;
  }

  Future<List<QuizQuestion>> getAll() async => (await load()).questions;
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

class StoryRepository {
  StoryRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  StoryCatalog? _catalog;

  Future<StoryCatalog> load() async {
    if (_catalog != null) return _catalog!;
    final json = await _datasource.loadObject(
      key: 'stories',
      fallbackPath: AssetPaths.stories,
    );
    final categories = JsonMap.extractList(json, itemsKey: 'categories')
        .map(StoryCategory.fromJson)
        .toList(growable: false);
    final items = JsonMap.extractList(json, itemsKey: 'items')
        .map(StoryItem.fromJson)
        .toList();
    items.sort((a, b) => a.order.compareTo(b.order));
    _catalog = StoryCatalog(
      categories: categories,
      items: List<StoryItem>.unmodifiable(items),
    );
    return _catalog!;
  }

  Future<StoryItem?> getById(String id) async {
    final catalog = await load();
    for (final item in catalog.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<StoryItem?> getDaily({DateTime? now}) async {
    final catalog = await load();
    if (catalog.items.isEmpty) return null;
    return pickDaily(catalog.items, now: now);
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
