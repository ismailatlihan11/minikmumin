import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants/app_constants.dart';

class WuduProgress {
  const WuduProgress({
    required this.stepIndex,
    required this.completed,
    required this.started,
  });

  final int stepIndex;
  final bool completed;
  final bool started;

  bool get inProgress => started && !completed;
}

class ContinuePoint {
  const ContinuePoint({
    required this.title,
    required this.subtitle,
    required this.route,
    this.progress = 0,
  });

  final String title;
  final String subtitle;
  final String route;
  final double progress;
}

class FavoriteEntry {
  const FavoriteEntry({
    required this.kind,
    required this.id,
    required this.title,
  });

  final String kind;
  final String id;
  final String title;

  String get key => '$kind|$id';

  Map<String, String> toMap() => {
        'kind': kind,
        'id': id,
        'title': title,
      };

  factory FavoriteEntry.fromMap(Map<String, dynamic> map) {
    return FavoriteEntry(
      kind: map['kind']?.toString() ?? '',
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
    );
  }
}

class LocalProgressStore extends ChangeNotifier {
  LocalProgressStore({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  String _key(String name) => '${AppConstants.progressPrefix}$name';

  Future<bool> getOnboardingDone() async {
    final prefs = await _ensure();
    return prefs.getBool(_key('onboarding_done')) ?? false;
  }

  Future<void> setOnboardingDone({bool value = true}) async {
    final prefs = await _ensure();
    await prefs.setBool(_key('onboarding_done'), value);
    notifyListeners();
  }

  Future<int> getXp() async {
    final prefs = await _ensure();
    return prefs.getInt(_key('xp')) ?? 0;
  }

  Future<void> addXp(int value) async {
    if (value <= 0) return;
    final prefs = await _ensure();
    final current = prefs.getInt(_key('xp')) ?? 0;
    await prefs.setInt(_key('xp'), current + value);
    notifyListeners();
  }

  Future<String?> getNickname() async {
    final prefs = await _ensure();
    return prefs.getString(_key('nickname'));
  }

  Future<void> setNickname(String value) async {
    final prefs = await _ensure();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(_key('nickname'));
    } else {
      await prefs.setString(_key('nickname'), trimmed);
    }
    notifyListeners();
  }

  Future<bool> getPrayerGirlLearner() async {
    final prefs = await _ensure();
    return prefs.getString(_key('prayer_learner')) == 'girl';
  }

  Future<void> setPrayerGirlLearner(bool girl) async {
    final prefs = await _ensure();
    await prefs.setString(_key('prayer_learner'), girl ? 'girl' : 'boy');
    notifyListeners();
  }

  Future<WuduProgress> getWuduProgress() async {
    final prefs = await _ensure();
    return WuduProgress(
      stepIndex: prefs.getInt(_key('wudu_step')) ?? 0,
      completed: prefs.getBool(_key('wudu_completed')) ?? false,
      started: prefs.getBool(_key('wudu_started')) ?? false,
    );
  }

  Future<void> saveWuduStep(int index) async {
    final prefs = await _ensure();
    await prefs.setBool(_key('wudu_started'), true);
    await prefs.setInt(_key('wudu_step'), index);
    await prefs.setBool(_key('wudu_completed'), false);
    await setContinue(
      title: 'Abdesti Öğren',
      subtitle: '${index + 1}. adım',
      route: '/minik/learn/wudu',
      progress: ((index + 1) / 13).clamp(0, 1),
    );
  }

  Future<void> markWuduCompleted() async {
    final prefs = await _ensure();
    await prefs.setBool(_key('wudu_started'), true);
    await prefs.setBool(_key('wudu_completed'), true);
    await _addUnique(_key('completed_lessons'), 'wudu');
    await _addUnique(_key('badges'), 'first_lesson');
    await setContinue(
      title: 'Namazı Öğren',
      subtitle: 'Sıradaki ders',
      route: '/minik/learn/prayer',
      progress: 0,
    );
  }

  Future<void> resetWudu() async {
    final prefs = await _ensure();
    await prefs.setInt(_key('wudu_step'), 0);
    await prefs.setBool(_key('wudu_completed'), false);
    await prefs.setBool(_key('wudu_started'), false);
    notifyListeners();
  }

  Future<List<String>> getCompletedLessons() async {
    final prefs = await _ensure();
    return prefs.getStringList(_key('completed_lessons')) ?? const [];
  }

  Future<List<String>> getBadges() async {
    final prefs = await _ensure();
    return prefs.getStringList(_key('badges')) ?? const [];
  }

  Future<void> markCompleted(
    String kind,
    String id, {
    int xp = 0,
    String? badge,
  }) async {
    final already = await isCompleted(kind, id);
    if (already) return;
    await _addUnique(_key('completed_items'), '$kind|$id');
    await _addUnique(_key('completed_lessons'), kind);
    if (badge != null && badge.isNotEmpty) {
      await _addUnique(_key('badges'), badge);
    }
    if (kind == 'dua' || kind == 'prayer_dua') {
      await _addUnique(_key('badges'), 'first_dua');
    }
    if (kind == 'prayer_dua') {
      final items = await getCompletedItems();
      final count = items.where((item) => item.startsWith('prayer_dua|')).length;
      if (count >= 5) await _addUnique(_key('badges'), 'prayer_duas');
    }
    if (kind == 'story') await _addUnique(_key('badges'), 'first_lesson');
    if (kind == 'morality') await _addUnique(_key('badges'), 'good_manners');
    if (kind == 'quran') await _addUnique(_key('badges'), 'quran_reader');
    if (kind.startsWith('ql_')) await noteQuranLearnDay();
    if (xp > 0) await addXp(xp);
    notifyListeners();
  }

  Future<bool> isCompleted(String kind, String id) async {
    final items = await getCompletedItems();
    return items.contains('$kind|$id');
  }

  Future<List<String>> getCompletedItems() async {
    final prefs = await _ensure();
    return prefs.getStringList(_key('completed_items')) ?? const [];
  }

  Future<void> setContinue({
    required String title,
    required String subtitle,
    required String route,
    double progress = 0,
  }) async {
    final prefs = await _ensure();
    await prefs.setString(_key('continue_title'), title);
    await prefs.setString(_key('continue_subtitle'), subtitle);
    await prefs.setString(_key('continue_route'), route);
    await prefs.setDouble(_key('continue_progress'), progress.clamp(0, 1));
    notifyListeners();
  }

  Future<ContinuePoint?> getContinue() async {
    final prefs = await _ensure();
    final route = prefs.getString(_key('continue_route'));
    if (route == null || route.isEmpty) return null;
    return ContinuePoint(
      title: prefs.getString(_key('continue_title')) ?? 'Öğrenmeye Devam Et',
      subtitle: prefs.getString(_key('continue_subtitle')) ?? '',
      route: route,
      progress: prefs.getDouble(_key('continue_progress')) ?? 0,
    );
  }

  Future<void> setStoryPage(String id, int page) async {
    final prefs = await _ensure();
    await prefs.setInt(_key('story_page_$id'), page);
  }

  Future<int> getStoryPage(String id) async {
    final prefs = await _ensure();
    return prefs.getInt(_key('story_page_$id')) ?? 0;
  }

  Future<void> setBookBookmark({
    required String bookId,
    required int page,
    required String title,
    required int totalPages,
  }) async {
    final prefs = await _ensure();
    await prefs.setInt(_key('book_page_$bookId'), page);
    await setContinue(
      title: 'Kaldığın yerden devam et',
      subtitle: '$page. sayfa · $title',
      route: '/minik/learn/prophets-book/read',
      progress: (page / (totalPages <= 0 ? 1 : totalPages)).clamp(0, 1),
    );
  }

  Future<int?> getBookBookmark(String bookId) async {
    final prefs = await _ensure();
    if (!prefs.containsKey(_key('book_page_$bookId'))) return null;
    return prefs.getInt(_key('book_page_$bookId'));
  }

  Future<void> rememberMushafPage({
    required int jsonPage,
    required int displayNumber,
    required String surahLabel,
  }) async {
    final prefs = await _ensure();
    await prefs.setInt(_key('mushaf_page'), jsonPage);
    await prefs.setInt(_key('mushaf_display'), displayNumber);
    await prefs.setString(_key('mushaf_surah'), surahLabel);
    notifyListeners();
  }

  Future<void> setMushafBookmark({
    required int jsonPage,
    required int displayNumber,
    required String surahLabel,
    int totalPages = 604,
  }) async {
    await rememberMushafPage(
      jsonPage: jsonPage,
      displayNumber: displayNumber,
      surahLabel: surahLabel,
    );
    await setContinue(
      title: 'Kaldığın yerden devam et',
      subtitle: '$displayNumber. sayfa · $surahLabel',
      route: '/minik/quran/reader',
      progress: (displayNumber / (totalPages <= 0 ? 1 : totalPages)).clamp(0, 1),
    );
  }

  Future<int?> getMushafBookmark() async {
    final prefs = await _ensure();
    if (!prefs.containsKey(_key('mushaf_page'))) return null;
    return prefs.getInt(_key('mushaf_page'));
  }

  Future<({int jsonPage, int displayNumber, String surahLabel})?>
      getMushafBookmarkInfo() async {
    final prefs = await _ensure();
    if (!prefs.containsKey(_key('mushaf_page'))) return null;
    return (
      jsonPage: prefs.getInt(_key('mushaf_page')) ?? 0,
      displayNumber: prefs.getInt(_key('mushaf_display')) ?? 1,
      surahLabel: prefs.getString(_key('mushaf_surah')) ?? '',
    );
  }

  static const mushafFontMin = 16.0;
  static const mushafFontMax = 34.0;
  static const mushafFontDefault = 24.0;

  Future<double> getMushafFontSize() async {
    final prefs = await _ensure();
    return (prefs.getDouble(_key('mushaf_font')) ?? mushafFontDefault)
        .clamp(mushafFontMin, mushafFontMax);
  }

  Future<void> setMushafFontSize(double size) async {
    final prefs = await _ensure();
    await prefs.setDouble(
      _key('mushaf_font'),
      size.clamp(mushafFontMin, mushafFontMax),
    );
  }

  Future<bool> getMushafFingerFollow() async {
    final prefs = await _ensure();
    return prefs.getBool(_key('mushaf_follow')) ?? false;
  }

  Future<void> setMushafFingerFollow(bool on) async {
    final prefs = await _ensure();
    await prefs.setBool(_key('mushaf_follow'), on);
  }

  Future<List<FavoriteEntry>> getFavorites() async {
    final prefs = await _ensure();
    final raw = prefs.getString(_key('favorites_json')) ?? '[]';
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => FavoriteEntry.fromMap(Map<String, dynamic>.from(item)))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<bool> isFavorite(String kind, String id) async {
    final items = await getFavorites();
    return items.any((item) => item.kind == kind && item.id == id);
  }

  Future<void> toggleFavorite(FavoriteEntry entry) async {
    final prefs = await _ensure();
    final current = List<FavoriteEntry>.from(await getFavorites());
    final exists = current.any((item) => item.key == entry.key);
    if (exists) {
      current.removeWhere((item) => item.key == entry.key);
    } else {
      current.add(entry);
    }
    await prefs.setString(
      _key('favorites_json'),
      jsonEncode(current.map((item) => item.toMap()).toList()),
    );
    notifyListeners();
  }

  Future<int> getCounter(String name) async {
    final prefs = await _ensure();
    return prefs.getInt(_key(name)) ?? 0;
  }

  Future<int> addCounter(String name, [int amount = 1]) async {
    if (amount == 0) return getCounter(name);
    final prefs = await _ensure();
    final next = (prefs.getInt(_key(name)) ?? 0) + amount;
    await prefs.setInt(_key(name), next < 0 ? 0 : next);
    notifyListeners();
    return next;
  }

  Future<void> setCounter(String name, int value) async {
    final prefs = await _ensure();
    await prefs.setInt(_key(name), value < 0 ? 0 : value);
    notifyListeners();
  }

  Future<bool> getFlag(String name, {bool fallback = false}) async {
    final prefs = await _ensure();
    return prefs.getBool(_key(name)) ?? fallback;
  }

  Future<void> setFlag(String name, bool value) async {
    final prefs = await _ensure();
    await prefs.setBool(_key(name), value);
    notifyListeners();
  }

  Future<void> awardBadge(String id) async {
    if (id.trim().isEmpty) return;
    await _addUnique(_key('badges'), id);
    notifyListeners();
  }

  Future<int> getQuranLearnStreak() => getCounter('ql_streak');

  Future<void> noteQuranLearnDay() async {
    final prefs = await _ensure();
    final today = DateTime.now();
    final todayKey = today.year * 10000 + today.month * 100 + today.day;
    final last = prefs.getInt(_key('ql_last_day')) ?? 0;
    if (last == todayKey) return;
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey =
        yesterday.year * 10000 + yesterday.month * 100 + yesterday.day;
    final streak = prefs.getInt(_key('ql_streak')) ?? 0;
    final next = last == yesterdayKey ? streak + 1 : 1;
    await prefs.setInt(_key('ql_last_day'), todayKey);
    await prefs.setInt(_key('ql_streak'), next);
    notifyListeners();
  }

  Future<void> _addUnique(String key, String value) async {
    final prefs = await _ensure();
    final current = List<String>.from(prefs.getStringList(key) ?? const []);
    if (current.contains(value)) return;
    current.add(value);
    await prefs.setStringList(key, current);
  }
}
