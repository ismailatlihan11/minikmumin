import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

bool _containsWords(Uint8List font, List<int> words) {
  final bytes = ByteData.sublistView(font);
  for (var i = 0; i + words.length * 2 <= font.length; i += 2) {
    var match = true;
    for (var j = 0; j < words.length; j++) {
      if (bytes.getUint16(i + j * 2) != (words[j] & 0xFFFF)) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

void main() {
  final font = File('assets/fonts/KuranKerimFontAbay.ttf').readAsBytesSync();

  test('Abay stacks waqf marks on dammatan as low as on other harakat', () {
    // GPOS lookup 7 dammatan mark2 anchor (format 1, -28, 1096). Daha yüksek
    // değer ۘ / ۟ işaretlerini bir üst satıra aitmiş gibi gösterir.
    expect(_containsWords(font, [1, -28, 1096]), isTrue);
  });

  test('Abay runs mark-to-mark lookups in mkmk, not mark', () {
    // mkmk feature: FeatureParams 0, LookupCount 5, lookups 6, 7, 8, 9, 11.
    // mark içinde kalırlarsa vakıf işaretleri tenvinin çok üstüne çıkar.
    expect(_containsWords(font, [0, 5, 6, 7, 8, 9, 11]), isTrue);
  });
}
