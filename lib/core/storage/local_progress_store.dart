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
    await prefs.setString(_key('nickname'), value);
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
    notifyListeners();
  }

  Future<void> markWuduCompleted() async {
    final prefs = await _ensure();
    await prefs.setBool(_key('wudu_started'), true);
    await prefs.setBool(_key('wudu_completed'), true);
    await _addUnique(_key('completed_lessons'), 'wudu');
    await _addUnique(_key('badges'), 'first_lesson');
    notifyListeners();
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

  Future<void> _addUnique(String key, String value) async {
    final prefs = await _ensure();
    final current = List<String>.from(prefs.getStringList(key) ?? const []);
    if (current.contains(value)) return;
    current.add(value);
    await prefs.setStringList(key, current);
  }
}
