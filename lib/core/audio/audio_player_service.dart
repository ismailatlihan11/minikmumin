import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  Future<bool> playAsset(String path) async {
    if (path.trim().isEmpty) return false;
    try {
      await _player.stop();
      await _player.setAsset(path);
      await _player.play();
      return true;
    } catch (_) {
      // Missing or unplayable audio must never crash the lesson.
      return false;
    }
  }

  Stream<bool> get playingStream => _player.playingStream;

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
  static const String celebrate = 'assets/audio/effects/tebrik.mp3';
}
