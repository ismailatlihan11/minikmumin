/// Unicode RTL isolate. Flutter `TextAlign.justify` ve LTR ebeveyn
/// bazı Android sürümlerinde Arapça paragrafı LTR çizer; ayet soldan
/// `وَلَقَدْ` ile başlar. RLI…PDI metni bidi motora RTL kilitler.
const kRtlIsolateStart = '\u2067';
const kRtlIsolateEnd = '\u2069';

/// Fâtiha 1 ile aynı besmele. `الرَّحْمٰن` şedde + üstün sırasındadır;
/// `رَ + ّ` sırası Abay'da harekeyi kaydırır.
const kQuranBasmala =
    'بِسْمِ اللّٰهِ الر\u0651\u064Eحْمٰنِ الر\u0651\u064Eحٖيمِ';

String isolateRtl(String text) {
  if (text.isEmpty) return text;
  final stripped = text
      .replaceAll(kRtlIsolateStart, '')
      .replaceAll(kRtlIsolateEnd, '');
  return '$kRtlIsolateStart$stripped$kRtlIsolateEnd';
}

/// Hafs özel tecvid etiketleri (Abay/Emine glifleri).
/// JSON işmamı med noktası (`U+06EB` / madpoint) ile yazmış; imâle,
/// teshîl ve idğâm da vakıf/meem işaretine düşmüş. JSON değişmez.
const kQuranIshmam = '\u08D0';
const kQuranImale = '\u08D3';
const kQuranTasheel = '\u08D4';
const kQuranIdgham = '\u08D8';
const kQuranMedLabel = '\u08DA';

/// Ekran shaping'i için Unicode birleşim sırası. JSON dosyası değişmez.
/// Kur'an işaretleri (U+0653, U+0670, U+06EA/EB/EC, U+06DA) başka karaktere
/// çevrilmez — istisna: Hafs etiketleri, Abay'da olmayan işaretler
/// (`_abayMarkAliases`), elif+çeker+medde (`_fixAlefDaggerMaddah`) ve
/// mushafla farklı ayetler (`_pdfMarkFixes`).
///
/// U+0653 medde: mushafta med, önceki harfin üst harekesinin (şedde
/// yığını dahil) hemen üstünde durur ve taşıyıcıya doğru uzanır. Medde
/// bu yüzden elif/vav/ye'nin önüne, harekenin arkasına alınır
/// (`قَالُٓوا`, `اِنّ۪ٓي`); Abay mkmk'si onu harekenin üstüne oturtur.
/// Üst harekesiz yığında (`ف۪يٓ`) medde taşıyıcının üstünde kalır.
/// `حَتّٰٓى` gibi ٰ+ٓ yığınında medde yerinde kalır.
/// `الٓمٓ` mukattaa durur (medde zaten harfin üstünde).
String formatQuranArabic(String text, {int sure = 0, int ayah = 0}) {
  if (text.isEmpty) return text;
  text = _applyPdfMarkFixes(text, sure, ayah);
  text = _applySpecialTajweedLabels(text);
  // ۜ (U+06DC) HarfBuzz'da "modifier combining mark": harekenin önüne
  // taşınır ve vakıf ط'si harekenin üstüne değil içine oturur. Abay'da
  // aynı ط glifi olan ؕ (U+0615) yerinde kalır.
  text = text.replaceAll('\u06DC', '\u0615');
  // Abay'da olmayan Extended-A vakıf/tecvid işaretleri yedek fonta düşer
  // (renksiz, yanlış yükseklik); Abay'daki aynı glifin kod noktasına çevrilir.
  for (final e in _abayMarkAliases.entries) {
    text = text.replaceAll(e.key, e.value);
  }
  text = _fixAlefDaggerMaddah(text);
  final hasMaddah = text.contains('\u0653');
  final hasFarsiYeh = text.contains('\u06CC');
  if (!hasMaddah && !hasFarsiYeh) return text;

  final out = StringBuffer();
  final units = text.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final cu = units[i];
    if (cu == 0x06CC) {
      out.writeCharCode(0x064A);
      continue;
    }
    if (cu == 0x0653 &&
        i + 1 < units.length &&
        _isMaddCarrier(units[i + 1]) &&
        !_precededByMaddCarrier(units, i) &&
        !_markStackHasSuperscriptAlef(units, i)) {
      var carrier = units[i + 1];
      if (carrier == 0x06CC) carrier = 0x064A;
      out.writeCharCode(carrier);
      out.writeCharCode(0x0653);
      i++;
      continue;
    }
    out.writeCharCode(cu);
  }
  return out.toString().replaceAllMapped(
        _maddAfterCarrier,
        (m) => '${m[1]}\u0653${m[2]}',
      );
}

