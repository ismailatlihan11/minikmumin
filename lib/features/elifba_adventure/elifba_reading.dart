/// Harekeli harflerin Türkçe okunuşunu kurala göre üretir.
///
/// Kural: üstün kalın harflerde "a", ince harflerde "e"; esre kalın harflerde
/// "ı", ince harflerde "i"; ötre kalın harflerde "u", ince harflerde "ü".
/// Kaynak JSON'daki okunuşlar tutarsız olduğu için (ör. ضَ "dad", خَ "hı")
/// gösterimde bu üreteç esas alınır.
abstract final class ElifbaReading {
  static const fatha = 'َ';
  static const kasra = 'ِ';
  static const damma = 'ُ';

  /// Her durumda kalın okunan yedi harf.
  static const heavyLetters = {'خ', 'ص', 'ض', 'غ', 'ط', 'ق', 'ظ'};

  /// Peltek okunan üç harf.
  static const lispLetters = {'ث', 'ذ', 'ظ'};

  /// Boğazdan çıktığı için ه ve elif'ten ayrılan harfler.
  static const throatLetters = {'ح', 'ع'};

  /// Harfin Türkçe okunuşundaki ünsüz kökü. Elif ve ayn'da kök yoktur,
  /// okunuş sadece harekenin sesidir.
  static const consonants = <String, String>{
    'ا': '',
    'أ': '',
    'إ': '',
    'آ': '',
    'ء': '',
    'ب': 'b',
    'ت': 't',
    'ث': 's',
    'ج': 'c',
    'ح': 'h',
    'خ': 'h',
    'د': 'd',
    'ذ': 'z',
    'ر': 'r',
    'ز': 'z',
    'س': 's',
    'ش': 'ş',
    'ص': 's',
    'ض': 'd',
    'ط': 't',
    'ظ': 'z',
    'ع': '',
    'غ': 'ğ',
    'ف': 'f',
    'ق': 'k',
    'ك': 'k',
    'ل': 'l',
    'م': 'm',
    'ن': 'n',
    'ه': 'h',
    'و': 'v',
    'ي': 'y',
    'ى': 'y',
  };

  /// Ra esreliyken ince, üstünlü ve ötreliyken kalın okunur.
  static bool isHeavy(String letter, String mark) {
    if (letter == 'ر') return mark != kasra;
    return heavyLetters.contains(letter);
  }

  static String vowelFor(String mark, {required bool heavy}) {
    switch (mark) {
      case fatha:
        return heavy ? 'a' : 'e';
      case kasra:
        return heavy ? 'ı' : 'i';
      case damma:
        return heavy ? 'u' : 'ü';
    }
    return '';
  }

  /// Harekeli parçadaki kısa hareke; yoksa boş döner.
  static String markOf(String marked) {
    for (final mark in const [fatha, kasra, damma]) {
      if (marked.contains(mark)) return mark;
    }
    return '';
  }

  static String letterOf(String marked) {
    for (final rune in marked.runes) {
      final char = String.fromCharCode(rune);
      if (consonants.containsKey(char)) return char;
    }
    return '';
  }

  /// Uzatma, cezm ve tenvin içeren parçalar bu üretecin dışındadır.
  static bool isShortSyllable(String marked) {
    const skip = ['ْ', 'ً', 'ٍ', 'ٌ', 'ٰ', 'ا', 'و', 'ي'];
    final letter = letterOf(marked);
    if (letter.isEmpty || markOf(marked).isEmpty) return false;
    var letters = 0;
    for (final rune in marked.runes) {
      final isMark = (rune >= 0x064B && rune <= 0x0652) || rune == 0x0670;
      if (!isMark) letters += 1;
    }
    if (letters != 1) return false;
    for (final char in skip) {
      if (char != letter && marked.contains(char)) return false;
    }
    return true;
  }

  /// Örn. بَ → "be", صُ → "su (kalın)", ثِ → "si (peltek)".
  static String of(String letter, String mark, {bool withTag = true}) {
    final base = consonants[letter];
    if (base == null || mark.isEmpty) return '';
    final heavy = isHeavy(letter, mark);
    final syllable = '$base${vowelFor(mark, heavy: heavy)}';
    if (!withTag) return syllable;
    final tags = [
      if (lispLetters.contains(letter)) 'peltek',
      if (throatLetters.contains(letter)) 'boğaz',
      if (heavyLetters.contains(letter)) 'kalın',
      if (letter == 'ر') heavy ? 'kalın' : 'ince',
    ];
    return tags.isEmpty ? syllable : '$syllable (${tags.join(', ')})';
  }

  /// Harekeli parçanın okunuşu; üretilemezse JSON'daki metin korunur.
  static String forMarked(String marked, String fallback, {bool withTag = true}) {
    if (!isShortSyllable(marked)) return fallback;
    final reading = of(letterOf(marked), markOf(marked), withTag: withTag);
    return reading.isEmpty ? fallback : reading;
  }

  /// Şıklardaki okunuşu, o şıkkın ünlüsünün işaret ettiği harekeye göre
  /// yeniden üretir; böylece çeldiriciler de doğru sesi öğretir.
  static String forOption(String letter, String option) {
    final trimmed = option.trim();
    if (trimmed.isEmpty || trimmed.contains(' ')) return option;
    final mark = _markOfVowel(trimmed[trimmed.length - 1]);
    if (mark.isEmpty) return option;
    final reading = of(letter, mark, withTag: false);
    return reading.isEmpty ? option : reading;
  }

  static String _markOfVowel(String vowel) {
    switch (vowel) {
      case 'a':
      case 'e':
        return fatha;
      case 'ı':
      case 'i':
        return kasra;
      case 'u':
      case 'ü':
        return damma;
    }
    return '';
  }
}
