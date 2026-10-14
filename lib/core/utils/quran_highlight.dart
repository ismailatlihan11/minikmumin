import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// Diyanet mushafındaki Allah lafzı / Rab / vakıf kırmızısı.
const kQuranRed = Color(0xFFDF1C40);
const kQuranRedDark = Color(0xFFFF5C7A);

Color quranRedFor(Brightness brightness) =>
    brightness == Brightness.dark ? kQuranRedDark : kQuranRed;

/// Allah lafzı: اللّٰه / لِلّٰه / بِاللّٰه … hepsi "لّٰه" içerir.
/// اللّٰهُمَّ Diyanet mushafında siyahtır.
bool isAllahWord(String word) =>
    word.contains('\u0644\u0651\u0670\u0647') &&
    !word.contains('\u0644\u0651\u0670\u0647\u064F\u0645');

final _diacritics = RegExp(
    '[\u064B-\u0650\u0652-\u065F\u0670\u06D6-\u06ED\u0615\u08D3-\u08FF]');
final _rabb = RegExp('^(?:فو|ف|و|ال|ا)?[بلك]?ربّ');
final _notRabb = RegExp('ربّان|ربّيان|ربّيّون');

/// "Rab" kelimesi (رَبِّ، رَبَّنَا، بِرَبِّهِمْ …); رَبَّانِيُّونَ ve
/// رَبَّيَانِي (yetiştirdiler) hariç.
bool isRabbWord(String word) {
  final s = word.replaceAll(_diacritics, '');
  return _rabb.hasMatch(s) && !_notRabb.hasMatch(s);
}

/// Diyanet mushafında Rab kelimesinin Allah'ı kastetmediği için siyah
/// bırakıldığı yerler: (sure, ayet) → ayetteki kaçıncı Rab kelimesi.
const _blackRabb = <(int, int), Set<int>>{
  (12, 23): {0},
  (12, 41): {0},
  (12, 42): {0, 1},
  (12, 50): {0},
  (79, 24): {0},
};

/// Allah lafzını ve Rab kelimesini kırmızı yapar. Vakıf işaretleri burada
/// renklenmez; renkleri `AbayRenkli` fontunun içinden gelir.
List<TextSpan> quranHighlightSpans(
  String text,
  Color highlight, {
  int sure = 0,
  int ayah = 0,
}) {
  final red = TextStyle(color: highlight);
  final blackRabb = _blackRabb[(sure, ayah)] ?? const <int>{};
  var rabbIndex = 0;
  final spans = <TextSpan>[];
  final plain = StringBuffer();

  for (final token in text.split(RegExp(r'(?<=\s)|(?=\s)'))) {
    final wholeRed = isAllahWord(token) ||
        (isRabbWord(token) && !blackRabb.contains(rabbIndex++));
    if (!wholeRed) {
      plain.write(token);
      continue;
    }
    if (plain.isNotEmpty) {
      spans.add(TextSpan(text: plain.toString()));
      plain.clear();
    }
    spans.add(TextSpan(text: token, style: red));
  }
  if (plain.isNotEmpty) spans.add(TextSpan(text: plain.toString()));
  return spans;
}
