import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/story.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../quran_learn/quran_learn_widgets.dart';

class ProphetTrialMatchPage extends StatefulWidget {
  const ProphetTrialMatchPage({super.key});

  @override
  State<ProphetTrialMatchPage> createState() => _ProphetTrialMatchPageState();
}

class _ProphetTrialMatchPageState extends State<ProphetTrialMatchPage> {
  Future<List<ProphetTrialPair>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.stories.load().then((catalog) => catalog.imtihanPairs);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text('İmtihan Eşleştir')),
      body: AsyncBody<List<ProphetTrialPair>>(
        future: _future!,
        errorMessage: 'Oyun yüklenemedi.',
        onRetry: () => setState(
          () => _future = repos.stories.load().then((c) => c.imtihanPairs),
        ),
        builder: (pairs) {
          final playable = pairs
              .where((pair) => pair.name.isNotEmpty && pair.trial.isNotEmpty)
              .toList();
          if (playable.length < 2) {
            return const Center(child: Text('Eşleştirilecek kıssa yok.'));
          }
          return _MatchBoard(pairs: playable);
        },
      ),
    );
  }
}

class _Card {
  _Card({
    required this.pairId,
    required this.text,
    required this.isName,
  });

  final String pairId;
  final String text;
  final bool isName;
  bool faceUp = false;
  bool matched = false;
}

class _MatchBoard extends StatefulWidget {
  const _MatchBoard({required this.pairs});

  final List<ProphetTrialPair> pairs;

  @override
  State<_MatchBoard> createState() => _MatchBoardState();
}

class _MatchBoardState extends State<_MatchBoard> {
  late List<_Card> _cards;
  int? _first;
  bool _busy = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final pool = List<ProphetTrialPair>.from(widget.pairs)..shuffle(Random());
    final pick = pool.take(4).toList();
    _cards = [
      for (final pair in pick) ...[
        _Card(pairId: pair.id, text: pair.name, isName: true),
        _Card(pairId: pair.id, text: pair.trial, isName: false),
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
    if (_first == null) {
      _first = index;
      return;
    }
    final first = _cards[_first!];
    final samePair = first.pairId == card.pairId && first.isName != card.isName;
    if (samePair) {
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
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
      title: 'Maşallah!',
      subtitle: 'Peygamberleri imtihanlarıyla eşleştirdin.',
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
          title: 'İmtihan Eşleştir',
          subtitle:
              'Peygamber ismini, Kur’an’da anlatılan imtihanıyla eşleştir. Resim yok, yalnız isimler var.',
          image: 'assets/images/home/circle_stories.png',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final card = _cards[index];
            final open = card.faceUp || card.matched;
            return MinikCard(
              color: card.matched
                  ? MinikColors.mint
                  : open
                      ? (card.isName ? MinikColors.butter : MinikColors.sky)
                      : MinikColors.peach,
              padding: const EdgeInsets.all(10),
              onTap: () => _tap(index),
              child: Center(
                child: open
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card.isName ? 'Peygamber' : 'İmtihan',
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: MinikColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      )
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
