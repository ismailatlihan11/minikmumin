import '../../data/models/quran_learning.dart';
import 'elifba_models.dart';
import 'elifba_practice_bridge.dart';
import 'elifba_tajweed_bridge.dart';

/// Macera derslerini Kur'an Öğrenme Serisi'ndeki çalışmalarla besler.
/// Kaynak JSON'daki dersler zayıf kaldığında (cezm, şedde) aynı harf, hece
/// ve gerçek Kur'an kelimeleri buradan aktarılır.
abstract final class ElifbaQuranBridge {
  static const sukun = 'ْ';
  static const shadda = 'ّ';

  static List<ElifbaLessonPatch> patches(QuranLearningPack? pack) {
    return [
      if (pack != null)
        for (final topic in _topics)
          if (_build(pack, topic) case final content?)
            ElifbaLessonPatch(
              titleContains: topic.titleContains,
              content: content,
            ),
      ...ElifbaPracticeBridge.patches(pack),
      ...ElifbaTajweedBridge.patches(pack),
    ];
  }

  static const _topics = <_Topic>[
    _Topic(
      mark: sukun,
      titleContains: 'cezm',
      harakaId: 'sukun',
      sectionTitle: 'Cezm ile Kelime Okuma',
      sectionInstruction:
          'Kelimedeki cezmli harfi bul, önceki sesle birleştirerek oku.',
      focusLabel: 'Cezmli harf',
    ),
    _Topic(
      mark: shadda,
      titleContains: 'şedde',
      harakaId: 'shadda',
      sectionTitle: 'Şedde ile Kelime Okuma',
      sectionInstruction:
          'Şeddeli harfi iki kez oku: önce sakin, sonra harekeli.',
      focusLabel: 'Şeddeli harf',
    ),
  ];

  static Map<String, dynamic>? _build(QuranLearningPack pack, _Topic topic) {
    final letters = _letters(pack, topic);
    final words = _words(pack, topic);
    if (letters.isEmpty && words.isEmpty) return null;
    return {
      if (letters.isNotEmpty) 'examples': letters,
      if (words.isNotEmpty) ...{
        'word_examples': words,
        'word_section_title': topic.sectionTitle,
        'word_section_instruction': topic.sectionInstruction,
      },
    };
  }

  /// İşareti taşıyan tek harflik parçalar (بْ, بَّ ...).
  static List<Map<String, dynamic>> _letters(
    QuranLearningPack pack,
    _Topic topic,
  ) {
    final rows = <String, Map<String, dynamic>>{};
    for (final haraka in pack.harakat) {
      if (haraka.id != topic.harakaId && !haraka.symbol.contains(topic.mark)) {
        continue;
      }
      for (final example in haraka.examples) {
        if (!example.arabic.contains(topic.mark)) continue;
        if (_letterCount(example.arabic) != 1) continue;
        rows[example.arabic] = {
          'text': example.arabic,
          'reading': example.reading,
          'audio': example.audio ?? '',
        };
      }
    }
    for (final lesson in pack.combinations) {
      for (final example in lesson.examples) {
        if (!example.combined.contains(topic.mark)) continue;
        if (_letterCount(example.combined) != 1) continue;
        rows[example.combined] = {
          'text': example.combined,
          'reading': '${example.reading.toLowerCase()} (sakin)',
          'audio': example.audio ?? '',
        };
      }
    }
    return rows.values.toList(growable: false);
  }

  /// İşareti taşıyan heceler ve Kur'an'da geçen gerçek kelimeler.
  static List<Map<String, dynamic>> _words(
    QuranLearningPack pack,
    _Topic topic,
  ) {
    final rows = <String, Map<String, dynamic>>{};
    for (final haraka in pack.harakat) {
      if (haraka.id != topic.harakaId) continue;
      for (final example in haraka.examples) {
        if (!example.arabic.contains(topic.mark)) continue;
        if (_letterCount(example.arabic) < 2) continue;
        rows[example.arabic] = {
          'word': example.arabic,
          'reading': example.reading,
          'focus': _focus(example.arabic, topic),
          'audio': example.audio ?? '',
        };
      }
    }
    for (final lesson in pack.combinations) {
      for (final example in lesson.examples) {
        if (!example.combined.contains(topic.mark)) continue;
        if (_letterCount(example.combined) < 2) continue;
        rows[example.combined] = {
          'word': example.combined,
          'reading': example.reading,
          'focus': example.parts.join(' + '),
          'audio': example.audio ?? '',
        };
      }
    }
    for (final word in pack.words) {
      if (!word.arabic.contains(topic.mark)) continue;
      rows[word.arabic] = {
        'word': word.arabic,
        'reading': word.reading,
        'meaning': word.meaningTr,
        'focus': _focus(word.arabic, topic),
        'audio': word.audio ?? '',
      };
    }
    return rows.values.toList(growable: false);
  }

  /// Kelimenin hangi harfinde işaret olduğunu gösterir: "Şeddeli harf: بِّ".
  static String _focus(String word, _Topic topic) {
    final found = <String>[];
    final runes = word.runes.toList();
    for (var i = 0; i < runes.length; i++) {
      if (String.fromCharCode(runes[i]) != topic.mark) continue;
      final letter = _letterBefore(runes, i);
      if (letter.isEmpty) continue;
      final vowel = _vowelNear(runes, i);
      final piece = '$letter${topic.mark}$vowel';
      if (!found.contains(piece)) found.add(piece);
    }
    if (found.isEmpty) return '${topic.focusLabel} var.';
    return '${topic.focusLabel}: ${found.join(' · ')}';
  }

  static String _letterBefore(List<int> runes, int index) {
    for (var i = index - 1; i >= 0; i--) {
      if (!_isMark(runes[i])) return String.fromCharCode(runes[i]);
    }
    return '';
  }

  /// Şedde tek başına öğretilmez; hareke şeddenin iki yanında da yazılabildiği
  /// için ikisine de bakılır ve daima şeddeden sonra gösterilir.
  static String _vowelNear(List<int> runes, int index) {
    const vowels = [0x064E, 0x0650, 0x064F];
    for (final i in [index + 1, index - 1]) {
      if (i < 0 || i >= runes.length) continue;
      if (vowels.contains(runes[i])) return String.fromCharCode(runes[i]);
    }
    return '';
  }

  static bool _isMark(int rune) =>
      (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;

  static int _letterCount(String text) {
    var letters = 0;
    for (final rune in text.runes) {
      if (!_isMark(rune)) letters += 1;
    }
    return letters;
  }
}

class _Topic {
  const _Topic({
    required this.mark,
    required this.titleContains,
    required this.harakaId,
    required this.sectionTitle,
    required this.sectionInstruction,
    required this.focusLabel,
  });

  final String mark;
  final String titleContains;
  final String harakaId;
  final String sectionTitle;
  final String sectionInstruction;
  final String focusLabel;
}
