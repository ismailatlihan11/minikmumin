import 'dart:async';

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _live.add(this);
    _completionSub = _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        unawaited(_resetAfterComplete());
      }
    });
  }

  static final Set<AudioPlayerService> _live = <AudioPlayerService>{};
  static AudioPlayerService? _active;

  final AudioPlayer _player;
  StreamSubscription<ProcessingState>? _completionSub;
  String? _currentAsset;

  String? get currentAsset => _currentAsset;

  /// Stops every other live player so only [this] can make sound.
  Future<void> _claimExclusive() async {
    _active = this;
    final others = _live.where((other) => !identical(other, this)).toList();
    for (final other in others) {
      await other._stopLocal();
    }
  }

  Future<bool> playAsset(String path, {bool waitUntilDone = true}) async {
    if (path.trim().isEmpty) return false;
    try {
      await _claimExclusive();
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
      await _claimExclusive();
      await _player.stop();
      final duration = await _player.setAsset(path);
      return duration ?? _player.duration;
    } catch (_) {
      return null;
    }
  }

  Future<void> resume() async {
    try {
      await _claimExclusive();
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

  /// True only while audio is actively playing — not after natural completion.
  Stream<bool> get playingStream => _player.playerStateStream.map(_isActivelyPlaying);

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<bool> get completedStream => _player.processingStateStream.map(
        (state) => state == ProcessingState.completed,
      );

  Duration? get duration => _player.duration;

  bool get isPlaying => _isActivelyPlaying(_player.playerState);

  bool _isActivelyPlaying(PlayerState state) =>
      state.playing && state.processingState != ProcessingState.completed;

  Future<bool> toggleAsset(String path) async {
    if (path.trim().isEmpty) return false;
    if (isPlaying && _currentAsset == path) {
      await stop();
      return true;
    }
    return playAsset(path);
  }

  Future<void> _resetAfterComplete() async {
    await _stopLocal();
  }

  Future<void> _stopLocal() async {
    _currentAsset = null;
    if (identical(_active, this)) _active = null;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> stop() => _stopLocal();

  Future<void> dispose() async {
    _live.remove(this);
    if (identical(_active, this)) _active = null;
    await _completionSub?.cancel();
    _completionSub = null;
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
