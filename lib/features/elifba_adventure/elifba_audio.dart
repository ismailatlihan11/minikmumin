import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import 'elifba_audio_map.dart';

/// Maps Elifbâ JSON names to existing offline Kur'an Öğren clips.
/// Missing files never crash; the listen control stays disabled.
abstract final class ElifbaAudio {
  static const names = elifbaAudioNames;

  static const glyphs = elifbaAudioGlyphs;

  static String? resolve(String? path) {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!trimmed.startsWith('assets/audio/')) return null;
    if (AssetCatalog.contains(trimmed)) return trimmed;
    if (trimmed.startsWith('assets/audio/elifba/') ||
        trimmed.startsWith('assets/audio/quran_learn/')) {
      return trimmed;
    }
    return null;
  }

  static String? letterName(String name) {
    final stem = elifbaAudioNames[name.trim().toLowerCase()];
    if (stem == null) return null;
    return resolve(elifbaNamePath(stem));
  }

  static String? letterGlyph(String glyph) {
    final stem = glyphs[_firstArabicLetter(glyph)];
    if (stem == null) return null;
    return resolve(elifbaNamePath(stem));
  }

  static String? letterSound(String glyphOrName, {String haraka = 'fatha'}) {
    final stem = elifbaLetterStem(glyphOrName);
    if (stem == null) return null;
    if (haraka == 'name') return resolve(elifbaNamePath(stem));
    if (!elifbaSyllableHasRecording(haraka)) return null;
    // Hece kayıtları Elifbâ'ya özeldir: kartta yazan okunuşu (be, si, su)
    // Türkçe seslendirmeyle söyler. Kur'an serisinin kayıtları değişmez.
    return resolve(elifbaSyllablePath(stem, haraka));
  }

  static String? forMarked(String marked, {String? name}) {
    final haraka = elifbaHarakaOf(marked);
    if (haraka == 'name') {
      return letterName(name ?? '') ?? letterGlyph(marked);
    }
    // Kaydı olmayan hecede harfin adını çalmıyoruz: بَّ ile "Be" aynı şey
    // değil, yanlış öğretir.
    if (!elifbaSyllableHasRecording(haraka)) return null;
    return letterSound(name ?? marked, haraka: haraka) ??
        letterGlyph(marked) ??
        letterName(name ?? '');
  }

  /// Kelime ve ifadeler için ses: kayıt yoksa harf adı sesi çalınmaz,
  /// çünkü harfin adı ile kelimenin okunuşu aynı şey değildir.
  /// Okunuşu bilinen kelimelerin Elifbâ'ya özel kaydı kullanılır.
  static String? forExample(String text, {String audio = '', String reading = ''}) {
    final recorded = resolve(audio);
    if (recorded != null) return recorded;
    if (isSingleCluster(text)) return forMarked(text);
    final word = reading.isEmpty ? null : elifbaWordPath(reading);
    return word == null ? null : resolve(word);
  }

  /// Tek harf + üzerindeki harekelerden oluşan kısa parça mı?
  static bool isSingleCluster(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.contains(' ')) return false;
    var letters = 0;
    for (final rune in trimmed.runes) {
      final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
      if (!isMark) letters += 1;
    }
    return letters == 1;
  }

  static String? mark(String id) {
    return resolve('assets/audio/quran_learn/harakat/$id.mp3');
  }

  static Future<void> play(AudioPlayerService audio, String? path) async {
    final playable = resolve(path);
    if (playable == null) return;
    try {
      await audio.playAsset(playable, waitUntilDone: false);
    } catch (_) {}
  }

  static String _firstArabicLetter(String text) {
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (glyphs.containsKey(ch)) return ch;
    }
    return '';
  }
}