final _maddAfterCarrier = RegExp(
  '([\u064B\u064C\u064E\u064F\u0651\u0652\u0670][\u06EA\u0656]?)'
  '([\u0627\u0648\u064A\u0649])\u0653',
);

/// Elif + çeker (U+0670) + medde (U+0653): Unicode NFC bunu `آٰ` yapar.
/// Abay `آ` (= alefmadda) glifinde çeker dy=-750 ile meddenin içine biner.
/// Lam üstündeki `لٰٓ` doğru; elifte composition olmasın diye meddeyi
/// Abay'ın `آ` içinde de kullandığı U+06E4 (smallmadda) ile değiştiririz.
/// Kur'an'da 9 yer (Mâide 2 آمين, En'âm 143–144, …).
String _fixAlefDaggerMaddah(String text) {
  if (!text.contains('\u0670')) return text;
  // NFC formu: آ + ٰ
  text = text.replaceAll('\u0622\u0670', 'ا\u0670\u06E4');
  // JSON / NFD formu: ا + ٰ + ٓ
  text = text.replaceAll('ا\u0670\u0653', 'ا\u0670\u06E4');
  return text;
}

/// Yusuf 11 işmam, Hûd 41 imâle, Fussilet 44 teshîl, Hûd 42 idğâm,
/// Furkan 69 tek uzatılan `فيه` (`مد` etiketi he'nin altında).
String _applySpecialTajweedLabels(String text) {
  if (!text.contains('\u06EB') &&
      !text.contains('\u06ED') &&
      !text.contains('ف\u06EAيه\u06EA')) {
    return text;
  }
  return text
      .replaceAll('تَاْمَنَّ\u06EBا', 'تَاْمَنَّ${kQuranIshmam}ا')
      .replaceAll('مَجْرٰ\u06ED\u06D9يهَا', 'مَجْرٰ${kQuranImale}يهَا')
      .replaceAll('ءَاَ\u06ED\u06D8عْجَمِيٌّ', 'ءَاَ${kQuranTasheel}عْجَمِيٌّ')
      .replaceAll('ارْكَبْ\u06ED\u06D7', 'ارْكَبْ$kQuranIdgham')
      .replaceAll('ف\u06EAيه\u06EA', 'ف\u06EAيهِ$kQuranMedLabel');
}

const _abayMarkAliases = {
  '\u08D5': '\u06D6', // ص  highsad
  '\u08D6': '\u06DF', // ع  highain
  '\u0617': '\u06D8', // ز  highzain
  '\u08D7': '\u06D7', // ق  highqaf
  '\u08DE': '\u06E0', // قف highqaf.feh
  '\u08D9': '\u06E8', // ࣙ  lownoonkasra
  // Abay U+08D1/08D2'yi alt hemze çizer; Diyanet mushafında bunlar
  // "قصر" ve "مد" notudur.
  '\u08D1': '\u06EC', // قصر kasrpoint
  '\u08D2': '\u06EB', // مد  madpoint
};

/// Diyanet mushafında (kurani_kerim.pdf) vakıf/tecvid işareti JSON'dan farklı
/// basılmış ayetler. JSON değişmez; yalnız ekranda PDF'teki işaret gösterilir.
String _applyPdfMarkFixes(String text, int sure, int ayah) {
  if (_lazimMeemAyahs.contains((sure, ayah))) {
    text = text.replaceFirst('\u06D8', '\u06E2');
  }
  final fixes = _pdfMarkFixes[(sure, ayah)];
  if (fixes == null) return text;
  for (final (from, to) in fixes) {
    text = text.replaceFirst(from, to);
  }
  return text;
}

/// JSON'da ز (U+06D8) yazılmış ama mushafta lâzım durak "م" olan yerler.
const _lazimMeemAyahs = <(int, int)>{
  (2, 145), (2, 246), (2, 258), (2, 275), (3, 7), (3, 181), (5, 110),
  (7, 73), (7, 163), (9, 67), (9, 71), (20, 39), (23, 19),
};

