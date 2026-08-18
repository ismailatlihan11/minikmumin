import '../../app/constants/content_assets.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import 'quran_learn_progress.dart';

abstract final class QuranLearnAudio {
  /// Returns a playable asset path, or null when JSON/audio is missing.
  static String? resolve(String? path) {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!AssetCatalog.contains(trimmed)) return null;
    return trimmed;
  }

  static String? surahPath(int surahNumber) {
    final mapped = ContentAssets.audioFor('surah_$surahNumber');
    return resolve(mapped);
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

  static bool get canRecord => false;
}
