import '../../data/models/quran_learning.dart';

/// Cezm dersini Kur'an Öğrenme Serisi'ndeki cezm çalışmasıyla besler:
/// sâkin harfler, hece birleşimleri ve Kur'an'da geçen gerçek kelimeler.
abstract final class ElifbaCezmExamples {
  static const sukun = 'ْ';

  /// Dersin başlığı; yama bu başlığı içeren derse uygulanır.
  static const lessonTitleContains = 'cezm';

  static Map<String, dynamic>? build(QuranLearningPack? pack) {
    if (pack == null) return null;
    final letters = _sukunLetters(pack);
    final words = _words(pack);
    if (letters.isEmpty && words.isEmpty) return null;
    return {
      if (letters.isNotEmpty) 'examples': letters,
      if (words.isNotEmpty) 'word_examples': words,
      if (words.isNotEmpty) 'word_section_title': 'Cezm ile Kelime Okuma',
      if (words.isNotEmpty)
        'word_section_instruction':
            'Kelimedeki cezmli harfi bul, önceki sesle birleştirerek oku.',
    };
  }

  /// Tek tek sâkin harfler (بْ, تْ, مْ ...) ve sesleri.
  static List<Map<String, dynamic>> _sukunLetters(QuranLearningPack pack) {
    final rows = <String, Map<String, dynamic>>{};
    for (final haraka in pack.harakat) {
      if (!haraka.symbol.contains(sukun) && haraka.id != 'sukun') continue;
      for (final example in haraka.examples) {
        if (!example.arabic.contains(sukun)) continue;
        rows[example.arabic] = {
          'text': example.arabic,
          'reading': example.reading,
          'audio': example.audio ?? '',
        };
      }
    }
    for (final lesson in pack.combinations) {
      for (final example in lesson.examples) {
        final combined = example.combined;
        if (!combined.contains(sukun)) continue;
        if (_letterCount(combined) != 1) continue;
        rows[combined] = {
          'text': combined,
          'reading': '${_stripMarks(example.reading).toLowerCase()} (sakin)',
          'audio': example.audio ?? '',
        };
      }
    }
    return rows.values.toList(growable: false);
  }

  /// Cezm içeren gerçek Kur'an kelimeleri; hece birleşimleri de eklenir.
  static List<Map<String, dynamic>> _words(QuranLearningPack pack) {
    final rows = <String, Map<String, dynamic>>{};
    for (final lesson in pack.combinations) {
      for (final example in lesson.examples) {
        final combined = example.combined;
        if (!combined.contains(sukun)) continue;
        if (_letterCount(combined) < 2) continue;
        rows[combined] = {
          'word': combined,
          'reading': example.reading,
          'focus': example.parts.join(' + '),
          'audio': example.audio ?? '',
        };
      }
    }
    for (final word in pack.words) {
      if (!word.arabic.contains(sukun)) continue;
      rows[word.arabic] = {
        'word': word.arabic,
        'reading': word.reading,
        'meaning': word.meaningTr,
        'focus': _cezmFocus(word.arabic),
        'audio': word.audio ?? '',
      };
    }
    return rows.values.toList(growable: false);
  }

  /// Kelimedeki cezmli harfleri odak notu olarak gösterir: "Cezmli harf: لْ".
  static String _cezmFocus(String word) {
    final letters = <String>[];
    String? previous;
    for (final rune in word.runes) {
      final char = String.fromCharCode(rune);
      if (char == sukun && previous != null) {
        final marked = '$previous$sukun';
        if (!letters.contains(marked)) letters.add(marked);
      }
      final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
      if (!isMark) previous = char;
    }
    if (letters.isEmpty) return 'Cezm örneği.';
    return 'Cezmli harf: ${letters.join(' · ')}';
  }

  static int _letterCount(String text) {
    var letters = 0;
    for (final rune in text.runes) {
      final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
      if (!isMark) letters += 1;
    }
    return letters;
  }

  static String _stripMarks(String value) {
    return value.replaceAll(RegExp(r'[\u064B-\u0652]'), '').trim();
  }
}
