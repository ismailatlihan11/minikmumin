import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/search/search_index.dart';

SearchEntry _entry(
  SearchKind kind,
  String title, {
  String body = '',
  bool matchTitle = true,
}) {
  return SearchEntry(
    kind: kind,
    title: title,
    subtitle: 'alt',
    body: body,
    page: (_) => const SizedBox(),
    matchTitle: matchTitle,
  );
}

void main() {
  test('fold keeps length and ignores Turkish letters and case', () {
    const text = 'İbrâhîm Şükür ĞÖÇ ısı';
    final folded = SearchText.fold(text);
    expect(folded, 'ibrahim sukur goc isi');
    expect(folded.length, text.length);
  });

  test('query without Turkish letters or apostrophe still matches', () {
    final entries = [
      _entry(SearchKind.dua, 'Aksırınca'),
      _entry(SearchKind.quran, "Kur'an okurken"),
    ];
    expect(searchEntries(entries, 'aksirinca').single.entry.title, 'Aksırınca');
    expect(searchEntries(entries, 'KURAN').single.entry.kind, SearchKind.quran);
  });

  test('every word must match and title hits rank above body hits', () {
    final entries = [
      _entry(SearchKind.hadith, 'Temizlik', body: 'yemekten önce eller yıkanır'),
      _entry(SearchKind.dua, 'Yemekten Sonra', body: 'yemek bitince'),
      _entry(SearchKind.dua, 'Uyumadan Önce', body: 'yatağa girince'),
    ];
    final hits = searchEntries(entries, 'yemek');
    expect(hits.map((h) => h.entry.title), ['Yemekten Sonra', 'Temizlik']);
    expect(searchEntries(entries, 'yemek uyku'), isEmpty);
    expect(searchEntries(entries, 'yemek', kind: SearchKind.hadith), hasLength(1));
  });

  test('body hit shows a snippet around the match', () {
    final long = '${'a ' * 60}sabır güzeldir ${'b ' * 60}';
    final hit = searchEntries(
      [_entry(SearchKind.morality, 'Başlık', body: long)],
      'sabir',
    ).single;
    expect(hit.snippet, startsWith('…'));
    expect(hit.snippet, contains('sabır güzeldir'));
  });

  test('ayah titles are not searched, only their meal', () {
    final entries = [
      _entry(SearchKind.quran, 'Bakara Sûresi'),
      _entry(SearchKind.quran, 'Bakara Sûresi, 5. ayet',
          body: 'kurtuluşa erenler', matchTitle: false),
    ];
    expect(searchEntries(entries, 'bakara'), hasLength(1));
    expect(searchEntries(entries, 'kurtulus'), hasLength(1));
  });
}