const _pdfMarkFixes = <(int, int), List<(String, String)>>{
  (2, 259): [
    ('ي\u064Eت\u064Eس\u064Eن\u0651\u064Eه\u0652\u06DA', 'ي\u064Eت\u064Eس\u064Eن\u0651\u064Eه\u0652\u06DC'), // ج → ط
  ],
  (7, 44): [
    ('الظ\u0651\u064Eال\u0650م\u06EAين\u064E\u06D9', 'الظ\u0651\u064Eال\u0650م\u06EAين\u064E'), // − لا
  ],
  (7, 128): [
    ('ل\u0650ل\u0651\u0670ه\u0650\u06E0', 'ل\u0650ل\u0651\u0670ه\u0650\u06DA'), // قف → ج
  ],
  (9, 60): [
    ('و\u064Eال\u0652م\u064Fؤ\u064E\u06ECل\u0651\u064Eف\u064Eة\u0650', 'و\u064Eال\u0652م\u064Fؤ\u064Eل\u0651\u064Eف\u064Eة\u0650'), // − قصر
  ],
  (11, 46): [
    ('ص\u064Eال\u0650ح\u064D\u06D7', 'ص\u064Eال\u0650ح\u064D\u06D8'), // ق → ز
  ],
  (14, 44): [
    ('ال\u0652ع\u064Eذ\u064Eاب\u064F', 'ال\u0652ع\u064Eذ\u064Eاب\u064F\u06D9'), // + لا
  ],
  (15, 49): [
    ('ا\u064Eن\u064Eا\u06EC', 'ا\u064Eن\u064Eا'), // − قصر
  ],
  (16, 90): [
    ('و\u064Eا\u0656یت\u064E\u0653ائ\u0650', 'و\u064Eا\u0656یت\u064E\u06EC\u0653ائ\u0650'), // + قصر
  ],
  (17, 106): [
    ('ل\u0650ت\u064Eق\u0652ر\u064Eا\u064Eه\u064F\u06EB', 'ل\u0650ت\u064Eق\u0652ر\u064Eا\u064Eه\u064F'), // − مد
  ],
  (18, 23): [
    ('ل\u0650ش\u064Eا\u06ECي\u0652ء\u064D', 'ل\u0650ش\u064Eاي\u0652ء\u064D'), // − قصر
  ],
  (19, 77): [
    ('ل\u064Eا\u064Fوت\u064Eي\u064Eن\u0651\u064E', 'ل\u064Eا\u064Fو\u06EBت\u064Eي\u064Eن\u0651\u064E'), // + مد
  ],
  (20, 21): [
    ('ال\u0652ا\u064Fول\u0670ى', 'ال\u0652ا\u064Fو\u06EBل\u0670ى'), // + مد
  ],
  (20, 48): [
    ('ا\u064Fوح\u0650ي\u064E', 'ا\u064Fو\u06EBح\u0650ي\u064E'), // + مد
  ],
  (20, 51): [
    ('ال\u0652ا\u064Fول\u0670ى', 'ال\u0652ا\u064Fو\u06EBل\u0670ى'), // + مد
  ],
  (20, 94): [
    ('ی\u064Eب\u0652ن\u064Eؤ\u064F\u08D1م\u0651\u064E', 'ی\u064Eب\u0652ن\u064Eؤ\u064Fم\u0651\u064E'), // − قصر
  ],
  (23, 24): [
    ('ال\u0652م\u064Eل\u064Eؤ\u064F\u06ECا', 'ال\u0652م\u064Eل\u064Eؤ\u064Fا'), // − قصر
  ],
  (26, 116): [
    ('ت\u064Eن\u0652ت\u064Eه\u0650', 'ت\u064Eن\u0652ت\u064E\u06ECه\u0650'), // + قصر
  ],
  (26, 167): [
    ('ت\u064Eن\u0652ت\u064Eه\u0650', 'ت\u064Eن\u0652ت\u064E\u06ECه\u0650'), // + قصر
  ],
  (27, 9): [
    ('ا\u064Eن\u064Eا\u06EC', 'ا\u064Eن\u064Eا'), // − قصر
  ],
  (27, 92): [
    ('ا\u064Eت\u0652ل\u064Fو\u064E\u06ECا', 'ا\u064Eت\u0652ل\u064Fو\u064Eا'), // − قصر
  ],
  (28, 30): [
    ('ا\u064Eن\u064Eا\u06EC', 'ا\u064Eن\u064Eا'), // − قصر
  ],
  (34, 34): [
    ('م\u064Fت\u0652ر\u064Eف\u064Fوه\u064E\u0653ا\u06D9', 'م\u064Fت\u0652ر\u064Eف\u064Fوه\u064E\u0653ا'), // − لا
  ],
  (37, 106): [
    ('ال\u0652ب\u064Eل\u0670\u0653ؤ\u064F\u06ECا', 'ال\u0652ب\u064Eل\u0670\u0653ؤ\u064Fا'), // − قصر
  ],
  (38, 67): [
    ('ن\u064Eب\u064Eؤ\u064C\u06ECا', 'ن\u064Eب\u064Eؤ\u064Cا'), // − قصر
  ],
  (48, 5): [
    ('ع\u064Eظ\u0656یم\u064Bا', 'ع\u064Eظ\u0656یم\u064Bا\u06D9'), // + لا
  ],
  (50, 29): [
    ('ل\u0650ل\u0652ع\u064Eب\u06EAيد\u0650\u06DA', 'ل\u0650ل\u0652ع\u064Eب\u06EAيد\u0650\u06DF'), // ج → ع
  ],
  (64, 7): [
    ('ل\u064Eت\u064Fن\u064Eب\u0651\u064Eؤ\u064F\u06ECن\u0651\u064E', 'ل\u064Eت\u064Fن\u064Eب\u0651\u064Eؤ\u064Fن\u0651\u064E'), // − قصر
  ],
  (74, 15): [
    ('ا\u064Eز\u06EAيد\u064E\u06D9', 'ا\u064Eز\u06EAيد\u064E\u06D7'), // لا → ق
  ],
  (80, 22): [
    ('ا\u064Eن\u0652ش\u064Eر\u064Eه\u064F', 'ا\u064Eن\u0652ش\u064Eر\u064Eه\u064F\u06DC'), // + ط
  ],
  (80, 23): [
    ('ا\u064Eم\u064Eر\u064Eه\u064F\u06D9', 'ا\u064Eم\u064Eر\u064Eه\u064F\u06DC'), // لا → ط
  ],
  (83, 6): [
    ('ال\u0652ع\u064Eال\u064Eم\u06EAين\u064E\u06DC', 'ال\u0652ع\u064Eال\u064Eم\u06EAين\u064E\u06DA'), // ط → ج
  ],
  (83, 35): [
    ('ال\u0652ا\u064Eر\u064E\u0653ائ\u0650ك\u0650', 'ال\u0652ا\u064Eر\u064E\u0653ائ\u0650ك\u0650\u06D9'), // + لا
  ],
  (99, 6): [
    ('ا\u064Eش\u0652ت\u064Eات\u064Bا\u06D9', 'ا\u064Eش\u0652ت\u064Eات\u064Bا'), // − لا
  ],
  (104, 1): [
    ('ل\u064Fم\u064Eز\u064Eة\u064D\u06D9', 'ل\u064Fم\u064Eز\u064Eة\u064D\u06E8\u06D9'), // + ن
  ],
};

