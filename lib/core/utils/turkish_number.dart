abstract final class TurkishNumber {
  static const _ones = [
    '',
    'bir',
    'iki',
    'üç',
    'dört',
    'beş',
    'altı',
    'yedi',
    'sekiz',
    'dokuz',
  ];
  static const _tens = [
    '',
    'on',
    'yirmi',
    'otuz',
    'kırk',
    'elli',
    'altmış',
    'yetmiş',
    'seksen',
    'doksan',
  ];
  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String words(int value) {
    if (value == 0) return 'sıfır';
    if (value < 0) return '';
    final parts = <String>[];
    final hundreds = value ~/ 100;
    final rest = value % 100;
    if (hundreds == 1) {
      parts.add('yüz');
    } else if (hundreds > 1) {
      parts.add('${_ones[hundreds]} yüz');
    }
    if (rest >= 10) {
      parts.add(_tens[rest ~/ 10]);
      final one = rest % 10;
      if (one != 0) parts.add(_ones[one]);
    } else if (rest > 0) {
      parts.add(_ones[rest]);
    }
    return parts.join(' ');
  }

  static String arabicIndic(int value) {
    return value.abs().toString().split('').map((digit) {
      return _arabicDigits[int.parse(digit)];
    }).join();
  }

  static String pageLabel(int displayNumber) => '$displayNumber. sayfa';
}
