/// Harekeli harflerin Türkçe okunuşunu kurala göre üretir.
///
/// Kural: üstün kalın harflerde "a", ince harflerde "e"; esre her harfte "i";
/// ötre her harfte "u".
/// Kaynak JSON'daki okunuşlar tutarsız olduğu için (ör. ضَ "dad", خَ "hı")
/// gösterimde bu üreteç esas alınır.
abstract final class ElifbaReading {
  static const fatha = 'َ';
  static const kasra = 'ِ';
  static const damma = 'ُ';
  static const shadda = 'ّ';
  static const sukun = 'ْ';
  static const fathatayn = 'ً';
  static const kasratayn = 'ٍ';
  static const dammatayn = 'ٌ';

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
    if (letter == 'ر') return mark != kasra && mark != kasratayn;
    return heavyLetters.contains(letter);
  }

  static String vowelFor(String mark, {required bool heavy}) {
    final pair = vowelPairs[mark];
    if (pair == null) return '';
    return heavy ? pair.heavy : pair.thin;
  }

  /// Harekeli parçadaki hareke; yoksa boş döner. Tenvin çift harekedir,
  /// tek harekeden önce aranır.
  static String markOf(String marked) {
    for (final mark in const [
      fathatayn,
      kasratayn,
      dammatayn,
      fatha,
      kasra,
      damma,
      sukun,
    ]) {
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

  /// Uzatma içeren parçalar bu üretecin dışındadır.
  static bool isShortSyllable(String marked) {
    const skip = ['ٰ', 'ا', 'و', 'ي'];
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

  /// Örn. بَ → "be", صُ → "su (kalın)", ثِ → "si (peltek)", نَّ → "nne".
  /// Şeddeli harf iki kez okunduğu için ünsüz tekrarlanır.
  static String of(
    String letter,
    String mark, {
    bool withTag = true,
    bool doubled = false,
  }) {
    final base = consonants[letter];
    if (base == null || mark.isEmpty) return '';
    final heavy = isHeavy(letter, mark);
    // Cezmli harfin kendi sesi yoktur; önceki harekeyle birlikte kapanır:
    // بْ = "eb", صْ = "as". Sesi olmayan elif ve ayn kural dışıdır.
    if (mark == sukun) {
      if (base.isEmpty) return '';
      final lead = heavy ? 'a' : 'e';
      return withTag
          ? _tagged('$lead$base', letter, heavy: heavy)
          : '$lead$base';
    }
    final root = doubled ? '$base$base' : base;
    final syllable = '$root${vowelFor(mark, heavy: heavy)}';
    if (!withTag) return syllable;
    return _tagged(syllable, letter, heavy: heavy, doubled: doubled);
  }

  static String _tagged(
    String syllable,
    String letter, {
    required bool heavy,
    bool doubled = false,
  }) {
    final tags = [
      if (lispLetters.contains(letter)) 'peltek',
      if (throatLetters.contains(letter)) 'boğaz',
      if (heavyLetters.contains(letter)) 'kalın',
      if (letter == 'ر') heavy ? 'kalın' : 'ince',
      if (doubled) 'şeddeli',
    ];
    return tags.isEmpty ? syllable : '$syllable (${tags.join(', ')})';
  }

  /// Harekeli parçanın okunuşu; üretilemezse JSON'daki metin korunur.
  static String forMarked(String marked, String fallback,
      {bool withTag = true}) {
    if (!isShortSyllable(marked)) return fallback;
    final reading = of(
      letterOf(marked),
      markOf(marked),
      withTag: withTag,
      doubled: marked.contains(shadda),
    );
    return reading.isEmpty ? fallback : reading;
  }

  /// Şıklardaki okunuşu, o şıkkın ünlüsünün işaret ettiği harekeye göre
  /// yeniden üretir; böylece çeldiriciler de doğru sesi öğretir.
  static String forOption(String letter, String option,
      {bool doubled = false}) {
    final trimmed = option.trim();
    if (trimmed.isEmpty || trimmed.contains(' ')) return option;
    final mark = _markOfVowel(trimmed[trimmed.length - 1]);
    if (mark.isEmpty) return option;
    final reading = of(letter, mark, withTag: false, doubled: doubled);
    return reading.isEmpty ? option : reading;
  }

  /// Harekenin sesi: kalın harflerde ve ince harflerde. Yalnızca üstün
  /// harfin kalınlığına göre değişir; esre her harfte 'i', ötre her harfte
  /// 'u' okunur.
  /// Tenvin, harekenin sesine bir 'n' ekler: بً "ben", صً "san", بٍ "bin".
  static const vowelPairs = <String, ({String heavy, String thin})>{
    fatha: (heavy: 'a', thin: 'e'),
    kasra: (heavy: 'i', thin: 'i'),
    damma: (heavy: 'u', thin: 'u'),
    fathatayn: (heavy: 'an', thin: 'en'),
    kasratayn: (heavy: 'in', thin: 'in'),
    dammatayn: (heavy: 'un', thin: 'un'),
  };

  static String describeMark(String mark) {
    final pair = vowelPairs[mark];
    if (pair == null) return '';
    if (pair.heavy == pair.thin) return "her harfte '${pair.heavy}'";
    return "kalın harflerde '${pair.heavy}', ince harflerde '${pair.thin}'";
  }

  static final _shortVowelText =
      RegExp("kısa ['\u2018]?([aiu])['\u2019]?( ses)");
  static final _tenvinText = RegExp(r'-an, -in, -un');

  /// Ders metinlerinde harekeyi tek sese indirgeyen anlatımları düzeltir:
  /// "kısa 'a' sesi verir" → "kalın harflerde kısa 'a', ince harflerde
  /// kısa 'e' sesi verir".
  static String fixSoundText(String text) {
    if (text.isEmpty) return text;
    var fixed = text.replaceAllMapped(_shortVowelText, (match) {
      final pair = switch (match.group(1)) {
        'a' => vowelPairs[fatha],
        'i' => vowelPairs[kasra],
        'u' => vowelPairs[damma],
        _ => null,
      };
      // Esrede iki ses aynı olduğu için metin olduğu gibi kalır.
      if (pair == null || pair.heavy == pair.thin) return match.group(0)!;
      return "kalın harflerde kısa '${pair.heavy}', "
          "ince harflerde kısa '${pair.thin}'${match.group(2)}";
    });
    fixed = fixed.replaceAll(_tenvinText, '-an/-en, -in, -un');
    return fixed;
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
