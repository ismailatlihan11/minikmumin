import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/search/search_index.dart';

void main() {
  test('parses surah + ayah queries', () {
    for (final query in [
      'furkan 69',
      'Furkân 69',
      'Furkân Suresi 69',
      'furkan sûresi 69',
      'furkan69',
      '25:69',
      '25 69',
      '25.69',
    ]) {
      final ref = QuranRef.parse(query);
      expect(ref?.surahId, 25, reason: query);
      expect(ref?.ayahNo, 69, reason: query);
    }
    expect(QuranRef.parse('bakara 7')?.surahId, 2);
    expect(QuranRef.parse('ali imran 5')?.surahId, 3);
    expect(QuranRef.parse('Âl-i İmrân 5')?.surahId, 3);
    expect(QuranRef.parse('yasin 1')?.surahId, 36);
    expect(QuranRef.parse('ahzab 21')?.surahId, 33);
  });

  test('ignores plain words and unknown names', () {
    expect(QuranRef.parse('yasin'), isNull);
    expect(QuranRef.parse('namaz 5'), isNull);
    expect(QuranRef.parse('255'), isNull);
    expect(QuranRef.parse('200:1'), isNull);
  });

  test('pins the ayah first in search results', () {
    Widget page(BuildContext _) => const SizedBox();
    final entries = [
      SearchEntry(
        kind: SearchKind.quran,
        title: 'Furkân Sûresi',
        subtitle: '25. sûre',
        body: '',
        surahId: 25,
        page: page,
      ),
      for (final no in [68, 69, 70])
        SearchEntry(
          kind: SearchKind.quran,
          title: 'Furkân Sûresi, $no. ayet',
          subtitle: 'meal $no',
          body: 'meal $no',
          surahId: 25,
          ayahNo: no,
          matchTitle: false,
          page: page,
        ),
    ];

    final named = searchEntries(entries, 'furkan 69');
    expect(named.first.entry.ayahNo, 69);
    expect(named.map((h) => h.entry.title), contains('Furkân Sûresi'));

    final numeric = searchEntries(entries, '25:69');
    expect(numeric.map((h) => h.entry.title),
        ['Furkân Sûresi, 69. ayet', 'Furkân Sûresi']);

    expect(searchEntries(entries, 'furkan').first.entry.title, 'Furkân Sûresi');
  });
}
