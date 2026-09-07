import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../shared/widgets/favorite_button.dart';
import 'elifba_audio.dart';
import 'elifba_models.dart';
import 'elifba_widgets.dart';
import 'elifba_worlds.dart';

typedef ElifbaAnswer = void Function({required bool correct});

class ElifbaLetterGrid extends StatelessWidget {
  const ElifbaLetterGrid({
    super.key,
    required this.letters,
    required this.audio,
  });

  final List<ElifbaLetter> letters;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final letter in letters)
          _LetterChip(
            letter: letter,
            onTap: () {
              ElifbaAudio.play(
                audio,
                ElifbaAudio.letterName(letter.name) ??
                    ElifbaAudio.letterGlyph(letter.letter),
              );
            },
          ),
      ],
    );
  }
}

class _LetterChip extends StatefulWidget {
  const _LetterChip({required this.letter, required this.onTap});

  final ElifbaLetter letter;
  final VoidCallback onTap;

  @override
  State<_LetterChip> createState() => _LetterChipState();
}

class _LetterChipState extends State<_LetterChip> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        setState(() => _scale = 1.12);
        widget.onTap();
        await Future<void>.delayed(const Duration(milliseconds: 160));
        if (mounted) setState(() => _scale = 1);
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: 72,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MinikColors.mint),
          ),
          child: Column(
            children: [
              Text(
                widget.letter.letter,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 28,
                  color: MinikColors.darkGreen,
                ),
              ),
              if (widget.letter.name.isNotEmpty)
                Text(
                  widget.letter.name,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: MinikColors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElifbaNameSoundCard extends StatelessWidget {
  const ElifbaNameSoundCard({
    super.key,
    required this.letter,
    required this.audio,
  });

  final ElifbaLetter letter;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      color: MinikColors.mint,
      child: Column(
        children: [
          const Text('Harf', textDirection: TextDirection.ltr),
          ElifbaArabicTap(
            text: letter.letter,
            fontSize: 72,
            onTap: () => ElifbaAudio.play(
              audio,
              ElifbaAudio.letterName(letter.name) ??
                  ElifbaAudio.letterGlyph(letter.letter),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Harfin adı', textDirection: TextDirection.ltr),
          Text(
            letter.name,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ElifbaListenButton(
            audio: audio,
            path: ElifbaAudio.letterName(letter.name) ??
                ElifbaAudio.letterGlyph(letter.letter),
            label: 'Adını dinle',
          ),
        ],
      ),
    );
  }
}

class ElifbaLetterHunt extends StatelessWidget {
  const ElifbaLetterHunt({
    super.key,
    required this.letters,
    required this.target,
    required this.onAnswer,
  });

  final List<ElifbaLetter> letters;
  final ElifbaLetter target;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${target.name} harfini bul!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final letter in letters)
              Semantics(
                button: true,
                label: letter.name,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAnswer(correct: letter.letter == target.letter);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: MinikColors.goldSoft),
                    ),
                    child: Text(
                      letter.letter,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: AssetPaths.arabicFontFamily,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

const _thinBox = 'İnce';
const _heavyBox = 'Kalın';
const _lispBox = 'Peltek';

abstract final class ElifbaLetterKind {
  static const heavy = {'خ', 'ص', 'ض', 'غ', 'ط', 'ق', 'ظ'};
  static const lisp = {'ث', 'ذ', 'ظ'};

  static Set<String> boxesFor(String letter) {
    final boxes = <String>{};
    if (heavy.contains(letter)) boxes.add(_heavyBox);
    if (lisp.contains(letter)) boxes.add(_lispBox);
    if (boxes.isEmpty) boxes.add(_thinBox);
    return boxes;
  }
}

class ElifbaSortDrop extends StatelessWidget {
  const ElifbaSortDrop({
    super.key,
    required this.letter,
    required this.onAnswer,
  });

  final String letter;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    final accepted = ElifbaLetterKind.boxesFor(letter);
    return Column(
      children: [
        const Text('Harfi doğru kutuya bırak'),
        const SizedBox(height: 8),
        Draggable<String>(
          data: letter,
          feedback: _glyph(letter, dragging: true),
          childWhenDragging: Opacity(opacity: 0.3, child: _glyph(letter)),
          child: _glyph(letter),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final box in [_thinBox, _heavyBox, _lispBox])
              DragTarget<String>(
                onWillAcceptWithDetails: (_) => true,
                onAcceptWithDetails: (_) =>
                    onAnswer(correct: accepted.contains(box)),
                builder: (context, candidate, _) {
                  final color = box == _heavyBox
                      ? MinikColors.peach
                      : box == _lispBox
                          ? MinikColors.sky
                          : MinikColors.mint;
                  return Container(
                    width: 96,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: candidate.isEmpty ? color : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MinikColors.greenSoft),
                    ),
                    child: Text(
                      box,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        if (letter == 'ظ')
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Zı hem kalın hem peltek okunur.'),
          ),
      ],
    );
  }

  Widget _glyph(String value, {bool dragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dragging ? MinikColors.butter : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          value,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: AssetPaths.arabicFontFamily,
            fontSize: 36,
          ),
        ),
      ),
    );
  }
}

