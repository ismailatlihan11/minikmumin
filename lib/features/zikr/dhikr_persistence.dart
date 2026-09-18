import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/dhikr.dart';

class DhikrPersistenceService {
  DhikrPersistenceService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const itemsKey = 'dhkr_items';
  static const sessionsKey = 'dhkr_sessions';
  static const dailyStatsKey = 'dhkr_daily_stats';
  static const favoritesKey = 'dhkr_favorites';
  static const lastUsedKey = 'dhkr_last_used';
  static const settingsKey = 'dhkr_settings';
  static const inProgressKey = 'dhkr_in_progress';
  static const orderKey = 'dhkr_order';
  static const hiddenKey = 'dhkr_hidden';

  Future<SharedPreferences> _ensure() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<Dhikr>> loadItems() async {
    return _decodeList(itemsKey, Dhikr.fromJson);
  }

  Future<void> saveItems(List<Dhikr> items) async {
    await _encodeList(itemsKey, items.map((item) => item.toJson()).toList());
  }

  Future<List<DhikrSession>> loadSessions() async {
    return _decodeList(sessionsKey, DhikrSession.fromJson);
  }

  Future<void> saveSessions(List<DhikrSession> sessions) async {
    await _encodeList(
      sessionsKey,
      sessions.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<DhikrDailyStat>> loadDailyStats() async {
    return _decodeList(dailyStatsKey, DhikrDailyStat.fromJson);
  }

  Future<void> saveDailyStats(List<DhikrDailyStat> stats) async {
    await _encodeList(
      dailyStatsKey,
      stats.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<DhikrFavorite>> loadFavorites() async {
    return _decodeList(favoritesKey, DhikrFavorite.fromJson);
  }

  Future<void> saveFavorites(List<DhikrFavorite> favorites) async {
    await _encodeList(
      favoritesKey,
      favorites.map((item) => item.toJson()).toList(),
    );
  }

  Future<String?> loadLastUsedId() async {
    final prefs = await _ensure();
    return prefs.getString(lastUsedKey);
  }

  Future<void> saveLastUsedId(String id) async {
    final prefs = await _ensure();
    await prefs.setString(lastUsedKey, id);
  }

  Future<void> clearLastUsedId() async {
    final prefs = await _ensure();
    await prefs.remove(lastUsedKey);
  }

  Future<DhikrSettings> loadSettings() async {
    final prefs = await _ensure();
    final raw = prefs.getString(settingsKey);
    if (raw == null || raw.isEmpty) return const DhikrSettings();
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return const DhikrSettings();
    return DhikrSettings.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> saveSettings(DhikrSettings settings) async {
    final prefs = await _ensure();
    await prefs.setString(settingsKey, jsonEncode(settings.toJson()));
  }

  Future<DhikrProgress?> loadInProgress() async {
    final prefs = await _ensure();
    final raw = prefs.getString(inProgressKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return DhikrProgress.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> saveInProgress(DhikrProgress? progress) async {
    final prefs = await _ensure();
    if (progress == null) {
      await prefs.remove(inProgressKey);
      return;
    }
    await prefs.setString(inProgressKey, jsonEncode(progress.toJson()));
  }

  Future<List<String>> loadOrderIds() async {
    final prefs = await _ensure();
    final raw = prefs.getStringList(orderKey);
    return raw == null ? const [] : List<String>.from(raw);
  }

  Future<void> saveOrderIds(List<String> ids) async {
    final prefs = await _ensure();
    await prefs.setStringList(orderKey, ids);
  }

  Future<List<String>> loadHiddenIds() async {
    final prefs = await _ensure();
    final raw = prefs.getStringList(hiddenKey);
    return raw == null ? const [] : List<String>.from(raw);
  }

  Future<void> saveHiddenIds(List<String> ids) async {
    final prefs = await _ensure();
    await prefs.setStringList(hiddenKey, ids);
  }

  Future<List<T>> _decodeList<T>(
    String key,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final prefs = await _ensure();
    final raw = prefs.getString(key) ?? '[]';
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _encodeList(String key, List<Map<String, dynamic>> rows) async {
    final prefs = await _ensure();
    await prefs.setString(key, jsonEncode(rows));
  }
}
