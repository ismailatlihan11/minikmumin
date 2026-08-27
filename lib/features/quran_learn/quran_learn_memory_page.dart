import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_widgets.dart';

enum QuranLearnMemoryLevel {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        easy => 'Kolay',
        medium => 'Orta',
        hard => 'Zor',
      };

  /// Current game is the middle board: six pairs, three columns.
  int get pairCount => switch (this) {
        easy => 4,
        medium => 6,
        hard => 8,
      };

  int get columns => switch (this) {
        easy => 2,
        medium => 3,
        hard => 4,
      };

  int get xp => pairCount;

  int get rows => ((pairCount * 2) / columns).ceil();

  double get letterSize => switch (this) {
        easy => 28,
        medium => 32,
        hard => 26,
      };

  double get cardGap => switch (this) {
        easy => 6,
        medium => 8,
        hard => 6,
      };

  double get cardIconSize => switch (this) {
        easy => 22,
        medium => 28,
        hard => 22,
      };

  static double boardAspectRatio({
    required double width,
    required double height,
    required int columns,
    required int rows,
    required double gap,
  }) {
    final cardWidth = (width - gap * (columns - 1)) / columns;
    final cardHeight = (height - gap * (rows - 1)) / rows;
    if (cardWidth <= 0 || cardHeight <= 0) return 1;
    return cardWidth / cardHeight;
  }

  Duration get mismatchPause => switch (this) {
        easy => const Duration(milliseconds: 900),
        medium => const Duration(milliseconds: 700),
        hard => const Duration(milliseconds: 500),
      };
}

class QuranLearnMemoryPage extends StatefulWidget {
  const QuranLearnMemoryPage({super.key});

  @override
  State<QuranLearnMemoryPage> createState() => _QuranLearnMemoryPageState();
}

class _QuranLearnMemoryPageState extends State<QuranLearnMemoryPage> {
  Future<QuranLearningPack>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= context.read<ContentRepositories>().quranLearning.load();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('Harf Eşleştir')),
      body: AsyncBody<QuranLearningPack>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(
          () => _future = context.read<ContentRepositories>().quranLearning.load(),
        ),
        builder: (pack) => _MemoryBoard(pack: pack),
      ),
    );
  }
}

class _Card {
  _Card({required this.letter, required this.key});

  final QuranArabicLetter letter;
  final String key;
  bool faceUp = false;
  bool matched = false;
}

class _MemoryBoard extends StatefulWidget {
  const _MemoryBoard({required this.pack});

  final QuranLearningPack pack;

  @override
  State<_MemoryBoard> createState() => _MemoryBoardState();
}

class _MemoryBoardState extends State<_MemoryBoard> {
  final _audio = AudioPlayerService();
  QuranLearnMemoryLevel _level = QuranLearnMemoryLevel.medium;
  late List<_Card> _cards;
  int? _first;
  bool _busy = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _setLevel(QuranLearnMemoryLevel level) {
    if (_level == level) return;
    setState(() {
      _level = level;
      _deal();
    });
  }

  void _deal() {
    final letters = List<QuranArabicLetter>.from(widget.pack.letters)
      ..shuffle(Random());
    final pick = letters.take(_level.pairCount).toList();
    _cards = [
      for (final letter in pick) ...[
        _Card(letter: letter, key: '${letter.id}-a'),
        _Card(letter: letter, key: '${letter.id}-b'),
      ],
    ]..shuffle(Random());
    _first = null;
    _busy = false;
    _won = false;
  }

  Future<void> _tap(int index) async {
    if (_busy || _won) return;
    final card = _cards[index];
    if (card.faceUp || card.matched) return;
    setState(() => card.faceUp = true);
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      card.letter.audio,
    );
    if (_first == null) {
      _first = index;
      return;
    }
    final first = _cards[_first!];
    if (first.letter.id == card.letter.id) {
      setState(() {
        first.matched = true;
        card.matched = true;
        _first = null;
      });
      if (_cards.every((item) => item.matched)) {
        await _onWin();
      }
      return;
    }
    _busy = true;
    await Future<void>.delayed(_level.mismatchPause);
    if (!mounted) return;
    setState(() {
      first.faceUp = false;
      card.faceUp = false;
      _first = null;
      _busy = false;
    });
  }

  Future<void> _onWin() async {
    if (_won) return;
    setState(() => _won = true);
    await context.read<LocalProgressStore>().addXp(_level.xp);
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: 'Aynı harfleri buldun.',
      continueLabel: 'Yeni oyun',
      onContinue: () => setState(_deal),
    );
  }

  Widget _tile(int index) {
    if (index < 0 || index >= _cards.length) {
      return const SizedBox.shrink();
    }
    final card = _cards[index];
    final open = card.faceUp || card.matched;
    return SizedBox.expand(
      child: MinikCard(
        color: card.matched
            ? MinikColors.mint
            : open
                ? Colors.white
                : MinikColors.sky,
        padding: const EdgeInsets.all(4),
        onTap: () => _tap(index),
        child: Center(
          child: FittedBox(
            child: open
                ? QlBigArabic(card.letter.letter, fontSize: _level.letterSize)
                : Icon(
                    Icons.help_rounded,
                    size: _level.cardIconSize,
                    color: MinikColors.darkGreen,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Aynı iki harfi bul.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final level in QuranLearnMemoryLevel.values)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _level == level,
                  selectedColor: MinikColors.mint,
                  onSelected: (_) => _setLevel(level),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              children: [
                for (var row = 0; row < _level.rows; row++) ...[
                  if (row > 0) SizedBox(height: _level.cardGap),
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < _level.columns; col++) ...[
                          if (col > 0) SizedBox(width: _level.cardGap),
                          Expanded(child: _tile(row * _level.columns + col)),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_won) ...[
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Yeni oyun',
              onPressed: () => setState(_deal),
            ),
          ],
        ],
      ),
    );
  }
}
