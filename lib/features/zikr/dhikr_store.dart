import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/dhikr.dart';
import '../../data/repositories/dhikr_repository.dart';
import 'dhikr_feedback.dart';
import 'dhikr_logic.dart';
import 'dhikr_persistence.dart';

class DhikrStore extends ChangeNotifier {
  DhikrStore({
    DhikrRepository? repository,
    DhikrPersistenceService? persistence,
    DhikrFeedbackService? feedback,
  })  : _repository = repository ?? DhikrRepository(),
        _persistence = persistence ?? DhikrPersistenceService(),
        _feedback = feedback ?? DhikrFeedbackService();

  final DhikrRepository _repository;
  final DhikrPersistenceService _persistence;
  final DhikrFeedbackService _feedback;

  List<Dhikr> _items = const [];
  List<DhikrSession> _sessions = const [];
  List<DhikrDailyStat> _stats = const [];
  DhikrSettings _settings = const DhikrSettings();
  DhikrAssetManifest _manifest = DhikrAssetManifest.empty;
  String? _lastUsedId;
  bool _ready = false;
  Future<void> _persistWork = Future.value();

  @visibleForTesting
  void debugSetItems(List<Dhikr> items) {
    _items = List<Dhikr>.from(items);
    _ready = true;
  }

  bool get ready => _ready;
  List<Dhikr> get items => _items;
  List<DhikrSession> get sessions => _sessions;
  DhikrSettings get settings => _settings;
  DhikrAssetManifest get manifest => _manifest;

  Dhikr? get lastUsed {
    final id = _lastUsedId;
    if (id == null) return null;
    return byId(id);
  }

  Dhikr? get paused {
    for (final item in _items) {
      if (item.isPaused && item.currentCount > 0 && item.currentCount < item.targetCount) {
        return item;
      }
    }
    return lastUsed != null &&
            lastUsed!.currentCount > 0 &&
            lastUsed!.currentCount < lastUsed!.targetCount
        ? lastUsed
        : null;
  }

  List<Dhikr> get favorites =>
      _items.where((item) => item.isFavorite).toList(growable: false);

  List<Dhikr> get pausedItems => _items
      .where((item) => item.isPaused && item.currentCount > 0 && item.currentCount < item.targetCount)
      .toList(growable: false);

  List<Dhikr> get completedItems =>
      _items.where((item) => item.isCompleted).toList(growable: false);

