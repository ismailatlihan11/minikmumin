/// Kur'an Arapçası: Abay (KuranKerimFontAbay / Emine). Riyazus Salihin ile
/// aynı yamalı font; ٖ, U+08D1/08D2 ve ؕ doğrudan fontta çizilir.
abstract final class QuranFont {
  static const String family = 'Abay';
  static const List<String> fallback = ['NotoNaskhArabic'];

  /// Fâtiha 1 ile aynı besmele. `الرَّحْمٰن` şedde + üstün sırasındadır;
  /// `رَ + ّ` sırası Abay'da harekeyi kaydırır.
  static const String basmala =
      'بِسْمِ اللّٰهِ الر\u0651\u064Eحْمٰنِ الر\u0651\u064Eحٖيمِ';

  /// Hafs özel tecvid etiketleri (Abay/Emine glifleri).
  static const String ishmam = '\u08D0';
  static const String imale = '\u08D3';
  static const String tasheel = '\u08D4';
  static const String idgham = '\u08D8';
  static const String medLabel = '\u08DA';

  /// Ekran shaping'i için Unicode birleşim sırası. JSON dosyası değişmez.
  ///
  /// U+0653 medde veride bazen med harfinden önce gelir (`جَٓاءَكَ`).
  /// Birleşen işaret önceki tabana yapışır; meddeyi elif/vav/ye arkasına
  /// alırız (`جَآءَكَ`) ki GPOS onu doğru oturtsun. `حَتّٰٓى` gibi ٰ+ٓ
  /// yığınında ve `الٓمٓ` mukattaasında medde yerinde kalır.
  static String format(String text) {
    if (text.isEmpty) return text;
    text = _applySpecialTajweedLabels(text);
    if (!text.contains('\u0653') && !text.contains('\u06CC')) return text;

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
    return out.toString();
  }

  /// JSON işmâmı med noktasıyla (U+06EB), imâle/teshîl/idğâmı vakıf
  /// işaretiyle yazmış. Yusuf 11 işmâm, Hûd 41 imâle, Fussilet 44 teshîl,
  /// Hûd 42 idğâm, Furkan 69 `فيه` (`مد` etiketi he'nin altında).
  static String _applySpecialTajweedLabels(String text) {
    if (!text.contains('\u06EB') &&
        !text.contains('\u06ED') &&
        !text.contains('ف\u06EAيه\u06EA')) {
      return text;
    }
    return text
        .replaceAll('تَاْمَن\u0651\u064E\u06EBا', 'تَاْمَن\u0651\u064E$ishmamا')
        .replaceAll('مَجْرٰ\u06ED\u06D9يهَا', 'مَجْرٰ$imaleيهَا')
        .replaceAll('ءَاَ\u06ED\u06D8عْجَمِي\u0651\u064C',
            'ءَاَ$tasheelعْجَمِي\u0651\u064C')
        .replaceAll('ارْكَبْ\u06ED\u06D7', 'ارْكَبْ$idgham')
        .replaceAll('ف\u06EAيه\u06EA', 'ف\u06EAيهِ$medLabel');
  }

  static bool _isCombiningMark(int cu) {
    return (cu >= 0x0610 && cu <= 0x061A) ||
        (cu >= 0x064B && cu <= 0x065F) ||
        cu == 0x0670 ||
        (cu >= 0x06D6 && cu <= 0x06ED) ||
        (cu >= 0x08D0 && cu <= 0x08FF);
  }

  static bool _isMaddCarrier(int cu) {
    return cu == 0x0627 || // ا
        cu == 0x0648 || // و
        cu == 0x06CC || // ی
        cu == 0x0649 || // ى
        cu == 0x064A || // ي
        cu == 0x0626 || // ئ
        cu == 0x0624; // ؤ
  }

  static bool _precededByMaddCarrier(List<int> units, int maddIndex) {
    for (var j = maddIndex - 1; j >= 0; j--) {
      final cu = units[j];
      if (_isCombiningMark(cu)) continue;
      return _isMaddCarrier(cu);
    }
    return false;
  }

  static bool _markStackHasSuperscriptAlef(List<int> units, int maddIndex) {
    for (var j = maddIndex - 1; j >= 0; j--) {
      final cu = units[j];
      if (cu == 0x0670) return true;
      if (!_isCombiningMark(cu)) return false;
    }
    return false;
  }
}
