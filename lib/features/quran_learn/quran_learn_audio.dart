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
    if (trimmed.startsWith('assets/audio/prayer/')) return trimmed;
    if (trimmed.startsWith('assets/audio/duas/')) return trimmed;
    return null;
  }

  static String? letterStem(String? alphabetPath) {
    final path = alphabetPath?.trim() ?? '';
    const prefix = 'assets/audio/quran_learn/alphabet/';
    const suffix = '.mp3';
    if (!path.startsWith(prefix) || !path.endsWith(suffix)) return null;
    final stem = path.substring(prefix.length, path.length - suffix.length);
    return stem.isEmpty ? null : stem;
  }

  static String? exercisePath(String? alphabetPath, String harakaId) {
    final letterId = letterStem(alphabetPath);
    if (letterId == null) return null;
    return resolve(
        'assets/audio/quran_learn/exercises/${letterId}_$harakaId.mp3');
  }

  static String? practicePath(String? alphabetPath, String harakaId) {
    final stem = letterStem(alphabetPath);
    if (stem == null) return null;
    switch (harakaId) {
      case 'fatha':
      case 'kasra':
      case 'damma':
        return exercisePath(alphabetPath, harakaId);
      case 'fatha_madd':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/madd/${stem}_madd_alif.mp3');
      case 'kasra_madd':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/madd/${stem}_madd_ya.mp3');
      case 'damma_madd':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/madd/${stem}_madd_waw.mp3');
      case 'tanwin_fath':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/tanwin/${stem}_fathatayn.mp3');
      case 'tanwin_kasr':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/tanwin/${stem}_kasratayn.mp3');
      case 'tanwin_damm':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/tanwin/${stem}_dammatayn.mp3');
      case 'sukun':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/sukun/${stem}_sukun.mp3');
      case 'shadda':
        if (stem == 'elif') return null;
        return resolve('assets/audio/quran_learn/shadda/${stem}_shadda.mp3');
      default:
        return null;
    }
  }

  static String? sukunTripletPath(String? alphabetPath) {
    final stem = letterStem(alphabetPath);
    if (stem == null || stem == 'elif') return null;
    return resolve('assets/audio/quran_learn/sukun/${stem}_triplet.mp3') ??
        practicePath(alphabetPath, 'sukun');
  }

  static String? sukunJoinPath(String? alphabetPath, String hareke) {
    final stem = letterStem(alphabetPath);
    if (stem == null || stem == 'elif') return null;
    switch (hareke) {
      case 'kasra':
        return resolve('assets/audio/quran_learn/sukun/${stem}_join_kasra.mp3');
      case 'damma':
        return resolve('assets/audio/quran_learn/sukun/${stem}_join_damma.mp3');
      default:
        return resolve(
              'assets/audio/quran_learn/sukun/${stem}_join_fatha.mp3',
            ) ??
            (stem == 'ba'
                ? resolve('assets/audio/quran_learn/sukun/eb.mp3')
                : null);
    }
  }

  static String? shaddaHarekePath(String? alphabetPath, String hareke) {
    final stem = letterStem(alphabetPath);
    if (stem == null || stem == 'elif') return null;
    switch (hareke) {
      case 'kasra':
        return resolve(
          'assets/audio/quran_learn/shadda/${stem}_shadda_kasra.mp3',
        );
      case 'damma':
        return resolve(
          'assets/audio/quran_learn/shadda/${stem}_shadda_damma.mp3',
        );
      default:
        return practicePath(alphabetPath, 'shadda');
    }
  }

  static Future<void> playSequence(
    AudioPlayerService audio,
    LocalProgressStore store,
    List<String?> paths,
  ) async {
    for (final path in paths) {
      final playable = resolve(path);
      if (playable == null) continue;
      await play(audio, store, playable);
    }
  }

  static String? shortPairPath(String? alphabetPath, String harakaId) {
    switch (harakaId) {
      case 'fatha_madd':
      case 'tanwin_fath':
        return practicePath(alphabetPath, 'fatha');
      case 'kasra_madd':
      case 'tanwin_kasr':
        return practicePath(alphabetPath, 'kasra');
      case 'damma_madd':
      case 'tanwin_damm':
        return practicePath(alphabetPath, 'damma');
      default:
        return null;
    }
  }

  static String? tajweedExamplePath(
    String lessonId, {
    required int index,
    String? jsonAudio,
  }) {
    if (index < 0) return resolve(jsonAudio);
    final unique =
        'assets/audio/quran_learn/tajweed/${lessonId}_${index + 1}.mp3';
    return resolve(unique) ?? resolve(jsonAudio);
  }

  static String? surahPath(
    int surahNumber, {
    String? jsonAudio,
    bool allowFullSurahFallback = true,
  }) {
    final fromJson = resolve(jsonAudio);
    if (fromJson != null) return fromJson;
    if (!allowFullSurahFallback) return null;
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
