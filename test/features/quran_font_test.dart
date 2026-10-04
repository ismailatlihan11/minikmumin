import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/utils/quran_font.dart';

void main() {
  test('Hamdullah encoding maps Diyanet marks to font code points', () {
    expect(QuranFont.encode('الرَّحٖیمِ'), 'الرَّح\u06EAيمِ');
    expect(QuranFont.encode('عِوَجًۜا'), 'عِوَجً\u06D4ا');
    expect(QuranFont.encode('مَجْرٰ۪یهَا'), 'مَجْرٰ\u06ED\u06D9يهَا');
    expect(QuranFont.encode('\u0615\u0617\u06D8'), '\u06DC\u06D8\u06E2');
    expect(QuranFont.encode('\u08D7\u08DE'), '\u08D7\u08DE');
  });
}
