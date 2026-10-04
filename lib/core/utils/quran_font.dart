/// Diyanet'in "Shaikh Hamdullah Mushaf" fontu bazı işaretleri standart
/// Unicode yerine kendi kod noktalarında tutuyor. `kuran.json` standart
/// Unicode olduğu için metin çizilmeden önce bu fonta çevrilir.
/// Fontta karşılığı olmayan işaretler (ق, قف vakıf; 08D1, 08D2) olduğu gibi
/// kalır ve [fallback] fonttan çizilir.
abstract final class QuranFont {
  static const String family = 'Hamdullah';
  static const List<String> fallback = ['NotoNaskhArabic'];

  static const Map<int, String> _map = {
    0x06CC: '\u064A', // Farsça ye -> ye (font son hâlini noktasız çizer)
    0x0656: '\u06EA', // alt dikey elif (esre-i memdûde)
    0x0615: '\u06DC', // küçük ط (vakf-ı mutlak)
    0x0617: '\u06D8', // küçük ز (vakf-ı mücavvez)
    0x06D8: '\u06E2', // küçük م (vakf-ı lâzım)
    0x08D5: '\u06D6', // küçük ص (vakf-ı murahhas)
    0x08D6: '\u06DF', // küçük ع (rükû)
    0x08D9: '\u06E8', // alttaki küçük nûn (nûn-u ıvaz)
    0x06DC: '\u06D4', // sekte
    0x06EA: '\u06ED\u06D9', // imâle (Hûd 41)
    0x06EB: '\u06ED\u06D6', // işmâm (Yûsuf 11)
    0x06EC: '\u06ED\u06D8', // teshîl (Fussilet 44)
    0x06ED: '\u06ED\u06D7', // idğâm (Hûd 42)
  };

  static String encode(String text) {
    final out = StringBuffer();
    for (final rune in text.runes) {
      final mapped = _map[rune];
      if (mapped != null) {
        out.write(mapped);
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }
}
