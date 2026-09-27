import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../core/audio/audio_player_service.dart';
import '../../shared/widgets/favorite_button.dart';
import 'elifba_audio.dart';
import 'elifba_games.dart';
import 'elifba_models.dart';
import 'elifba_widgets.dart';

class ElifbaAudioButton extends StatelessWidget {
  const ElifbaAudioButton({
    super.key,
    required this.audio,
    required this.path,
    this.label = 'Dinle',
  });

  final AudioPlayerService audio;
  final String? path;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElifbaListenButton(audio: audio, path: path, label: label);
  }
}

class ElifbaLessonHeader extends StatelessWidget {
  const ElifbaLessonHeader({
    super.key,
    required this.title,
    this.subtitle = '',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.mint,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class ElifbaLessonSummary extends StatelessWidget {
  const ElifbaLessonSummary({
    super.key,
    required this.points,
  });

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.butter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bugünü hatırla',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $point'),
            ),
        ],
      ),
    );
  }
}

class ElifbaRewardCard extends StatelessWidget {
  const ElifbaRewardCard({
    super.key,
    required this.stars,
    required this.quizCorrect,
    required this.quizTotal,
  });

  final int stars;
  final int quizCorrect;
  final int quizTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        Text('Harika!', style: Theme.of(context).textTheme.displayMedium),
        const Text('Bugünkü dersi tamamladın.'),
        const SizedBox(height: 12),
        ElifbaStarsRow(count: stars),
        if (quizTotal > 0) Text('$quizCorrect / $quizTotal doğru'),
      ],
    );
  }
}

class ElifbaLetterCard extends StatefulWidget {
  const ElifbaLetterCard({
    super.key,
    required this.row,
    required this.audio,
    this.compact = false,
    this.allowFavorite = true,
    this.allowListen = true,
  });

  final ElifbaLetterRow row;
  final AudioPlayerService audio;
  final bool compact;
  final bool allowFavorite;

  /// Kaydı olmayan ya da kaydı iyi çıkmayan bölümlerde ses düğmeleri
  /// gösterilmez; çocuk kartı kendisi okur.
  final bool allowListen;

  @override
  State<ElifbaLetterCard> createState() => _ElifbaLetterCardState();
}

class _ElifbaLetterCardState extends State<ElifbaLetterCard> {
  var _highlight = false;
  var _sayNow = false;
  var _readingScale = 1.0;

  ElifbaLetterRow get row => widget.row;

  String? get _listenPath {
    if (!widget.allowListen) return null;
    if (row.audioLetter.isNotEmpty) {
      return ElifbaAudio.resolve(row.audioLetter) ?? row.audioLetter;
    }
    if (row.marked.isNotEmpty) {
      return ElifbaAudio.forMarked(row.marked, name: row.name);
    }
    return ElifbaAudio.letterName(row.name) ??
        ElifbaAudio.letterGlyph(row.letter);
  }

