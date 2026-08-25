import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import 'quran_learn_progress.dart';

abstract final class QuranLearnAudio {
  /// Returns a playable asset path, or null when JSON/audio is missing.
  static String? resolve(String? path) {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (AssetCatalog.contains(trimmed)) return trimmed;
    // Quran Learn clips are bundled under this prefix. Show Dinle even if
    // AssetCatalog was loaded before the nested folders were registered.
    if (trimmed.startsWith('assets/audio/quran_learn/')) return trimmed;
    return null;
  }

  static String? exercisePath(String? alphabetPath, String harakaId) {
    final path = alphabetPath?.trim() ?? '';
    const prefix = 'assets/audio/quran_learn/alphabet/';
    const suffix = '.mp3';
    if (!path.startsWith(prefix) || !path.endsWith(suffix)) return null;
    final letterId = path.substring(prefix.length, path.length - suffix.length);
    if (letterId.isEmpty) return null;
    return resolve('assets/audio/quran_learn/exercises/${letterId}_$harakaId.mp3');
  }

  static String? surahPath(int surahNumber, {String? jsonAudio}) {
    final fromJson = resolve(jsonAudio);
    if (fromJson != null) return fromJson;
    final padded = surahNumber.toString().padLeft(3, '0');
    return resolve('assets/audio/quran_learn/surahs/surah_$padded.mp3');
  }

  static Future<bool> play(
    AudioPlayerService audio,
    LocalProgressStore store,
    String? path,
  ) async {
    final playable = resolve(path);
    if (playable == null) return false;
    final ok = await audio.playAsset(playable);
    if (ok) await store.addCounter(quranLearnAudioPlays);
    return ok;
  }

  /// Prepares a clip for follow-along. Playback is started by the caller.
  static Future<Duration?> prepare(
    AudioPlayerService audio,
    LocalProgressStore store,
    String? path, {
    bool countPlay = true,
  }) async {
    final playable = resolve(path);
    if (playable == null) return null;
    final duration = await audio.prepareAsset(playable);
    if (duration != null && countPlay) {
      await store.addCounter(quranLearnAudioPlays);
    }
    return duration;
  }

  static bool get canRecord => false;
}