class ElifbaFormsCard extends StatelessWidget {
  const ElifbaFormsCard({super.key, required this.focus});

  final ElifbaFocusLetter focus;

  static const _labels = {
    'isolated': 'Tek',
    'initial': 'Başta',
    'medial': 'Ortada',
    'final': 'Sonda',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final entry in focus.forms.entries)
          Container(
            width: 88,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MinikColors.sky,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  entry.value,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: 28,
                  ),
                ),
                Text(
                  _labels[entry.key] ?? entry.key,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ElifbaChoiceRow extends StatelessWidget {
  const ElifbaChoiceRow({
    super.key,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.onAnswer,
  });

  final String prompt;
  final List<String> options;
  final String answer;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => onAnswer(correct: option == answer),
                child: Text(
                  option,
                  textDirection: _looksArabic(option)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: _looksArabic(option)
                        ? AssetPaths.arabicFontFamily
                        : 'NotoSans',
                    fontSize: _looksArabic(option) ? 26 : 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ElifbaHarakaDrag extends StatelessWidget {
  const ElifbaHarakaDrag({
    super.key,
    required this.letter,
    required this.targetMark,
    required this.targetReading,
    required this.onAnswer,
  });

  final String letter;
  final String targetMark;
  final String targetReading;
  final ElifbaAnswer onAnswer;

  static const marks = ['َ', 'ِ', 'ُ'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$targetReading yapmak için hangi harekeyi seçmelisin?'),
        const SizedBox(height: 12),
        DragTarget<String>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) =>
              onAnswer(correct: details.data == targetMark),
          builder: (context, candidate, _) {
            return Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: candidate.isEmpty ? Colors.white : MinikColors.mint,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: MinikColors.goldSoft, width: 2),
              ),
              child: Text(
                letter,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 56,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final mark in marks)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Draggable<String>(
                  data: mark,
                  feedback: _mark(mark, dragging: true),
                  childWhenDragging: Opacity(opacity: 0.25, child: _mark(mark)),
                  child: _mark(mark),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _mark(String mark, {bool dragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: dragging ? MinikColors.butter : MinikColors.peach,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          mark,
          style: const TextStyle(
            fontFamily: AssetPaths.arabicFontFamily,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}

class ElifbaBlendGame extends StatelessWidget {
  const ElifbaBlendGame({
    super.key,
    required this.parts,
    required this.result,
    required this.onDone,
  });

  final List<String> parts;
  final String result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final part in parts)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: MinikColors.sky,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  part.trim(),
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: 28,
                  ),
                ),
              ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Icon(Icons.arrow_downward_rounded, color: MinikColors.gold),
        ),
        ElifbaArabicTap(text: result, fontSize: 48),
        const SizedBox(height: 12),
        ElifbaPrimary(label: 'Sesleri birleştirdim', onPressed: onDone),
      ],
    );
  }
}

class ElifbaFindMark extends StatelessWidget {
  const ElifbaFindMark({
    super.key,
    required this.word,
    required this.mark,
    required this.onAnswer,
  });