  Future<void> _tapMarked() async {
    HapticFeedback.selectionClick();
    setState(() {
      _highlight = true;
      _readingScale = 1.28;
      _sayNow = false;
    });
    await ElifbaAudio.play(widget.audio, _listenPath);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    setState(() {
      _sayNow = true;
      _readingScale = 1;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _highlight = false);
  }

  Future<void> _repeat() async {
    await ElifbaAudio.play(widget.audio, _listenPath);
    if (mounted) setState(() => _sayNow = true);
  }

  @override
  Widget build(BuildContext context) {
    final arabicSize = widget.compact ? 32.0 : 40.0;
    return AnimatedScale(
      scale: _highlight ? 1.04 : 1,
      duration: const Duration(milliseconds: 180),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _highlight ? MinikColors.goldSoft : MinikColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _highlight ? MinikColors.gold : MinikColors.mint,
            width: _highlight ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Harf', textDirection: TextDirection.ltr),
            ),
            Text(
              row.letter,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AssetPaths.arabicFontFamily,
                fontSize: arabicSize,
                color: MinikColors.darkGreen,
              ),
            ),
            const Text('Harfin adı', textDirection: TextDirection.ltr),
            Text(
              row.name,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (row.marked.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(row.markedCaption, textDirection: TextDirection.ltr),
              GestureDetector(
                onTap: _tapMarked,
                child: Text(
                  row.marked,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: arabicSize + 4,
                    color: MinikColors.green,
                  ),
                ),
              ),
            ],
            if (row.reading.isNotEmpty) ...[
              const Text('Okunuşu', textDirection: TextDirection.ltr),
              AnimatedScale(
                scale: _readingScale,
                duration: const Duration(milliseconds: 220),
                child: Text(
                  row.reading,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: MinikColors.gold,
                      ),
                ),
              ),
            ],
            if (row.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  row.note,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_sayNow)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Şimdi sen söyle!',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w800,
                    color: MinikColors.green,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (widget.allowListen) ...[
                  ElifbaAudioButton(audio: widget.audio, path: _listenPath),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _listenPath == null ? null : _repeat,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Tekrar Et'),
                    ),
                  ),
                ],
                if (widget.allowFavorite)
                  FavoriteButton(
                    kind: 'elifba_example',
                    id: row.marked.isEmpty ? row.letter : row.marked,
                    title: [
                      row.letter,
                      row.name,
                      if (row.marked.isNotEmpty) row.marked,
                      if (row.reading.isNotEmpty) row.reading,
                    ].join(' · '),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ElifbaLetterTable extends StatefulWidget {
  const ElifbaLetterTable({
    super.key,
    required this.rows,
    required this.audio,
    this.title = '',
    this.instruction = '',
    this.allowFavorite = true,
    this.allowListen = true,
  });

  final List<ElifbaLetterRow> rows;
  final AudioPlayerService audio;
  final String title;
  final String instruction;
  final bool allowFavorite;
  final bool allowListen;

  static const groups = <List<String>>[
    ['ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ'],
    ['د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص'],
    ['ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق'],
    ['ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي'],
  ];

  @override
  State<ElifbaLetterTable> createState() => _ElifbaLetterTableState();
}

class _ElifbaLetterTableState extends State<ElifbaLetterTable> {
  var _showAll = false;
  var _group = 0;

  List<ElifbaLetterRow> get _visible {
    if (widget.rows.length < 20 || _showAll) return widget.rows;
    final letters = ElifbaLetterTable.groups[_group.clamp(0, 3)];
    return [
      for (final letter in letters)
        widget.rows.firstWhere(
          (row) => row.letter == letter,
          orElse: () => ElifbaLetterRow(letter: letter, name: ''),
        ),
    ].where((row) => row.name.isNotEmpty || row.marked.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 420;
    final columns = narrow ? 1 : 2;
    final grouped = widget.rows.length >= 20;
    return Column(
      children: [
        if (widget.title.isNotEmpty)
          ElifbaLessonHeader(
            title: widget.title,
            subtitle: widget.instruction,
          ),
        if (grouped) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < ElifbaLetterTable.groups.length; i++)
                ChoiceChip(
                  label: Text('${i + 1}. Grup'),
                  selected: !_showAll && _group == i,
                  onSelected: (_) => setState(() {
                    _showAll = false;
                    _group = i;
                  }),
                ),
              FilterChip(
                label: const Text('Tümünü Gör'),
                selected: _showAll,
                onSelected: (value) => setState(() => _showAll = value),
              ),
            ],
          ),
          if (!_showAll)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                ElifbaLetterTable.groups[_group].join('  '),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 22,
                ),
              ),
            ),
        ],
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              textDirection: TextDirection.ltr,
              children: [
                for (final row in _visible)
                  SizedBox(
                    width: width,
                    child: ElifbaLetterCard(
                      row: row,
                      audio: widget.audio,
                      compact: columns == 2,
                      allowFavorite: widget.allowFavorite,
                      allowListen: widget.allowListen,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ElifbaRuleCard extends StatelessWidget {
  const ElifbaRuleCard({
    super.key,
    required this.title,
    this.detail = '',
    this.extra = '',
    this.letters = const [],
    this.memory = '',
  });

  final String title;
  final String detail;
  final String extra;
  final List<String> letters;
  final String memory;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.lavender,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(detail, textAlign: TextAlign.center),
          ],
          if (letters.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final letter in letters)
                  Text(
                    letter,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: AssetPaths.arabicFontFamily,
                      fontSize: 28,
                    ),
                  ),
              ],
            ),
          ],
          if (memory.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              memory,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AssetPaths.arabicFontFamily,
                fontSize: 22,
              ),
            ),
          ],
          if (extra.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              extra,
              textAlign: TextAlign.center,
              textDirection:
                  extra.runes.any((code) => code >= 0x0600 && code <= 0x06FF)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              style: extra.runes.any((code) => code >= 0x0600 && code <= 0x06FF)
                  ? const TextStyle(
                      fontFamily: AssetPaths.arabicFontFamily,
                      fontSize: 28,
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class ElifbaExampleCard extends StatelessWidget {
  const ElifbaExampleCard({
    super.key,
    required this.example,
    required this.audio,
    this.highlight = '',
  });

  final ElifbaExample example;
  final AudioPlayerService audio;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final path = ElifbaAudio.forExample(
      example.text,
      audio: example.audio,
      reading: example.reading,
    );
    return ElifbaSoftCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElifbaArabicTap(
                  text: example.text,
                  fontSize: 36,
                  onTap: () => ElifbaAudio.play(audio, path),
                ),
              ),
              FavoriteButton(
                kind: 'elifba_example',
                id: example.text,
                title: example.reading.isEmpty
                    ? example.text
                    : '${example.text} · ${example.reading}',
              ),
            ],
          ),
          if (example.reading.isNotEmpty)
            Text(
              example.reading,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          if (example.focus.isNotEmpty || highlight.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: MinikColors.butter,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                highlight.isEmpty ? example.focus : highlight,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (example.note.isNotEmpty || example.rule.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                example.note.isNotEmpty ? example.note : example.rule,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
          ElifbaAudioButton(audio: audio, path: path),
        ],
      ),
    );
  }
}

