import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../../data/models/dhikr.dart';

/// Short tesbih clicks need a SoundPool-style player. just_audio/ExoPlayer
/// seeks on every tap, so ticks arrive late or get dropped.
class DhikrFeedbackService {
  DhikrFeedbackService({this.silent = false});

  final bool silent;
  static const _poolSize = 6;
  static const _clickAsset = 'audio/effects/tesbih_click.wav';

  final List<AudioPlayer> _clicks = [];
  final List<bool> _busy = [];
  AudioPlayer? _long;
  var _cursor = 0;
  var _ready = false;
  Future<void>? _loading;

  Future<void> preload(String path) async {
    if (silent) return;
    await _ensure();
  }

  Future<void> _ensure() async {
    if (silent || _ready) return;
    _loading ??= _create();
    await _loading;
  }

  Future<void> _create() async {
    final ctx = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    for (var i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setAudioContext(ctx);
        await player.setSource(AssetSource(_clickAsset));
        final index = _clicks.length;
        player.onPlayerComplete.listen((_) async {
          try {
            await player.seek(Duration.zero);
          } catch (_) {}
          if (index < _busy.length) _busy[index] = false;
        });
        _clicks.add(player);
        _busy.add(false);
      } catch (_) {
        try {
          await player.dispose();
        } catch (_) {}
      }
    }
    final long = AudioPlayer();
    try {
      await long.setPlayerMode(PlayerMode.mediaPlayer);
      await long.setReleaseMode(ReleaseMode.stop);
      await long.setAudioContext(ctx);
      _long = long;
    } catch (_) {
      try {
        await long.dispose();
      } catch (_) {}
    }
    _ready = _clicks.isNotEmpty;
    if (!_ready) _loading = null;
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
    if (silent || path.trim().isEmpty) return;
    if (!_ready) {
      unawaited(_ensure().then((_) => _fire(path)));
      return;
    }
    _fire(path);
  }

  void _fire(String path) {
    if (path.endsWith('.wav') || path.contains('tesbih_click')) {
      if (_clicks.isEmpty) return;
      var index = -1;
      for (var i = 0; i < _clicks.length; i++) {
        final j = (_cursor + i) % _clicks.length;
        if (!_busy[j]) {
          index = j;
          break;
        }
      }
      if (index < 0) index = _cursor % _clicks.length;
      _cursor = index + 1;
      _busy[index] = true;
      unawaited(_resumeClick(_clicks[index], index));
      return;
    }
    final long = _long;
    if (long == null) return;
    unawaited(long.play(AssetSource(_assetKey(path))));
  }

  Future<void> _resumeClick(AudioPlayer player, int index) async {
    try {
      await player.resume();
    } catch (_) {
      try {
        await player.play(
          AssetSource(_clickAsset),
          mode: PlayerMode.lowLatency,
        );
      } catch (_) {
        if (index < _busy.length) _busy[index] = false;
      }
    }
  }

  String _assetKey(String path) {
    const prefix = 'assets/';
    return path.startsWith(prefix) ? path.substring(prefix.length) : path;
  }

  Future<void> dispose() async {
    for (final player in _clicks) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _clicks.clear();
    _busy.clear();
    try {
      await _long?.dispose();
    } catch (_) {}
    _long = null;
    _ready = false;
    _loading = null;
  }
}
