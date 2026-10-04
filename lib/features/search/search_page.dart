import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/dua_hands_icon.dart';
import '../../shared/widgets/minik_ui.dart';
import 'search_index.dart';

final _indexCache = Expando<Future<List<SearchEntry>>>();

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _recentKey = 'search_recent';
  static const _groupPreview = 4;
  static const _maxListed = 200;
  static const _suggestions = [
    'Yemek',
    'Uyku',
    'Namaz',
    'Sabır',
    'Anne',
    'Hz. Musa',
    'Fâtiha',
    'Rahman',
    'Bakara 255',
  ];

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  late final Future<List<SearchEntry>> _index;
  List<String> _recent = const [];
  String _query = '';
  SearchKind? _kind;

  @override
  void initState() {
    super.initState();
    final repos = context.read<ContentRepositories>();
    _index = _indexCache[repos] ??= buildSearchIndex(repos);
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _recent = prefs.getStringList(_recentKey) ?? const []);
  }

  Future<void> _remember(String query) async {
    final text = query.trim();
    if (text.length < 2) return;
    final next = [
      text,
      ..._recent.where((q) => q.toLowerCase() != text.toLowerCase()),
    ].take(8).toList();
    setState(() => _recent = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, next);
  }

  Future<void> _clearRecent() async {
    setState(() => _recent = const []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _setQuery(String value) {
    _debounce?.cancel();
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _query = value);
    _remember(value);
  }

  Future<void> _open(SearchEntry entry) async {
    _focus.unfocus();
    _remember(_query);
    await Navigator.push(context, MinikTheme.route(entry.page(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinikColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          key: const ValueKey('search_field'),
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _setQuery,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: InputDecoration(
            hintText: 'Dua, sure, hadis, peygamber ara…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintStyle: TextStyle(color: MinikColors.textMuted),
          ),
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox(width: 12)
                : IconButton(
                    tooltip: 'Temizle',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _setQuery('');
                      _focus.requestFocus();
                    },
                  ),
          ),
        ],
      ),
      body: FutureBuilder<List<SearchEntry>>(
        future: _index,
        builder: (context, snapshot) {
          final entries = snapshot.data;
          if (_query.trim().isEmpty) return _idle();
          if (entries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _results(entries);
        },
      ),
    );
  }

  Widget _idle() {
    return ListView(
      padding: AppSpacing.page,
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(child: SectionLabel('Son aramalar')),
              TextButton(
                onPressed: _clearRecent,
                child: const Text('Temizle'),
              ),
            ],
          ),
          for (final query in _recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.history_rounded, color: MinikColors.textMuted),
              title: Text(query),
              trailing: Icon(Icons.north_west_rounded,
                  size: 18, color: MinikColors.textMuted),
              onTap: () => _setQuery(query),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SectionLabel('Bunları arayabilirsin'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final text in _suggestions)
              ActionChip(
                label: Text(text),
                avatar: Icon(Icons.search_rounded,
                    size: 16, color: MinikColors.green),
                onPressed: () => _setQuery(text),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Dualar, Kur\'an mealleri, hadisler, peygamberler, kıssalar, '
          'güzel ahlak, dini bilgiler ve Esmaül Hüsna içinde arar. '
          'Bir ayete gitmek için “Furkan 69” ya da “25:69” yaz.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: MinikColors.textMuted),
        ),
      ],
    );
  }

  Widget _results(List<SearchEntry> entries) {
    final terms = SearchText.terms(_query);
    final all = searchEntries(entries, _query);
    final counts = <SearchKind, int>{};
    for (final hit in all) {
      counts[hit.entry.kind] = (counts[hit.entry.kind] ?? 0) + 1;
    }
    final kind = counts.containsKey(_kind) ? _kind : null;
    final chips = SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: [
          _chip('Tümü', all.length, kind == null, () {
            setState(() => _kind = null);
          }),
          for (final k in SearchKind.values)
            if (counts[k] != null)
              _chip(k.label, counts[k]!, kind == k, () {
                setState(() => _kind = k);
              }),
        ],
      ),
    );

    if (all.isEmpty) {
      return Padding(
        padding: AppSpacing.page,
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(Icons.search_off_rounded,
                size: 56, color: MinikColors.textMuted),
            const SizedBox(height: 12),
            Text(
              '“${_query.trim()}” için sonuç bulunamadı.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Başka bir kelimeyle ya da daha kısa yazarak dene.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: MinikColors.textMuted),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[];
    if (kind != null) {
      final hits = all.where((h) => h.entry.kind == kind).toList();
      for (final hit in hits.take(_maxListed)) {
        rows.add(_tile(hit, terms));
      }
      if (hits.length > _maxListed) {
        rows.add(_moreNote(hits.length - _maxListed));
      }
    } else {
      for (final k in SearchKind.values) {
        final hits = all.where((h) => h.entry.kind == k).toList();
        if (hits.isEmpty) continue;
        rows.add(SectionLabel('${k.label} (${hits.length})'));
        for (final hit in hits.take(_groupPreview)) {
          rows.add(_tile(hit, terms));
        }
        if (hits.length > _groupPreview) {
          rows.add(Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _kind = k),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text('Tümünü gör (${hits.length})'),
            ),
          ));
        }
        rows.add(const SizedBox(height: AppSpacing.sm));
      }
    }

    return Column(
      children: [
        chips,
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: rows.length,
            itemBuilder: (_, i) => rows[i],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, int count, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label $count'),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _moreNote(int hidden) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '$hidden sonuç daha var. Aramayı daraltmak için kelime ekle.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: MinikColors.textMuted),
      ),
    );
  }

  Widget _tile(SearchHit hit, List<String> terms) {
    final entry = hit.entry;
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MinikCard(
        color: MinikColors.surface,
        onTap: () => _open(entry),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MinikColors.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: entry.kind == SearchKind.dua
                  ? Center(
                      child: DuaHandsIcon(size: 22, color: MinikColors.green))
                  : Icon(entry.kind.icon, size: 20, color: MinikColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    _highlight(
                        entry.title,
                        terms,
                        theme.titleMedium
                            ?.copyWith(color: MinikColors.darkGreen)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hit.snippet.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      _highlight(
                          hit.snippet,
                          terms,
                          theme.bodySmall
                              ?.copyWith(color: MinikColors.textMuted)),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _highlight(String text, List<String> terms, TextStyle? style) {
    final folded = SearchText.fold(text);
    final marks = List<bool>.filled(text.length, false);
    for (final term in terms) {
      var from = 0;
      while (true) {
        final at = folded.indexOf(term, from);
        if (at < 0) break;
        for (var i = at; i < at + term.length && i < marks.length; i++) {
          marks[i] = true;
        }
        from = at + term.length;
      }
    }
    final strong = style?.copyWith(
      fontWeight: FontWeight.w800,
      color: MinikColors.green,
      backgroundColor: MinikColors.mint,
    );
    final spans = <TextSpan>[];
    var start = 0;
    for (var i = 1; i <= text.length; i++) {
      if (i == text.length || marks[i] != marks[start]) {
        spans.add(TextSpan(
          text: text.substring(start, i),
          style: marks[start] ? strong : style,
        ));
        start = i;
      }
    }
    return TextSpan(children: spans, style: style);
  }
}