const kashidaChar = '\u0640';

bool isArabicCombiningMark(int cu) {
  return (cu >= 0x0610 && cu <= 0x061A) ||
      (cu >= 0x064B && cu <= 0x065F) ||
      cu == 0x0670 ||
      (cu >= 0x06D6 && cu <= 0x06ED) ||
      (cu >= 0x08D0 && cu <= 0x08FF);
}

bool isDualJoiningLetter(int cu) {
  return cu == 0x0626 ||
      cu == 0x0628 ||
      (cu >= 0x062A && cu <= 0x062E) ||
      (cu >= 0x0633 && cu <= 0x063A) ||
      (cu >= 0x0641 && cu <= 0x0647) ||
      cu == 0x0649 ||
      cu == 0x064A ||
      cu == 0x06CC;
}

/// Kashida eklenecek dizinler (harften / harekelerinden hemen sonra).
/// Kelime sonuna tatweel konmaz.
List<int> kashidaInsertPoints(String word) {
  final points = <int>[];
  final units = word.codeUnits;
  for (var i = 0; i < units.length; i++) {
    if (!isDualJoiningLetter(units[i])) continue;
    var j = i + 1;
    while (j < units.length && isArabicCombiningMark(units[j])) {
      j++;
    }
    if (j >= units.length) continue;
    points.add(j);
    i = j - 1;
  }
  return points;
}

String insertKashidas(String word, int count) {
  final pts = kashidaInsertPoints(word);
  if (pts.isEmpty || count <= 0) return word;
  final extras = List<int>.filled(pts.length, 0);
  for (var i = 0; i < count; i++) {
    extras[i % pts.length]++;
  }
  final buf = StringBuffer();
  var prev = 0;
  for (var i = 0; i < pts.length; i++) {
    buf.write(word.substring(prev, pts[i]));
    if (extras[i] > 0) buf.write(kashidaChar * extras[i]);
    prev = pts[i];
  }
  buf.write(word.substring(prev));
  return buf.toString();
}

bool _isMaddCarrier(int cu) {
  return cu == 0x0627 || // ا
      cu == 0x0648 || // و
      cu == 0x06CC || // ی
      cu == 0x0649 || // ى
      cu == 0x064A || // ي
      cu == 0x0626 || // ئ
      cu == 0x0624; // ؤ
}

bool _precededByMaddCarrier(List<int> units, int maddIndex) {
  for (var j = maddIndex - 1; j >= 0; j--) {
    final cu = units[j];
    if (isArabicCombiningMark(cu)) continue;
    return _isMaddCarrier(cu);
  }
  return false;
}

bool _markStackHasSuperscriptAlef(List<int> units, int maddIndex) {
  for (var j = maddIndex - 1; j >= 0; j--) {
    final cu = units[j];
    if (cu == 0x0670) return true;
    if (!isArabicCombiningMark(cu)) return false;
  }
  return false;
}
