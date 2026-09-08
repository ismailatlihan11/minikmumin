/// Harf adı / harf şekli ile ses dosyası kökü eşlemesi ve dosya yolu kuralları.
/// Flutter'a bağlı değildir; ses üretim ve denetim araçları da burayı okur.
library;

/// Harf adından ya da Arapça harften ses dosyası kökü (ör. "Sad" → "sad").
String? elifbaLetterStem(String glyphOrName) {
  final byName = elifbaAudioNames[glyphOrName.trim().toLowerCase()];
  if (byName != null) return byName;
  for (final rune in glyphOrName.runes) {
    final stem = elifbaAudioGlyphs[String.fromCharCode(rune)];
    if (stem != null) return stem;
  }
  return null;
}

/// Harfin adını söyleyen kayıt ("Sad").
String elifbaNamePath(String stem) =>
    'assets/audio/quran_learn/alphabet/$stem.mp3';

/// Harekeli hece kaydı ("sa", "si", "su", "es", "sse").
String elifbaSyllablePath(String stem, String haraka) =>
    'assets/audio/elifba/exercises/${stem}_$haraka.mp3';

/// Kelime ve ifade kaydı. Dosya adı okunuştan türetilir ("rabbenâ" →
/// rabbena.mp3), böylece aynı kelime iki kez üretilmez.
String? elifbaWordPath(String reading) {
  final slug = reading
      .toLowerCase()
      .replaceAll('â', 'a')
      .replaceAll('î', 'i')
      .replaceAll('û', 'u')
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (slug.isEmpty) return null;
  return 'assets/audio/elifba/words/$slug.mp3';
}

/// Harekenin kendi adını söyleyen kayıt ("üstün").
String elifbaMarkPath(String id) =>
    'assets/audio/quran_learn/harakat/$id.mp3';

/// İşaretli parçadaki hareke türü; işaret yoksa "name".
String elifbaHarakaOf(String marked) {
  if (marked.contains('ّ')) {
    if (marked.contains('ِ')) return 'shadda_kasra';
    if (marked.contains('ُ')) return 'shadda_damma';
    return 'shadda_fatha';
  }
  if (marked.contains('ْ')) return 'sukun';
  if (marked.contains('ً')) return 'fathatayn';
  if (marked.contains('ٍ')) return 'kasratayn';
  if (marked.contains('ٌ')) return 'dammatayn';
  if (marked.contains('ِ')) return 'kasra';
  if (marked.contains('ُ')) return 'damma';
  if (marked.contains('َ')) return 'fatha';
  return 'name';
}

const elifbaAudioNames = <String, String>{
  'elif': 'elif',
  'be': 'ba',
  'te': 'ta',
  'se': 'tha',
  'cim': 'jim',
  'ha': 'ha',
  'hı': 'kha',
  'hi': 'kha',
  'dal': 'dal',
  'zel': 'dhal',
  'ra': 'ra',
  'ze': 'zay',
  'sin': 'sin',
  'şın': 'shin',
  'sad': 'sad',
  'dad': 'dad',
  'tı': 'ta_heavy',
  'zı': 'za_heavy',
  'ayn': 'ayn',
  'gayın': 'ghayn',
  'gayn': 'ghayn',
  'fe': 'fa',
  'kaf': 'qaf',
  'kef': 'kaf',
  'lam': 'lam',
  'mim': 'mim',
  'nun': 'nun',
  'he': 'hah',
  'vav': 'waw',
  'ye': 'ya',
  'ya': 'ya',
};

const elifbaAudioGlyphs = <String, String>{
  'ا': 'elif',
  'أ': 'elif',
  'إ': 'elif',
  'ب': 'ba',
  'ت': 'ta',
  'ث': 'tha',
  'ج': 'jim',
  'ح': 'ha',
  'خ': 'kha',
  'د': 'dal',
  'ذ': 'dhal',
  'ر': 'ra',
  'ز': 'zay',
  'س': 'sin',
  'ش': 'shin',
  'ص': 'sad',
  'ض': 'dad',
  'ط': 'ta_heavy',
  'ظ': 'za_heavy',
  'ع': 'ayn',
  'غ': 'ghayn',
  'ف': 'fa',
  'ق': 'qaf',
  'ك': 'kaf',
  'ل': 'lam',
  'م': 'mim',
  'ن': 'nun',
  'ه': 'hah',
  'و': 'waw',
  'ي': 'ya',
  'ى': 'ya',
};