class ElifbaComparisonCard extends StatelessWidget {
  const ElifbaComparisonCard({
    super.key,
    required this.left,
    required this.right,
    required this.leftCaption,
    required this.rightCaption,
  });

  final String left;
  final String right;
  final String leftCaption;
  final String rightCaption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _cell(context, left, leftCaption)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.compare_arrows_rounded, color: MinikColors.gold),
        ),
        Expanded(child: _cell(context, right, rightCaption)),
      ],
    );
  }

  Widget _cell(BuildContext context, String arabic, String caption) {
    return ElifbaSoftCard(
      color: MinikColors.sky,
      child: Column(
        children: [
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: AssetPaths.arabicFontFamily,
              fontSize: 36,
            ),
          ),
          Text(caption, textDirection: TextDirection.ltr),
        ],
      ),
    );
  }
}

class ElifbaCompareGame extends StatelessWidget {
  const ElifbaCompareGame({
    super.key,
    required this.pair,
    required this.onAnswer,
  });

  final ElifbaComparePair pair;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    final glyphs = pair.glyphs;
    final lisp =
        glyphs.where((g) => ElifbaLetterKind.lisp.contains(g)).toList();
    final heavy =
        glyphs.where((g) => ElifbaLetterKind.heavy.contains(g)).toList();
    final lower = pair.difference.toLowerCase();
    final askLisp = lower.contains('peltek');
    final prompt = askLisp
        ? 'Hangisi peltek?'
        : (lower.contains('kalın') || lower.contains('kalin')
            ? 'Hangisi kalın?'
            : 'Hangisi farklı?');
    final answer = askLisp
        ? (lisp.isNotEmpty ? lisp.first : glyphs.first)
        : (heavy.isNotEmpty ? heavy.first : glyphs.last);
    return Column(
      children: [
        Text(
          pair.group,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: AssetPaths.arabicFontFamily,
            fontSize: 36,
          ),
        ),
        if (pair.difference.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(pair.difference, textAlign: TextAlign.center),
          ),
        ElifbaChoiceRow(
          prompt: prompt,
          options: glyphs,
          answer: answer,
          onAnswer: onAnswer,
        ),
      ],
    );
  }
}

