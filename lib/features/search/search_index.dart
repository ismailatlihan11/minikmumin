import 'package:flutter/material.dart';

import '../../app/constants/basics_sections.dart';
import '../../app/constants/surah_names.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../asma/asma_page.dart';
import '../duas/duas_page.dart';
import '../hadith/hadith_page.dart';
import '../learn/basics_page.dart';
import '../learn/ilmihal_page.dart';
import '../learn/morality_page.dart';
import '../prophets/prophets_page.dart';
import '../quran/quran_page.dart';
import '../stories/stories_page.dart';

enum SearchKind {
  dua('Dualar', Icons.volunteer_activism_rounded),
  quran("Kur'an", Icons.menu_book_rounded),
  hadith('Hadisler', Icons.format_quote_rounded),
  prophet('Peygamberler', Icons.auto_stories_rounded),
  story('Kıssalar', Icons.book_rounded),
  morality('Güzel Ahlak', Icons.favorite_rounded),
  basics('Dini Bilgiler', Icons.school_rounded),
  asma('Esmaül Hüsna', Icons.star_rounded);

  const SearchKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

class SearchEntry {
  SearchEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.page,
    bool matchTitle = true,
  })  : _title = matchTitle ? SearchText.fold(title) : '',
        _body = SearchText.fold(body);

  final SearchKind kind;
  final String title;
  final String subtitle;
  final String body;
  final WidgetBuilder page;
  final String _title;
  final String _body;
}

class SearchHit {
  const SearchHit(this.entry, this.snippet, this.score);

  final SearchEntry entry;
  final String snippet;
  final int score;
}

abstract final class SearchText {
  static const _map = {
    'İ': 'i', 'I': 'i', 'ı': 'i', 'î': 'i', 'Î': 'i',
    'Ş': 's', 'ş': 's', 'Ğ': 'g', 'ğ': 'g',
    'Ü': 'u', 'ü': 'u', 'û': 'u', 'Û': 'u',
    'Ö': 'o', 'ö': 'o', 'Ç': 'c', 'ç': 'c',
    'â': 'a', 'Â': 'a', '’': "'", '‘': "'", 'ʼ': "'",
  };

  /// Lowercases and strips Turkish letters/circumflexes one-to-one, so an
  /// index into the folded text is also an index into the original.
  static String fold(String text) {
    final out = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _map[char] ?? char.toLowerCase();
      out.write(mapped.length == char.length ? mapped : char);
    }
    return out.toString();
  }

  static List<String> terms(String query) => fold(query)
      .replaceAll("'", '')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();

  static String _compact(String folded) => folded.replaceAll("'", '');
}

List<SearchHit> searchEntries(
  List<SearchEntry> entries,
  String query, {
  SearchKind? kind,
}) {
  final terms = SearchText.terms(query);
  if (terms.isEmpty) return const [];
  final hits = <SearchHit>[];
  for (final entry in entries) {
    if (kind != null && entry.kind != kind) continue;
    final title = SearchText._compact(entry._title);
    final body = SearchText._compact(entry._body);
    var score = 0;
    var matched = true;
    for (final term in terms) {
      if (title.startsWith(term)) {
        score += 30;
      } else if (title.contains(term)) {
        score += 20;
      } else if (body.contains(term)) {
        score += 1;
      } else {
        matched = false;
        break;
      }
    }
    if (!matched) continue;
    hits.add(SearchHit(entry, _snippet(entry, terms.first), score));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits;
}

String _snippet(SearchEntry entry, String term) {
  final text = entry.body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (SearchText._compact(entry._title).contains(term) ||
      SearchText._compact(SearchText.fold(entry.subtitle)).contains(term) ||
      text.isEmpty) {
    return entry.subtitle;
  }
  final at = SearchText.fold(text).indexOf(term);
  if (at < 0) return entry.subtitle;
  final start = at > 40 ? at - 40 : 0;
  final end = (at + 110).clamp(0, text.length);
  return '${start > 0 ? '…' : ''}${text.substring(start, end)}'
      '${end < text.length ? '…' : ''}';
}

String _join(Iterable<String> parts) =>
    parts.where((p) => p.trim().isNotEmpty).join(' · ');

String _firstWords(String text, int max) {
  final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length <= max) return clean;
  final cut = clean.lastIndexOf(' ', max);
  return '${clean.substring(0, cut > 0 ? cut : max)}…';
}

Future<List<SearchEntry>> buildSearchIndex(ContentRepositories repos) async {
  final results = await Future.wait([
    _duas(repos),
    _hadiths(repos),
    _prophets(repos),
    _stories(repos),
    _morality(repos),
    _basics(repos),
    _asma(repos),
    _quran(repos),
  ].map((f) => f.catchError((_) => <SearchEntry>[])));
  return [for (final list in results) ...list];
}

