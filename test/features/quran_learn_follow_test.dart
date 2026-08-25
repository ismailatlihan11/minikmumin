import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_follow.dart';

void main() {
  test('splits a surah so longer ayahs keep the highlight longer', () {
    const verses = [
      'قُلْ',
      'هُوَ اللَّهُ أَحَدٌ',
      'وَلَا الضَّالِّينَ',
    ];
    final spans = QuranLearnFollowTimeline.fromArabic(
      verses,
      const Duration(seconds: 10),
    );
    expect(spans, hasLength(3));
    expect(spans.first.start, Duration.zero);
    expect(spans.last.end, const Duration(seconds: 10));
    expect(spans[0].end, lessThan(spans[1].end - spans[1].start));
    expect(
      spans[2].end - spans[2].start,
      greaterThan(spans[0].end - spans[0].start),
    );
    expect(spans.every((span) => span.wordIndex == null), isTrue);
  });

  test('picks the ayah at the current playback position', () {
    final spans = QuranLearnFollowTimeline.fromArabic(
      const ['ا', 'ب ب', 'ج ج ج'],
      const Duration(milliseconds: 900),
    );
    expect(QuranLearnFollowTimeline.indexAt(spans, Duration.zero), 0);
    expect(
      QuranLearnFollowTimeline.indexAt(spans, const Duration(milliseconds: 899)),
      2,
    );
    expect(
      QuranLearnFollowTimeline.indexAt(spans, const Duration(seconds: 2)),
      2,
    );
  });

  test('empty verses yield no cues', () {
    expect(
      QuranLearnFollowTimeline.fromArabic(const [], const Duration(seconds: 3)),
      isEmpty,
    );
    expect(QuranLearnFollowTimeline.indexAt(const [], Duration.zero), -1);
  });
}
