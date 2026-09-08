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
    final stem = names[name.trim().toLowerCase()];
    if (stem == null) return null;
    return resolve('assets/audio/quran_learn/alphabet/$stem.mp3');
  }

  static String? letterGlyph(String glyph) {
    final stem = glyphs[_firstArabicLetter(glyph)];
    if (stem == null) return null;
    return resolve('assets/audio/quran_learn/alphabet/$stem.mp3');
  }

  static String? letterSound(String glyphOrName, {String haraka = 'fatha'}) {
    final fromName = names[glyphOrName.trim().toLowerCase()];
    final stem = fromName ?? glyphs[_firstArabicLetter(glyphOrName)];
    if (stem == null) return null;
    if (haraka == 'name') {
      return resolve('assets/audio/quran_learn/alphabet/$stem.mp3');
    }
    // Hece kayıtları Elifbâ'ya özeldir: kartta yazan okunuşu (be, si, su)
    // Türkçe seslendirmeyle söyler. Kur'an serisinin kayıtları değişmez.
    return resolve('assets/audio/elifba/exercises/${stem}_$haraka.mp3');
  }

  static String? forMarked(String marked, {String? name}) {
    var haraka = 'name';
    if (marked.contains('ّ')) {
      haraka = 'shadda';
    } else if (marked.contains('ْ')) {
      haraka = 'sukun';
    } else if (marked.contains('ِ')) {
      haraka = 'kasra';
    } else if (marked.contains('ُ')) {
      haraka = 'damma';
    } else if (marked.contains('َ')) {
      haraka = 'fatha';
    }
    final sounded = haraka == 'name'
        ? (letterName(name ?? '') ?? letterGlyph(marked))
        : letterSound(name ?? marked, haraka: haraka);
    return sounded ?? letterGlyph(marked) ?? letterName(name ?? '');
  }

  /// Kelime ve ifadeler için ses: kayıt yoksa harf adı sesi çalınmaz,
  /// çünkü harfin adı ile kelimenin okunuşu aynı şey değildir.
  static String? forExample(String text, {String audio = ''}) {
    final recorded = resolve(audio);
    if (recorded != null) return recorded;
    if (!isSingleCluster(text)) return null;
    return forMarked(text);
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