class ElifbaPracticeCard extends StatelessWidget {
  const ElifbaPracticeCard({
    super.key,
    required this.example,
    required this.audio,
    required this.onAnswer,
  });

  final ElifbaExample example;
  final AudioPlayerService audio;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    final options = ['Med', 'Şedde', 'Cezm', 'Tenvin'];
    final answer = example.focus.isEmpty ? example.rule : example.focus;
    return Column(
      children: [
        ElifbaExampleCard(example: example, audio: audio),
        const SizedBox(height: 12),
        if (answer.isNotEmpty)
          ElifbaChoiceRow(
            prompt: 'Kelimenin içinde hangi kural var?',
            options: options,
            answer: options.contains(answer) ? answer : answer,
            onAnswer: onAnswer,
          ),
      ],
    );
  }
}

class ElifbaCategoryBoard extends StatelessWidget {
  const ElifbaCategoryBoard({
    super.key,
    required this.categories,
    required this.tables,
    required this.selected,
    required this.onPick,
    required this.audio,
  });

  final List<ElifbaCategory> categories;
  final Map<String, List<ElifbaLetterRow>> tables;
  final ElifbaCategory? selected;
  final ValueChanged<ElifbaCategory> onPick;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    final rows =
        selected == null ? const <ElifbaLetterRow>[] : _rowsFor(selected!);
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final cat in categories)
              ChoiceChip(
                label: Text(cat.name),
                selected: selected?.name == cat.name,
                onSelected: (_) => onPick(cat),
              ),
          ],
        ),
        if (selected != null) ...[
          const SizedBox(height: 10),
          ElifbaSoftCard(
            color: MinikColors.peach,
            child: Column(
              children: [
                if (selected!.arabicName.isNotEmpty)
                  Text(
                    selected!.arabicName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: AssetPaths.arabicFontFamily,
                      fontSize: 28,
                    ),
                  ),
                Text(selected!.name,
                    style: Theme.of(context).textTheme.headlineMedium),
                if (selected!.meaning.isNotEmpty) Text(selected!.meaning),
                if (selected!.memoryPhrase.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      selected!.memoryPhrase,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: AssetPaths.arabicFontFamily,
                        fontSize: 22,
                      ),
                    ),
                  ),
                if (selected!.note.isNotEmpty) Text(selected!.note),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.ltr,
            alignment: WrapAlignment.center,
            children: [
              for (final row in rows)
                SizedBox(
                  width: 88,
                  child: ElifbaSoftCard(
                    onTap: () => ElifbaAudio.play(
                      audio,
                      ElifbaAudio.letterName(row.name) ??
                          ElifbaAudio.letterGlyph(row.letter),
                    ),
                    child: Column(
                      children: [
                        Text(
                          row.letter,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: AssetPaths.arabicFontFamily,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          row.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  List<ElifbaLetterRow> _rowsFor(ElifbaCategory cat) {
    final lower = cat.name.toLowerCase();
    if (lower.contains('kalın') || lower.contains('kalin')) {
      return tables['kalin_harfler'] ?? _fromLetters(cat.letters);
    }
    if (lower.contains('peltek')) {
      return tables['peltek_harfler'] ?? _fromLetters(cat.letters);
    }
    if (lower.contains('ince')) {
      return tables['ince_harfler'] ?? _fromLetters(cat.letters);
    }
    return _fromLetters(cat.letters);
  }

  List<ElifbaLetterRow> _fromLetters(List<String> letters) {
    return [
      for (final letter in letters) ElifbaLetterRow(letter: letter, name: ''),
    ];
  }
}

class ElifbaMedCompare extends StatelessWidget {
  const ElifbaMedCompare({
    super.key,
    required this.items,
    required this.audio,
  });

  final List<ElifbaMedLetter> items;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          ElifbaMedCard(item: item, audio: audio),
          const SizedBox(height: 8),
          ElifbaComparisonCard(
            left: _shortOf(item.example),
            right: item.example,
            leftCaption: _shortReading(item.reading),
            rightCaption: item.reading,
          ),
          const SizedBox(height: 8),
          const _SoundWave(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _shortOf(String example) {
    if (example.isEmpty) return '';
    final first = String.fromCharCode(example.runes.first);
    if (example.contains('َ')) return '$firstَ';
    if (example.contains('ِ')) return '$firstِ';
    if (example.contains('ُ')) return '$firstُ';
    return first;
  }

  String _shortReading(String reading) {
    return reading
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('û', 'u');
  }
}

class ElifbaMedTableView extends StatelessWidget {
  const ElifbaMedTableView({
    super.key,
    required this.rows,
    required this.audio,
  });

  final List<ElifbaMedRow> rows;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              child: Column(
                children: [
                  Text(row.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                  Text(row.formula),
                  const SizedBox(height: 6),
                  Text(
                    row.pattern,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: AssetPaths.arabicFontFamily,
                      fontSize: 36,
                    ),
                  ),
                  Text('Okunuşu: ${row.reading}'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final example in row.examples)
                        ActionChip(
                          label: Text(
                            example,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: AssetPaths.arabicFontFamily,
                            ),
                          ),
                          onPressed: () => ElifbaAudio.play(
                            audio,
                            ElifbaAudio.forExample(example),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ElifbaVerseStudy extends StatefulWidget {
  const ElifbaVerseStudy({super.key, required this.verses});

  final List<ElifbaVerse> verses;

  @override
  State<ElifbaVerseStudy> createState() => _ElifbaVerseStudyState();
}

class _ElifbaVerseStudyState extends State<ElifbaVerseStudy> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final verse in widget.verses)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElifbaSoftCard(
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final word
                          in verse.text.split(' ').where((w) => w.isNotEmpty))
                        ActionChip(
                          label: Text(
                            word,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: AssetPaths.arabicFontFamily,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () => setState(() => _picked = word),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(verse.focus.join(' · ')),
                  if (_picked != null && verse.text.contains(_picked!)) ...[
                    const SizedBox(height: 8),
                    Text(
                      _picked!,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: AssetPaths.arabicFontFamily,
                        fontSize: 28,
                      ),
                    ),
                    Text(_marksOf(_picked!), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _marksOf(String word) {
    final marks = <String>[];
    if (word.contains('ْ')) marks.add('Cezm');
    if (word.contains('ّ')) marks.add('Şedde');
    if (word.contains('ا') ||
        word.contains('ٰ') ||
        word.contains('و') && word.contains('ُ')) {
      marks.add('Med');
    }
    if (word.contains('لل') || word.contains('الل')) marks.add('Lafzatullah');
    if (marks.isEmpty)
      return 'Bu kelimeye dokundun. İşaretleri birlikte arayalım.';
    return marks.join(' · ');
  }
}

class ElifbaSurahPractice extends StatelessWidget {
  const ElifbaSurahPractice({
    super.key,
    required this.surahs,
    required this.flow,
  });

  final List<ElifbaSurah> surahs;
  final List<String> flow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElifbaSoftCard(
          color: MinikColors.mint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Akış', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              for (final step in flow) Text('• $step'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final surah in surahs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              color: MinikColors.sky,
              child: Column(
                children: [
                  Text(surah.name,
                      style: Theme.of(context).textTheme.headlineMedium),
                  Text(surah.focus.join(' · ')),
                  const SizedBox(height: 8),
                  const Text(
                      'Dinle  →  Tecvid işaretlerini bul  →  Kelime kelime çalış  →  Oku  →  Tekrar et'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SoundWave extends StatelessWidget {
  const _SoundWave();

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 7; i++)
            reduce
                ? _bar(8 + (i % 3) * 6)
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 6, end: 18 + (i % 3) * 6),
                    duration: Duration(milliseconds: 500 + i * 70),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) => _bar(value),
                  ),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 6,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: MinikColors.gold,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
