import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/utils/quran_font.dart';
import 'package:minik_kalpler/data/models/quran_verse.dart';

void main() {
  test('format moves maddah after its carrier and keeps Quranic marks', () {
    const enam5 =
        'فَقَدْ كَذَّبُوا بِالْحَقِّ لَمَّا جَٓاءَهُمْؕ فَسَوْفَ یَاْتٖیهِمْ اَنْبٰٓؤُ\u08D1ا مَا كَانُوا بِهٖ یَسْتَهْزِؤُ\u08D2نَ';
    final text = QuranFont.format(enam5);
    expect(text, contains('جَا\u0653ءَهُمْ'));
    expect(text, contains('اَنْبٰٓؤُ\u08D1ا'));
    expect(text, contains('يَسْتَهْزِؤُ\u08D2نَ'));
    expect(text, contains('\u0656'));
    expect(text, contains('\u0615'));
    expect(text.contains('\u06CC'), isFalse);
    expect(QuranFont.format(text), text);
  });

  test('mukattaa and alef stacks keep maddah in place', () {
    expect(QuranFont.format('الٓمٓ'), 'الٓمٓ');
    expect(QuranFont.format('حَتّٰٓى'), 'حَتّٰٓى');
  });

  group('kuran.json special rules', () {
    final rows = (jsonDecode(File('assets/data/kuran.json').readAsStringSync())
        as Map<String, dynamic>)['ayet'] as List<dynamic>;
    String arabic(int surah, int ayah) {
      final row = rows
          .cast<Map<String, dynamic>>()
          .firstWhere((r) => r['sure_id'] == surah && r['ayet_no'] == ayah);
      return QuranFont.format(
          (row['metin'] as Map<String, dynamic>)['arapca'] as String);
    }

    test('basmala matches Fatiha 1 with shadda before fatha', () {
      expect(QuranFont.basmala, arabic(1, 1));
      expect(QuranFont.basmala, contains('ر\u0651\u064Eحْ'));
    });

    test('Yusuf 11 shows ishmam instead of the med-point', () {
      final text = arabic(12, 11);
      expect(text, contains('تَاْمَن\u0651\u064E\u08D0ا'));
      expect(text.contains('\u06EB'), isFalse);
    });

    test('Hud 41/42 and Fussilet 44 use Emine labels', () {
      expect(arabic(11, 41), contains('مَجْرٰ\u08D3يهَا'));
      expect(arabic(11, 42), contains('ارْكَبْ\u08D8'));
      expect(arabic(41, 44), contains('ءَاَ\u08D4عْجَمِي\u0651\u064C'));
    });

    test('Furqan 69 writes med under the heh of fihi', () {
      final text = arabic(25, 69);
      expect(text, contains('ف\u06EAيهِ\u08DA'));
      expect(text.contains('ف\u06EAيه\u06EA'), isFalse);
      expect(QuranFont.format(text), text);
    });

    test('ordinary med-point on waw stays', () {
      expect(QuranFont.format('اُو\u06EBتُوا'), 'اُو\u06EBتُوا');
      expect(QuranFont.format('دَاوُ\u06EBدُ'), 'دَاوُ\u06EBدُ');
    });
  });

  test('QuranVerse formats Arabic when loading kuran.json rows', () {
    final verse = QuranVerse.fromJson({
      'ayet_id': 794,
      'sure_id': 6,
      'ayet_no': 5,
      'sayfa': 127,
      'metin': {'arapca': 'جَٓاءَكَ فٖی', 'meal': 'test'},
    });
    expect(verse.arabic, 'جَا\u0653ءَكَ فٖي');
  });
}
