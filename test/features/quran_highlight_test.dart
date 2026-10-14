import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/utils/quran_highlight.dart';

void main() {
  const red = Color(0xFFDF1C40);

  List<(String, bool)> parts(String text, {int sure = 0, int ayah = 0}) => [
        for (final s
            in quranHighlightSpans(text, red, sure: sure, ayah: ayah))
          (s.text!, s.style?.color == red),
      ];

  test('Allah lafzı kelimesiyle kırmızı, diğer kelimeler düz', () {
    expect(parts('خَتَمَ اللّٰهُ عَلٰى'), [
      ('خَتَمَ ', false),
      ('اللّٰهُ', true),
      (' عَلٰى', false),
    ]);
    expect(parts('بِاللّٰهِ لِلّٰهِ').where((p) => p.$2).length, 2);
  });

  test('اللّٰهُمَّ mushaftaki gibi siyah', () {
    expect(parts('قُلِ اللّٰهُمَّ مَالِكَ').where((p) => p.$2), isEmpty);
  });

  test('vakıf işaretleri span ile bölünmez (renk fonttan gelir)', () {
    expect(parts('سَمْعِهِمْۜ وَعَلٰى'), [('سَمْعِهِمْۜ وَعَلٰى', false)]);
  });

  test('AbayRenkli: vakıf glifleri COLR ile kırmızı', () {
    final bytes = File('assets/fonts/KuranKerimFontAbayRenkli.ttf')
        .readAsBytesSync();
    final tags = String.fromCharCodes(bytes.sublist(0, 400));
    expect(tags, contains('COLR'));
    expect(tags, contains('CPAL'));
    // آ ligatürü: elif katmanı metin renginde, medde katmanı kırmızı.
    expect(latin1.decode(bytes, allowInvalid: true),
        contains('alefmadda.3.part1'));
  });

  test('Rab kelimesi kırmızı; rabbânî, ribbiyyûn, rabbayânî ve terabbus değil',
      () {
    for (final w in ['رَبِّ', 'رَبَّنَٓا', 'بِرَبِّهِمْ', 'فَوَرَبِّكَ', 'اَلِرَبِّكَ', 'رَبّ۪ي']) {
      expect(isRabbWord(w), isTrue, reason: w);
    }
    for (final w in ['الرَّبَّانِيُّونَ', 'رِبِّيُّونَ', 'رَبَّيَان۪ي', 'فَتَرَبَّصُوا', 'نُرَبِّكَ']) {
      expect(isRabbWord(w), isFalse, reason: w);
    }
  });

  test('Yûsuf 42: kralı kasteden Rab siyah', () {
    expect(
      parts('اذْكُرْن۪ي عِنْدَ رَبِّكَۘ فَاَنْسٰيهُ', sure: 12, ayah: 42)
          .where((p) => p.$2),
      isEmpty,
    );
    expect(parts('رَبِّكَۘ').single.$2, isTrue);
  });

  test('metin değişmeden birleşir', () {
    const ayah =
        'خَتَمَ اللّٰهُ عَلٰى قُلُوبِهِمْ وَعَلٰى سَمْعِهِمْۜ وَعَلٰٓى اَبْصَارِهِمْ غِشَاوَةٌۘ وَلَهُمْ عَذَابٌ عَظ۪يمٌ۟';
    expect(parts(ayah).map((p) => p.$1).join(), ayah);
  });

  test('tüm Kur\'an: 2699 Allah lafzı, 965 kırmızı Rab', () {
    final data = jsonDecode(File('assets/data/kuran.json').readAsStringSync());
    var allah = 0, rabb = 0;
    for (final a in data['ayet'] as List) {
      final text = a['metin']['arapca'] as String;
      for (final s in quranHighlightSpans(text, red,
          sure: a['sure_id'] as int, ayah: a['ayet_no'] as int)) {
        if (s.style?.color != red) continue;
        if (isAllahWord(s.text!)) {
          allah++;
        } else if (isRabbWord(s.text!)) {
          rabb++;
        }
      }
    }
    expect((allah, rabb), (2699, 965));
  });
}
