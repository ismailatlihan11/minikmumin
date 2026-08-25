/// Ayah-timed follow-along cues. Word-level sync can fill [wordIndex] later.
class QuranLearnFollowSpan {
  const QuranLearnFollowSpan({
    required this.ayahIndex,
    required this.start,
    required this.end,
    this.wordIndex,
  });

  final int ayahIndex;
  final Duration start;
  final Duration end;

  /// Reserved for later word karaoke. Null means the whole ayah.
  final int? wordIndex;
}

abstract final class QuranLearnFollowTimeline {
  static List<QuranLearnFollowSpan> fromArabic(
    List<String> verses,
    Duration total,
  ) {
    if (verses.isEmpty) return const [];
    final safeTotal = total <= Duration.zero
        ? Duration(milliseconds: 1200 * verses.length)
        : total;
    final weights = [for (final verse in verses) audioWeight(verse)];
    final sum = weights.fold<int>(0, (a, b) => a + b);
    final totalMs = safeTotal.inMilliseconds;
    var elapsed = 0;
    final spans = <QuranLearnFollowSpan>[];
    for (var i = 0; i < verses.length; i++) {
      final share = i == verses.length - 1
          ? totalMs - elapsed
          : (totalMs * weights[i] / sum).round();
      final start = Duration(milliseconds: elapsed);
      elapsed += share < 1 ? 1 : share;
      spans.add(
        QuranLearnFollowSpan(
          ayahIndex: i,
          start: start,
          end: Duration(milliseconds: elapsed.clamp(0, totalMs)),
        ),
      );
    }
    if (spans.isNotEmpty) {
      spans[spans.length - 1] = QuranLearnFollowSpan(
        ayahIndex: spans.last.ayahIndex,
        start: spans.last.start,
        end: safeTotal,
        wordIndex: spans.last.wordIndex,
      );
    }
    return spans;
  }

  static int indexAt(List<QuranLearnFollowSpan> spans, Duration position) {
    if (spans.isEmpty) return -1;
    for (final span in spans) {
      if (position < span.end) return span.ayahIndex;
    }
    return spans.last.ayahIndex;
  }

  /// Letter-weighted length so longer ayahs keep the highlight longer.
  static int audioWeight(String arabic) {
    var weight = 0;
    for (final code in arabic.runes) {
      if (_isArabicLetter(code)) {
        weight += 2;
        if (_maddLetters.contains(code)) weight += 1;
      } else if (code == 0x0651) {
        weight += 1;
      }
    }
    return weight < 1 ? 1 : weight;
  }

  static const _maddLetters = {0x0627, 0x0622, 0x0649, 0x0648, 0x064A};

  static bool _isArabicLetter(int code) {
    if (code >= 0x0621 && code <= 0x063A) return true;
    if (code >= 0x0641 && code <= 0x064A) return true;
    return code == 0x0629 || code == 0x0649 || code == 0x06CC;
  }
}