  List<Dhikr> get recentlyUsed {
    final used = _items.where((item) => item.lastUsedAt != null).toList();
    used.sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));
    return used;
  }

  Dhikr? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  String imageFor(Dhikr dhikr) => _manifest.imageFor(dhikr);

  String audioFor(Dhikr dhikr) => _manifest.audioFor(dhikr);

  int todayCompletedCount(String dhikrId, [DateTime? now]) {
    final today = DhikrStatsService.dateKey(now ?? DateTime.now());
    return _sessions
        .where((session) =>
            session.dhikrId == dhikrId &&
            DhikrStatsService.dateKey(session.completedAt) == today)
        .length;
  }

  DhikrOverview overview([DateTime? now]) {
    return DhikrStatsService.overview(
      items: _items,
      stats: _stats,
      now: now,
    );
  }

  Future<void> restore() async {
    try {
      final catalog = await _repository.loadCatalog();
      _manifest = await _repository.loadManifest();
      final saved = await _persistence.loadItems();
      _items = _repository.merge(catalog: catalog, saved: saved);
      _sessions = await _persistence.loadSessions();
      _stats = await _persistence.loadDailyStats();
      _settings = await _persistence.loadSettings();
      _lastUsedId = await _persistence.loadLastUsedId();
      final favoriteIds = {
        for (final item in await _persistence.loadFavorites()) item.dhikrId,
      };
      if (favoriteIds.isNotEmpty) {
        _items = [
          for (final item in _items)
            item.copyWith(isFavorite: item.isFavorite || favoriteIds.contains(item.id)),
        ];
      }
    } catch (_) {
      _items = const [];
    }
    _ready = true;
    notifyListeners();
    unawaited(_feedback.preload(_manifest.click));
  }

  Future<void> warmupClick() => _feedback.preload(_manifest.click);

  Future<DhikrTapResult> addCount(String id, {int? step, DateTime? now}) {
    return _changeCount(id, delta: step ?? byId(id)?.incrementStep ?? 1, now: now);
  }

  Future<DhikrTapResult> subtractCount(String id, {int? step, DateTime? now}) {
    return _changeCount(
      id,
      delta: -(step ?? byId(id)?.incrementStep ?? 1),
      now: now,
    );
  }

  Future<void> resetCurrent(String id) async {
    final item = byId(id);
    if (item == null) return;
    await _replace(
      item.copyWith(
        currentCount: 0,
        isPaused: false,
        updatedAt: DateTime.now(),
        clearSessionStartedAt: true,
      ),
    );
    await _persistence.saveInProgress(null);
  }

  Future<void> startAgain(String id) async {
    final item = byId(id);
    if (item == null) return;
    await _replace(
      item.copyWith(
        currentCount: 0,
        isPaused: false,
        updatedAt: DateTime.now(),
        sessionStartedAt: DateTime.now(),
      ),
    );
    await _persistence.saveInProgress(null);
  }

  Future<void> pause(String id) async {
    final item = byId(id);
    if (item == null) return;
    if (item.currentCount <= 0 || item.currentCount >= item.targetCount) {
      await _replace(item.copyWith(isPaused: false, updatedAt: DateTime.now()));
      await _persistence.saveInProgress(null);
      return;
    }
    final paused = item.copyWith(isPaused: true, updatedAt: DateTime.now());
    await _replace(paused);
    await _persistence.saveInProgress(
      DhikrProgress(
        dhikrId: paused.id,
        target: paused.targetCount,
        current: paused.currentCount,
        lastUsedAt: paused.lastUsedAt,
        status: 'paused',
      ),
    );
  }

  Future<void> toggleFavorite(String id) async {
    final item = byId(id);
    if (item == null) return;
    final next = item.copyWith(isFavorite: !item.isFavorite, updatedAt: DateTime.now());
    await _replace(next);
    await _persistence.saveFavorites([
      for (final dhikr in _items)
        if (dhikr.isFavorite) DhikrFavorite(dhikrId: dhikr.id),
    ]);
  }

  Future<void> updateSettings(DhikrSettings settings) async {
    _settings = settings;
    await _persistence.saveSettings(settings);
    notifyListeners();
  }

  Future<void> updateDhikr(Dhikr dhikr) async {
    await _replace(dhikr.copyWith(updatedAt: DateTime.now()));
  }

  Future<Dhikr> createCustom({
    required String title,
    String arabic = '',
    String transliteration = '',
    String meaning = '',
    int targetCount = 33,
    int incrementStep = 1,
    int vibrationEvery = 1,
    int soundEvery = 33,
    bool vibrationEnabled = true,
    bool soundEnabled = true,
  }) async {
    final now = DateTime.now();
    final dhikr = Dhikr(
      id: 'custom_${now.millisecondsSinceEpoch}',
      title: title.trim(),
      arabic: arabic.trim(),
      transliteration: transliteration.trim(),
      meaning: meaning.trim(),
      category: 'custom',
      targetCount: targetCount.clamp(1, 100000),
      incrementStep: incrementStep.clamp(1, 1000),
      vibrationEvery: vibrationEvery.clamp(1, 100000),
      soundEvery: soundEvery.clamp(1, 100000),
      vibrationEnabled: vibrationEnabled,
      soundEnabled: soundEnabled,
      createdAt: now,
      updatedAt: now,
      isCustom: true,
    );
    _items = [..._items, dhikr];
    await _persistence.saveItems(_items);
    notifyListeners();
    return dhikr;
  }

  Future<DhikrTapResult> _changeCount(
    String id, {
    required int delta,
    DateTime? now,
  }) async {
    final item = byId(id);
    if (item == null) {
      return const DhikrTapResult(dhikr: Dhikr(id: '', title: ''));
    }
    final stamp = now ?? DateTime.now();
    final today = DhikrStatsService.dateKey(stamp);
    final previous = item.currentCount;
    final current = delta >= 0
        ? DhikrCounterService.increment(previous, delta)
        : DhikrCounterService.decrement(previous, -delta);
    final added = current - previous;
    var dailyCount = item.dailyCount;
    if (item.dailyDate != today) dailyCount = 0;
    dailyCount += added > 0 ? added : 0;
    final completed = added > 0 &&
        DhikrCounterService.justCompleted(
          previous: previous,
          current: current,
          target: item.targetCount,
        );
    DhikrSession? session;
    var next = item.copyWith(
      currentCount: current,
      totalCount: added > 0 ? item.totalCount + added : item.totalCount,
      dailyCount: dailyCount,
      dailyDate: today,
      isPaused: current > 0 && current < item.targetCount,
      isCompleted: item.isCompleted || completed,
      lastUsedAt: stamp,
      updatedAt: stamp,
      sessionStartedAt: item.sessionStartedAt ?? stamp,
    );
    if (completed) {
      final started = item.sessionStartedAt ?? stamp;
      session = DhikrSession(
        id: 'session_${stamp.microsecondsSinceEpoch}',
        dhikrId: item.id,
        target: item.targetCount,
        completedAt: stamp,
        count: item.targetCount,
        durationSeconds: stamp.difference(started).inSeconds.clamp(0, 86400),
      );
      _sessions = [..._sessions, session];
    }
    if (added != 0) {
      _bumpDailyStat(
        dhikrId: item.id,
        date: today,
        count: added > 0 ? added : 0,
        completed: completed ? 1 : 0,
      );
    }
    final canVibrate = added > 0 &&
        _settings.vibrationEnabled &&
        next.vibrationEnabled;
    final milestone = canVibrate &&
        DhikrCounterService.shouldPulse(current, next.vibrationEvery);
    final click = added > 0 && _settings.soundEnabled && next.soundEnabled;
    if (click) {
      unawaited(_feedback.playClick(_manifest.click));
    }
    if (completed) {
      unawaited(_feedback.playClick(_manifest.complete));
    }
    if (canVibrate || completed) {
      unawaited(_feedback.vibrate(
        _settings,
        accent: milestone || completed,
      ));
    }

    _items = [
      for (final existing in _items)
        if (existing.id == next.id) next else existing,
    ];
    _lastUsedId = item.id;
    notifyListeners();
    unawaited(_enqueuePersist());
    return DhikrTapResult(
      dhikr: next,
      vibrated: canVibrate || completed,
      sounded: click || completed,
      completed: completed,
      session: session,
    );
  }

  Future<void> _enqueuePersist() {
    final done = Completer<void>();
    _persistWork = _persistWork.then((_) async {
      await _persistence.saveItems(_items);
      await _persistence.saveSessions(_sessions);
      await _persistence.saveDailyStats(_stats);
      final id = _lastUsedId;
      if (id != null) await _persistence.saveLastUsedId(id);
      final current = id == null ? null : byId(id);
      await _persistence.saveInProgress(
        current != null && current.isPaused
            ? DhikrProgress(
                dhikrId: current.id,
                target: current.targetCount,
                current: current.currentCount,
                lastUsedAt: current.lastUsedAt,
                status: 'paused',
              )
            : null,
      );
      if (!done.isCompleted) done.complete();
    }).catchError((Object error, StackTrace stack) {
      if (!done.isCompleted) done.completeError(error, stack);
    });
    return done.future;
  }

  void _bumpDailyStat({
    required String dhikrId,
    required String date,
    required int count,
    required int completed,
  }) {
    final index = _stats.indexWhere(
      (stat) => stat.dhikrId == dhikrId && stat.date == date,
    );
    if (index < 0) {
      _stats = [
        ..._stats,
        DhikrDailyStat(
          date: date,
          dhikrId: dhikrId,
          count: count,
          completedSessions: completed,
        ),
      ];
      return;
    }
    final current = _stats[index];
    _stats = [
      ..._stats.sublist(0, index),
      current.copyWith(
        count: current.count + count,
        completedSessions: current.completedSessions + completed,
      ),
      ..._stats.sublist(index + 1),
    ];
  }

  Future<void> _replace(Dhikr dhikr) async {
    _items = [
      for (final item in _items)
        if (item.id == dhikr.id) dhikr else item,
    ];
    notifyListeners();
    await _enqueuePersist();
  }

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }
}