Future<List<SearchEntry>> _duas(ContentRepositories repos) async {
  final catalog = await repos.duas.getCatalog();
  final prayer = (await repos.duas.getPrayerDuas())
      .map(DuaEntry.fromPrayerDua)
      .toList(growable: false);
  SearchEntry entry(DuaEntry dua, String kind, List<DuaEntry> list) {
    return SearchEntry(
      kind: SearchKind.dua,
      title: dua.title,
      subtitle: kind == 'prayer_dua'
          ? 'Namaz duası'
          : _join([dua.section, dua.when]),
      body: _join([
        dua.section,
        dua.when,
        dua.fullReading,
        dua.fullMeaning,
        dua.reference,
      ]),
      page: (_) => DuaDetailPage(dua: dua, kind: kind, catalog: list),
    );
  }

  return [
    for (final dua in catalog) entry(dua, 'dua', catalog),
    for (final dua in prayer) entry(dua, 'prayer_dua', prayer),
  ];
}

Future<List<SearchEntry>> _hadiths(ContentRepositories repos) async {
  final all = await repos.hadith.getAll();
  return [
    for (final hadith in all)
      SearchEntry(
        kind: SearchKind.hadith,
        title: _firstWords(hadith.plainTurkish, 60),
        subtitle: 'Hadis',
        body: hadith.plainTurkish,
        page: (_) => HadithDetailPage(hadith: hadith),
      ),
  ];
}

Future<List<SearchEntry>> _prophets(ContentRepositories repos) async {
  final all = await repos.prophets.getAll();
  return [
    for (final prophet in all)
      SearchEntry(
        kind: SearchKind.prophet,
        title: prophet.choiceName,
        subtitle: _firstWords(prophet.summary, 90),
        body: _join([prophet.summary, ...prophet.lessons]),
        page: (_) => ProphetDetailPage(item: prophet),
      ),
  ];
}

Future<List<SearchEntry>> _stories(ContentRepositories repos) async {
  final catalog = await repos.stories.load();
  final titles = {for (final c in catalog.categories) c.id: c.title};
  return [
    for (final story in catalog.items)
      SearchEntry(
        kind: SearchKind.story,
        title: story.title,
        subtitle: titles[story.category] ?? _firstWords(story.summary, 90),
        body: _join([story.summary, ...story.lessons, story.reflection]),
        page: (_) => StoryReaderPage(story: story),
      ),
  ];
}

Future<List<SearchEntry>> _morality(ContentRepositories repos) async {
  final catalog = await repos.morality.load();
  final titles = {for (final c in catalog.categories) c.id: c.title};
  return [
    for (final lesson in catalog.lessons)
      SearchEntry(
        kind: SearchKind.morality,
        title: lesson.title,
        subtitle: titles[lesson.category] ?? 'Güzel Ahlak',
        body: _join([
          lesson.shortMessage,
          lesson.childExplanation,
          lesson.lesson,
          lesson.dailyChallenge,
        ]),
        page: (_) => MoralityLessonPage(
          lesson: lesson,
          categoryTitle: titles[lesson.category],
        ),
      ),
  ];
}

Future<List<SearchEntry>> _basics(ContentRepositories repos) async {
  final catalog = await repos.basics.load();
  final sectionOf = {
    for (final section in BasicsSections.all)
      for (final id in section.itemIds) id: section.title,
  };
  final ilmihal = await repos.ilmihal.load();
  final ilmihalTitles = {for (final c in ilmihal.categories) c.id: c.title};
  return [
    for (final item in catalog.items)
      SearchEntry(
        kind: SearchKind.basics,
        title: item.title,
        subtitle: _join(
            [sectionOf[item.id] ?? 'Temel Dini Bilgiler', item.shortDescription]),
        body: _join([
          item.shortDescription,
          item.content,
          item.meaning,
          ...item.keyPoints,
        ]),
        page: (_) => BasicsItemPage(
          item: item,
          sectionTitle: sectionOf[item.id] ?? 'Temel Dini Bilgiler',
        ),
      ),
    for (final lesson in ilmihal.lessons)
      SearchEntry(
        kind: SearchKind.basics,
        title: lesson.title,
        subtitle: _join(['İlmihal', ilmihalTitles[lesson.category] ?? '']),
        body: _join([lesson.summary, ...lesson.keyPoints, lesson.activity]),
        page: (_) => IlmihalLessonPage(lesson: lesson),
      ),
  ];
}

Future<List<SearchEntry>> _asma(ContentRepositories repos) async {
  final all = await repos.asma.getAll();
  return [
    for (final item in all)
      SearchEntry(
        kind: SearchKind.asma,
        title: item.name,
        subtitle: item.meaning,
        body: _join([item.meaning, item.childExplanation]),
        page: (_) => AsmaDetailPage(item: item),
      ),
  ];
}

Future<List<SearchEntry>> _quran(ContentRepositories repos) async {
  final ayahs = await repos.quran.getAllAyahs();
  return [
    for (var id = 1; id <= 114; id++)
      SearchEntry(
        kind: SearchKind.quran,
        title: '${surahName(id)} Sûresi',
        subtitle: '$id. sûre',
        body: '',
        page: (_) => QuranSurahPage(surahId: id),
      ),
    for (final ayah in ayahs)
      SearchEntry(
        kind: SearchKind.quran,
        title: '${surahName(ayah.surahId)} Sûresi, ${ayah.ayahNo}. ayet',
        subtitle: _firstWords(ayah.meal, 110),
        body: ayah.meal,
        matchTitle: false,
        page: (_) =>
            QuranSurahPage(surahId: ayah.surahId, initialAyahNo: ayah.ayahNo),
      ),
  ];
}
