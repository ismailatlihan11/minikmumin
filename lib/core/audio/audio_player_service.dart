import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  String? _currentAsset;

  String? get currentAsset => _currentAsset;

  Future<bool> playAsset(String path, {bool waitUntilDone = true}) async {
    if (path.trim().isEmpty) return false;
    try {
      await _player.stop();
      _currentAsset = path;
      await _player.setAsset(path);
      if (waitUntilDone) {
        await _player.play();
      } else {
        unawaited(_player.play().then((_) {}, onError: (_, __) {}));
      }
      return true;
    } catch (_) {
      _currentAsset = null;
      // Missing or unplayable audio must never crash the lesson.
      return false;
    }
  }

  /// Loads the asset without waiting for playback to finish.
  Future<Duration?> prepareAsset(String path) async {
    if (path.trim().isEmpty) return null;
    try {
      await _player.stop();
      final duration = await _player.setAsset(path);
      return duration ?? _player.duration;
    } catch (_) {
      return null;
    }
  }

  Future<void> resume() async {
    try {
      unawaited(_player.play().then((_) {}, onError: (_, __) {}));
    } catch (_) {}
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (_) {}
  }

  Stream<bool> get playingStream => _player.playingStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<bool> get completedStream => _player.processingStateStream.map(
        (state) => state == ProcessingState.completed,
      );

  Duration? get duration => _player.duration;

  bool get isPlaying => _player.playing;

  Future<bool> toggleAsset(String path) async {
    if (path.trim().isEmpty) return false;
    if (_player.playing) {
      await stop();
      return true;
    }
    return playAsset(path);
  }

  Future<void> stop() async {
    _currentAsset = null;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}

abstract final class EffectAudio {
  static const String correct = 'assets/audio/effects/dogru_cevap.mp3';
  static const String retry = 'assets/audio/effects/tekrar_deneyelim.mp3';
  static const String complete = 'assets/audio/effects/ders_tamamlandi.mp3';
  static const String tesbihClick = 'assets/audio/effects/tesbih_click.wav';
}
