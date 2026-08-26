import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_memory_page.dart';

void main() {
  test('current harf eşleştir board is the medium level', () {
    expect(QuranLearnMemoryLevel.medium.pairCount, 6);
    expect(QuranLearnMemoryLevel.medium.columns, 3);
    expect(QuranLearnMemoryLevel.medium.xp, 6);
  });

  test('easy is smaller and hard is larger than the current board', () {
    expect(QuranLearnMemoryLevel.easy.pairCount, 4);
    expect(QuranLearnMemoryLevel.easy.columns, 2);
    expect(QuranLearnMemoryLevel.hard.pairCount, 8);
    expect(QuranLearnMemoryLevel.hard.columns, 4);
  });
}
