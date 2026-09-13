import 'elifba_models.dart' show elifbaStripMarks;

/// Tecvid derslerindeki kelime ve ifadelerin Türkçe okunuşu.
///
/// Tek harf + hareke için `ElifbaReading` kuralı yeterli, ama "مَنْ يَقُولُ"
/// gibi ifadelerde okunuş kuralla üretilemez: idğamda harfler birleşir,
/// iklâbda nun mim olur. Bu tablo hem JSON'daki hem de Kur'an serisinden
/// gelen örneklerin altına doğru okunuşu yazar.
String elifbaPhraseReading(String text) {
  final key = _normalize(text);
  if (key.isEmpty) return '';
  return _readings[key] ?? '';
}

/// Aynı ifade mushaf imlâsına göre farklı yazılabiliyor (أَنْبِئْهُمْ /
/// اَنْبِئْهُمْ). Hareke, uzatma ve durak işaretleri atılıp hemze ile elif
/// tek biçime indirilir.
String _normalize(String text) {
  final buffer = StringBuffer();
  for (final rune in elifbaStripMarks(text).runes) {
    // Durak, medde, alt elif (ٖ) mushaf imlâsı; anahtarda yok sayılır.
    if (rune >= 0x06D6 && rune <= 0x06ED) continue;
    if (rune == 0x0653 ||
        rune == 0x0654 ||
        rune == 0x0655 ||
        rune == 0x0656) {
      continue;
    }
    final char = String.fromCharCode(rune);
    buffer.write(switch (char) {
      'أ' || 'إ' || 'آ' || 'ٱ' => 'ا',
      'ى' || 'ی' => 'ي', // elif maksûre + Farsî ye → Arap ye
      'ئ' || 'ؤ' => 'ء',
      'ة' => 'ه',
      _ => char,
    });
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

const _readings = <String, String>{
  // İzhâr
  'من امن': 'men âmene',
  'من هاد': 'men hâd',
  'من هاده': 'men hâde',
  'عليم حكيم': 'alîmün hakîm',
  'انعمت': "en'amte",
  'كفوا احد': 'küfüven ehad',
  'من خوف': 'min havfin',
  // İdğam
  'من يقول': 'mey yekûlü',
  'من ربهم': 'mir rabbihim',
  'من يعمل': "mey ya'mel",
  'فمن يعمل': "femey ya'mel",
  'يكن له': 'yekül lehû',
  'فويل للمصلين': 'feveylül lil-musallîn',
  'من ربه': 'mir rabbihî',
  'عابد ما': 'âbidüm mâ',
  'حبل من': 'hablüm min',
  'ان نسينا': 'in nesînâ',
  'سنة ولا': 'sinetüv velâ',
  'سنه ولا': 'sinetüv velâ',
  'مما': 'mimmâ',
  'اضرب بعصاك': "ıdrib bi'asâke",
  'قل رب': 'kur rabbi',
  'قد تبين': 'kat tebeyyene',
  // İklâb
  'انبءهم': "embi'hüm",
  'سميع بصير': 'semîum basîr',
  'ترميهم بحجاره': 'termîhim bihicârah',
  // İhfâ
  'من تحتها': 'min tahtihâ',
  'انفسكم': 'enfüseküm',
  'من شر': 'min şerri',
  'ينقضون': 'yenkudûne',
  'عن صلاتهم': 'an salâtihim',
  'من قبلك': 'min kablike',
  'من سجيل': 'min siccîl',
  'من جوع': "min cû'",
  // Gunne
  'ان': 'inne',
  'ثم': 'sümme',
  'عم': 'amme',
  // Ra
  'رب': 'rabbi',
  'رسل': 'rusul',
  'رزق': 'rızk',
  'غير': 'ğayri',
  'الرحمن': 'er-rahmâni',
  // Lafzatullah
  'قال الله': 'kâlellâhu',
  'بسم الله': 'bismillâhi',
  'الله': 'Allâhu',
  // Vakıf ve durak işaretleri
  'الرحيم': 'er-rahîm',
  'العالمين': 'el-âlemîn',
  'عليهم': 'aleyhim',
  'ريبه فيه': 'raybe fîh',
  'ريب فيه': 'raybe fîh',
};
