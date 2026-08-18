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

  void _deal() {
    final letters = List<QuranArabicLetter>.from(widget.pack.letters)
      ..shuffle(Random());
    final pick = letters.take(6).toList();
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
    await Future<void>.delayed(const Duration(milliseconds: 700));
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
    await context.read<LocalProgressStore>().addXp(6);
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: 'Aynı harfleri buldun.',
      continueLabel: 'Yeni oyun',
      onContinue: () => setState(_deal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        const PageHeader(
          title: 'Harf Eşleştir',
          subtitle: 'Aynı iki harfi bul.',
          image: 'assets/images/home/card_quran_learn.png',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final card = _cards[index];
            final open = card.faceUp || card.matched;
            return MinikCard(
              color: card.matched
                  ? MinikColors.mint
                  : open
                      ? Colors.white
                      : MinikColors.sky,
              padding: const EdgeInsets.all(8),
              onTap: () => _tap(index),
              child: Center(
                child: open
                    ? QlBigArabic(card.letter.letter, fontSize: 42)
                    : const Icon(
                        Icons.help_rounded,
                        size: 36,
                        color: MinikColors.darkGreen,
                      ),
              ),
            );
          },
        ),
        if (_won) ...[
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Yeni oyun',
            onPressed: () => setState(_deal),
          ),
        ],
      ],
    );
  }
}
