import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/dhikr.dart';

class DhikrFeedbackService {
  DhikrFeedbackService({this.silent = false}) {
    if (silent) return;
    _players = [
      AudioPlayer(
        handleInterruptions: false,
        handleAudioSessionActivation: false,
      ),
      AudioPlayer(
        handleInterruptions: false,
        handleAudioSessionActivation: false,
      ),
    ];
  }

  final bool silent;
  List<AudioPlayer> _players = const [];
  final Map<int, String> _loaded = {};
  var _cursor = 0;

  Future<void> preload(String path) async {
    if (silent || path.trim().isEmpty) return;
    for (var i = 0; i < _players.length; i++) {
      try {
        await _players[i].setAsset(path);
        _loaded[i] = path;
      } catch (_) {}
    }
  }

  Future<void> vibrate(DhikrSettings settings) async {
    if (silent || !settings.vibrationEnabled) return;
    try {
      switch (settings.vibrationIntensity) {
        case DhikrVibrationIntensity.light:
          await HapticFeedback.lightImpact();
        case DhikrVibrationIntensity.normal:
          await HapticFeedback.mediumImpact();
        case DhikrVibrationIntensity.strong:
          await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  Future<void> playClick(String path) async {
    if (silent || path.trim().isEmpty || _players.isEmpty) return;
    final index = _cursor % _players.length;
    _cursor++;
    final player = _players[index];
    try {
      if (_loaded[index] != path) {
        await player.setAsset(path);
        _loaded[index] = path;
      }
      await player.seek(Duration.zero);
      unawaited(player.play());
    } catch (_) {
      _loaded.remove(index);
      try {
        await player.stop();
        await player.setAsset(path);
        _loaded[index] = path;
        unawaited(player.play());
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    for (final player in _players) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players = const [];
    _loaded.clear();
  }
}
