import 'dart:convert';

import '../../core/storage/local_progress_store.dart';

class ElifbaSnapshot {
  const ElifbaSnapshot({
    required this.completedLessons,
    required this.startedLessons,
    required this.currentLesson,
    required this.stars,
    required this.badges,
    required this.quizResults,
    required this.unlockAll,
    required this.dailyDone,
    required this.dailyStamp,
  });

  final Set<int> completedLessons;
  final Set<int> startedLessons;
  final int currentLesson;
  final int stars;
  final Set<String> badges;
  final Map<String, int> quizResults;
  final bool unlockAll;
  final bool dailyDone;
  final String dailyStamp;

  bool isCompleted(int id) => completedLessons.contains(id);

  bool isStarted(int id) => startedLessons.contains(id) || isCompleted(id);

  bool isInProgress(int id) => isStarted(id) && !isCompleted(id);

  bool isUnlocked(int id) {
    if (unlockAll || id <= 1) return true;
    return completedLessons.contains(id - 1);
  }

  int get doneCount => completedLessons.length;

  double ratio(int total) => total <= 0 ? 0 : (doneCount / total).clamp(0, 1);
}

class ElifbaProgress {
  ElifbaProgress(this._store);

  final LocalProgressStore _store;

  static const completedKey = 'elifba_completed_lessons';
  static const startedKey = 'elifba_started_lessons';
  static const progressMapKey = 'elifba_progress';
  static const currentKey = 'elifba_current_lesson';
  static const starsKey = 'elifba_stars';
  static const badgesKey = 'elifba_badges';
  static const quizKey = 'elifba_quiz_results';
  static const unlockKey = 'elifba_unlock_all';
  static const dailyStampKey = 'elifba_daily_stamp';
  static const dailyDoneKey = 'elifba_daily_done';

  Future<ElifbaSnapshot> load() async {
    final prefs = await _store.prefs;
    final today = _todayStamp();
    final stamp = prefs.getString(_store.prefKey(dailyStampKey)) ?? '';
    final dailyDone = stamp == today &&
        (prefs.getBool(_store.prefKey(dailyDoneKey)) ?? false);
    return ElifbaSnapshot(
      completedLessons: {
        for (final item
            in prefs.getStringList(_store.prefKey(completedKey)) ?? const [])
          int.tryParse(item) ?? 0,
      }..remove(0),
      startedLessons: {
        for (final item
            in prefs.getStringList(_store.prefKey(startedKey)) ?? const [])
          int.tryParse(item) ?? 0,
      }..remove(0),
      currentLesson: prefs.getInt(_store.prefKey(currentKey)) ?? 1,
      stars: prefs.getInt(_store.prefKey(starsKey)) ?? 0,
      badges: {
        ...prefs.getStringList(_store.prefKey(badgesKey)) ?? const [],
      },
      quizResults: _decodeQuiz(prefs.getString(_store.prefKey(quizKey))),
      unlockAll: prefs.getBool(_store.prefKey(unlockKey)) ?? false,
      dailyDone: dailyDone,
      dailyStamp: today,
    );
  }

  Future<void> setCurrent(int lessonId) async {
    final prefs = await _store.prefs;
    await prefs.setInt(_store.prefKey(currentKey), lessonId);
    _store.announce();
  }

  Future<void> markStarted(int lessonId) async {
    final snap = await load();
    if (snap.isStarted(lessonId)) {
      await setCurrent(lessonId);
      await _writeProgressMap(
        started: snap.startedLessons,
        completed: snap.completedLessons,
        current: lessonId,
      );
      return;
    }
    final prefs = await _store.prefs;
    final started = {
      ...snap.startedLessons.map((id) => '$id'),
      '$lessonId',
    }.toList()
      ..sort();
    await prefs.setStringList(_store.prefKey(startedKey), started);
    await prefs.setInt(_store.prefKey(currentKey), lessonId);
    await _writeProgressMap(
      started: {...snap.startedLessons, lessonId},
      completed: snap.completedLessons,
      current: lessonId,
    );
    _store.announce();
  }

  Future<void> completeLesson({
    required int lessonId,
    required int starsEarned,
    required int quizCorrect,
    String? badge,
  }) async {
    final snap = await load();
    final prefs = await _store.prefs;
    final done = {
      ...snap.completedLessons.map((id) => '$id'),
      '$lessonId',
    }.toList()
      ..sort();
    final started = {
      ...snap.startedLessons.map((id) => '$id'),
      '$lessonId',
    }.toList()
      ..sort();
    await prefs.setStringList(_store.prefKey(completedKey), done);
    await prefs.setStringList(_store.prefKey(startedKey), started);
    await prefs.setInt(_store.prefKey(starsKey), snap.stars + starsEarned);
    final quiz = Map<String, int>.from(snap.quizResults)
      ..['$lessonId'] = quizCorrect;
    await prefs.setString(_store.prefKey(quizKey), jsonEncode(quiz));
    if (badge != null && badge.isNotEmpty) {
      final badges = {...snap.badges, badge}.toList();
      await prefs.setStringList(_store.prefKey(badgesKey), badges);
    }
    await prefs.setInt(_store.prefKey(currentKey), lessonId + 1);
    await prefs.setString(_store.prefKey(dailyStampKey), _todayStamp());
    await prefs.setBool(_store.prefKey(dailyDoneKey), true);
    await _store.setContinue(
      title: 'Elifbâ + Tecvid Macerası',
      subtitle: 'Ders $lessonId tamamlandı',
      route: '/minik/learn/elifba-adventure',
      progress: 0,
    );
    await _writeProgressMap(
      started: {...snap.startedLessons, lessonId},
      completed: {...snap.completedLessons, lessonId},
      current: lessonId + 1,
    );
    _store.announce();
  }

  Future<void> addStars(int amount) async {
    if (amount <= 0) return;
    final snap = await load();
    final prefs = await _store.prefs;
    await prefs.setInt(_store.prefKey(starsKey), snap.stars + amount);
    _store.announce();
  }

  Future<void> grantBadge(String badge) async {
    final snap = await load();
    final prefs = await _store.prefs;
    await prefs.setStringList(
      _store.prefKey(badgesKey),
      {...snap.badges, badge}.toList(),
    );
    _store.announce();
  }

  Future<void> setUnlockAll(bool value) async {
    final prefs = await _store.prefs;
    await prefs.setBool(_store.prefKey(unlockKey), value);
    _store.announce();
  }

  Future<void> reset() async {
    final prefs = await _store.prefs;
    for (final key in [
      completedKey,
      startedKey,
      progressMapKey,
      currentKey,
      starsKey,
      badgesKey,
      quizKey,
      unlockKey,
      dailyStampKey,
      dailyDoneKey,
    ]) {
      await prefs.remove(_store.prefKey(key));
    }
    _store.announce();
  }

  Future<void> _writeProgressMap({
    required Set<int> started,
    required Set<int> completed,
    required int current,
  }) async {
    final prefs = await _store.prefs;
    final map = <String, String>{
      for (final id in {...started, ...completed})
        '$id': completed.contains(id)
            ? 'tamamlandı'
            : (id == current ? 'devam ediyor' : 'başladı'),
    };
    await prefs.setString(_store.prefKey(progressMapKey), jsonEncode(map));
  }

  Map<String, int> _decodeQuiz(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          '${entry.key}': int.tryParse('${entry.value}') ?? 0,
      };
    } catch (_) {
      return const {};
    }
  }

  String _todayStamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