  final String word;
  final String mark;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    final chars = [
      for (final rune in word.runes) String.fromCharCode(rune),
    ];
    return Wrap(
      spacing: 2,
      alignment: WrapAlignment.center,
      children: [
        for (final ch in chars)
          InkWell(
            onTap: () => onAnswer(correct: ch == mark),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                ch,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AssetPaths.arabicFontFamily,
                  fontSize: 36,
                  color: ch == mark ? MinikColors.gold : MinikColors.darkGreen,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ElifbaTenvinCards extends StatelessWidget {
  const ElifbaTenvinCards({
    super.key,
    required this.types,
    required this.audio,
  });

  final List<ElifbaType> types;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in types)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              color: MinikColors.lavender,
              onTap: () => ElifbaAudio.play(
                audio,
                ElifbaAudio.letterSound('be', haraka: _harakaFor(item.symbol)),
              ),
              child: Row(
                children: [
                  Text(
                    item.symbol,
                    style: const TextStyle(
                      fontFamily: AssetPaths.arabicFontFamily,
                      fontSize: 42,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(item.reading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _harakaFor(String symbol) {
    if (symbol.contains('ً')) return 'fathatayn';
    if (symbol.contains('ٍ')) return 'kasratayn';
    return 'dammatayn';
  }
}

class ElifbaMedCard extends StatelessWidget {
  const ElifbaMedCard({
    super.key,
    required this.item,
    required this.audio,
  });

  final ElifbaMedLetter item;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return ElifbaSoftCard(
      child: Column(
        children: [
          Text(item.condition),
          const SizedBox(height: 8),
          ElifbaArabicTap(
            text: item.example,
            fontSize: 56,
            onTap: () => ElifbaAudio.play(
              audio,
              ElifbaAudio.letterSound(_shortOf(item.example)),
            ),
          ),
          Text(
            item.reading,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              minHeight: 8,
              value: 1,
              color: MinikColors.gold,
              backgroundColor: MinikColors.creamDark,
            ),
          ),
        ],
      ),
    );
  }

  String _shortOf(String example) =>
      example.isEmpty ? 'ب' : example.substring(0, 1);
}

class ElifbaExampleList extends StatelessWidget {
  const ElifbaExampleList({
    super.key,
    required this.examples,
    required this.audio,
  });

  final List<ElifbaExample> examples;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final example in examples)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElifbaSoftCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElifbaArabicTap(
                          text: example.text,
                          fontSize: 36,
                          onTap: () => ElifbaAudio.play(
                            audio,
                            example.audio.isEmpty
                                ? ElifbaAudio.letterGlyph(example.text)
                                : example.audio,
                          ),
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
                  if (example.focus.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MinikColors.butter,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        example.focus,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: AssetPaths.arabicFontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (example.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(example.subtitle),
                    ),
                  if (ElifbaAudio.resolve(example.audio) != null)
                    ElifbaListenButton(audio: audio, path: example.audio),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ElifbaMahrajBoard extends StatelessWidget {
  const ElifbaMahrajBoard({
    super.key,
    required this.groups,
    required this.onPick,
  });

  final List<ElifbaGroup> groups;
  final ValueChanged<ElifbaGroup> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final group in groups)
          ElifbaSoftCard(
            color: MinikColors.peach,
            onTap: () => onPick(group),
            child: SizedBox(
              width: 140,
              child: Column(
                children: [
                  Text(
                    _emoji(group.name),
                    style: const TextStyle(fontSize: 28),
                  ),
                  Text(
                    group.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _emoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dudak') || lower.contains('şefe')) return '👄';
    if (lower.contains('dil') || lower.contains('lisan')) return '👅';
    if (lower.contains('burun') || lower.contains('gunne') || lower.contains('hayş')) {
      return '👃';
    }
    if (lower.contains('cevf')) return '🌬️';
    if (lower.contains('halk') || lower.contains('boğaz')) return '🫁';
    return '🫁';
  }
}

class ElifbaKalkalaRow extends StatelessWidget {
  const ElifbaKalkalaRow({super.key, required this.letters});

  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < letters.length; i++)
          reduce
              ? _ball(letters[i])
              : TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 8),
                  duration: Duration(milliseconds: 700 + i * 80),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, value % 8 - 4),
                    child: child,
                  ),
                  child: _ball(letters[i]),
                ),
      ],
    );
  }

  Widget _ball(String letter) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: MinikColors.goldSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: AssetPaths.arabicFontFamily,
          fontSize: 26,
        ),
      ),
    );
  }
}

class ElifbaTajweedGuess extends StatelessWidget {
  const ElifbaTajweedGuess({
    super.key,
    required this.example,
    required this.options,
    required this.answer,
    required this.onAnswer,
  });

  final ElifbaExample example;
  final List<String> options;
  final String answer;
  final ElifbaAnswer onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElifbaArabicTap(text: example.text, fontSize: 36),
        if (example.focus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 12),
            child: Text(
              example.focus,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AssetPaths.arabicFontFamily,
                fontSize: 20,
                color: MinikColors.gold,
              ),
            ),
          ),
        ElifbaChoiceRow(
          prompt: 'Burada hangi kural gizlenmiş?',
          options: options,
          answer: answer,
          onAnswer: onAnswer,
        ),
      ],
    );
  }
}

class ElifbaQuizPage extends StatefulWidget {
  const ElifbaQuizPage({
    super.key,
    required this.items,
    required this.onFinished,
  });

  final List<ElifbaQuizItem> items;
  final void Function(int correct) onFinished;

  @override
  State<ElifbaQuizPage> createState() => _ElifbaQuizPageState();
}

class _ElifbaQuizPageState extends State<ElifbaQuizPage> {
  var _index = 0;
  var _correct = 0;
  String? _flash;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return ElifbaPrimary(
        label: 'Devam',
        onPressed: () => widget.onFinished(0),
      );
    }
    final item = widget.items[_index];
    return Column(
      children: [
        Text('Quiz ${_index + 1} / ${widget.items.length}'),
        const SizedBox(height: AppSpacing.md),
        ElifbaChoiceRow(
          prompt: item.question,
          options: item.options,
          answer: item.answer,
          onAnswer: ({required bool correct}) async {
            setState(() {
              _flash = correct
                  ? ElifbaVoice.pick(ElifbaVoice.correct, _index)
                  : ElifbaVoice.pick(ElifbaVoice.retry, _index);
            });
            if (correct) _correct += 1;
            await Future<void>.delayed(const Duration(milliseconds: 700));
            if (!mounted) return;
            if (_index >= widget.items.length - 1) {
              widget.onFinished(_correct);
            } else {
              setState(() {
                _index += 1;
                _flash = null;
              });
            }
          },
        ),
        if (_flash != null) ...[
          const SizedBox(height: 12),
          ElifbaMascot(line: _flash!),
        ],
      ],
    );
  }
}

bool _looksArabic(String value) {
  return value.runes.any((code) => code >= 0x0600 && code <= 0x06FF);
}
