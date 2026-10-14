import 'quran_arabic.dart';

/// Kur'an Arapçası: Abay (KuranKerimFontAbay / Emine). Riyazus Salihin ile
/// aynı yamalı font. `AbayRenkli` vakıf/tecvid işaretlerini ve meddeyi
/// Diyanet mushafındaki gibi kırmızı çizer (COLR).
abstract final class QuranFont {
  static const String family = 'AbayRenkli';
  static const List<String> fallback = ['NotoNaskhArabic'];

  /// Fâtiha 1 ile aynı besmele. `الرَّحْمٰن` şedde + üstün sırasındadır;
  /// `رَ + ّ` sırası Abay'da harekeyi kaydırır.
  static const String basmala = kQuranBasmala;

  /// Hafs özel tecvid etiketleri (Abay/Emine glifleri).
  static const String ishmam = kQuranIshmam;
  static const String imale = kQuranImale;
  static const String tasheel = kQuranTasheel;
  static const String idgham = kQuranIdgham;
  static const String medLabel = kQuranMedLabel;

  /// Ekran shaping'i için Unicode birleşim sırası. JSON dosyası değişmez.
  /// [sure]/[ayah] verilirse Diyanet mushafında farklı basılmış işaretler
  /// de düzeltilir.
  static String format(String text, {int sure = 0, int ayah = 0}) =>
      formatQuranArabic(text, sure: sure, ayah: ayah);
}
