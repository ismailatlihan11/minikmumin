import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_memory_page.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

/// Invisible bidi/format marks must not make a correct tap fail.
String qlNormalizeAnswer(String value) {
  return value
      .replaceAll(
        RegExp(r'[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'),
        '',
      )
      .trim();
}

bool qlSameAnswer(String a, String b) =>
    qlNormalizeAnswer(a) == qlNormalizeAnswer(b);

bool qlSameSequence(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!qlSameAnswer(a[i], b[i])) return false;
  }
  return true;
}

String quranLearnGameTypeLabel(String type) {
  switch (type) {
    case 'find_letter':
      return 'Harfi Bul';
    case 'find_vowel':
      return 'Sesini Bul';
    case 'build_word':
      return 'Birleştir';
    case 'choose_reading':
      return 'Okunuşu Seç';
    case 'choose_surah':
      return 'Sureyi Bul';
    case 'find_tajweed':
      return 'Kuralı Bul';
    default:
      return 'Oyun';
  }
}

class QlGamesStrip extends StatelessWidget {
  const QlGamesStrip({
    super.key,
    required this.games,
    this.title = 'Oyunlar',
  });

  final List<QuranLearningGame> games;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        for (final game in games)
          ContentTile(
            title: game.question,
            subtitle: quranLearnGameTypeLabel(game.type),
            leading: const Icon(
              Icons.sports_esports_rounded,
              color: MinikColors.green,
            ),
            onTap: () => openQuranLearnGame(context, game),
          ),
      ],
    );
  }
}

Future<void> openQuranLearnGame(
  BuildContext context,
  QuranLearningGame game,
) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => QuranLearnGamePage(game: game)),
  );
}

class QuranLearnGamesHubPage extends StatefulWidget {
  const QuranLearnGamesHubPage({super.key});

  @override
  State<QuranLearnGamesHubPage> createState() => _QuranLearnGamesHubPageState();
}

class _QuranLearnGamesHubPageState extends State<QuranLearnGamesHubPage> {
  Future<QuranLearningPack>? _future;

  @override
  Widget build(BuildContext context) {
    _future ??= context.read<ContentRepositories>().quranLearning.load();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text("Kur'an Öğrenme Oyunları")),
      body: AsyncBody<QuranLearningPack>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(
          () => _future = context.read<ContentRepositories>().quranLearning.load(),
        ),
        builder: (pack) => ListView(
          padding: AppSpacing.page,
          children: [
            const PageHeader(
              title: "Kur'an Öğrenme Oyunları",
              subtitle: 'Harfleri boya, eşleştir, bul ve birleştir.',
              image: 'assets/images/home/card_quran_learn.png',
            ),
            ContentTile(
              title: 'Harfleri boya',
              subtitle: 'Bir harf seç, parmağınla boya.',
              leading: const Icon(Icons.palette_rounded, color: MinikColors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuranLearnColorHubPage(),
                ),
              ),
            ),
            ContentTile(
              title: 'Harf eşleştir',
              subtitle: 'Kolay, orta ve zor. Aynı iki harfi bul.',
              leading: const Icon(Icons.grid_view_rounded, color: MinikColors.green),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuranLearnMemoryPage(),
                ),
              ),
            ),
            QlGamesStrip(games: pack.games, title: 'Tüm oyunlar'),
          ],
        ),
      ),
    );
  }
}

class QuranLearnDrillGamesPage extends StatelessWidget {
  const QuranLearnDrillGamesPage({
    super.key,
    required this.pack,
    this.levelId = 13,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final games = pack.gamesForLevel(levelId);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(pack.titleForLevel(levelId, fallback: 'Mini oyunlar')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          final total = pack.realLessonCount(levelId);
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total oyun',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Text(
                  pack.levelById(levelId)?.description ??
                      'Harf, hareke ve kelime oyunlarıyla pekiştirelim.',
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ContentTile(
                title: 'Harfleri boya',
                subtitle: 'Bir harf seç, parmağınla boya.',
                leading: const Icon(
                  Icons.palette_rounded,
                  color: MinikColors.green,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuranLearnColorHubPage(),
                  ),
                ),
              ),
              ContentTile(
                title: 'Harf eşleştir',
                subtitle: 'Aynı iki harfi bul.',
                leading: const Icon(
                  Icons.grid_view_rounded,
                  color: MinikColors.green,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuranLearnMemoryPage(),
                  ),
                ),
              ),
              if (games.isNotEmpty)
                QlGamesStrip(games: games, title: 'Alıştırma oyunları'),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnGamePage extends StatefulWidget {
  const QuranLearnGamePage({super.key, required this.game});

  final QuranLearningGame game;

  @override
  State<QuranLearnGamePage> createState() => _QuranLearnGamePageState();
}

class _QuranLearnGamePageState extends State<QuranLearnGamePage> {
  String? _picked;
  bool _won = false;

  QuranLearningGame get game => widget.game;

  Future<void> _onCorrect() async {
    if (_won) return;
    setState(() => _won = true);
    final store = context.read<LocalProgressStore>();
    final pack = await context.read<ContentRepositories>().quranLearning.load();
    await store.addCounter(quranLearnCorrectAnswers);
    if (game.isBuildWord) {
      await store.addCounter(quranLearnCombinations);
    }
    await QuranLearnProgress.complete(
      store,
      pack: pack,
      kind: 'ql_game',
      id: game.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: game.feedbackCorrect,
      continueLabel: 'Tamam',
    );
  }

  void _onWrong() {
    setState(() => _picked = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(game.feedbackWrong)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(quranLearnGameTypeLabel(game.type))),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.mint,
            child: Text(
              game.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (game.isBuildWord)
            QlCombineBoard(
              parts: game.parts.isNotEmpty ? game.parts : game.correctOrder,
              target: game.correctOrder.isNotEmpty ? game.correctOrder : game.parts,
              result: game.result,
              won: _won,
              onCorrect: _onCorrect,
              onWrong: _onWrong,
            )
          else
            _ChoicePlay(
              game: game,
              picked: _picked,
              won: _won,
              onPick: (option) {
                if (_won) return;
                setState(() => _picked = option);
                if (qlSameAnswer(option, game.correctAnswer)) {
                  _onCorrect();
                } else {
                  _onWrong();
                }
              },
            ),
          if (_won) ...[
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Tamam',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoicePlay extends StatelessWidget {
  const _ChoicePlay({
    required this.game,
    required this.picked,
    required this.won,
    required this.onPick,
  });

  final QuranLearningGame game;
  final String? picked;
  final bool won;
  final ValueChanged<String> onPick;

  bool get _arabicOptions {
    return game.type == 'find_letter' ||
        game.type == 'find_vowel' ||
        game.options.any((item) => RegExp(r'[\u0600-\u06FF]').hasMatch(item));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in game.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MinikCard(
              color: won && qlSameAnswer(option, game.correctAnswer)
                  ? MinikColors.mint
                  : picked == option && !qlSameAnswer(option, game.correctAnswer)
                      ? MinikColors.blush
                      : MinikColors.surface,
              onTap: won ? null : () => onPick(option),
              child: SizedBox(
                height: 64,
                child: Center(
                  child: _arabicOptions
                      ? Text(
                          option,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: AssetPaths.arabicFontFamily,
                            fontSize: 32,
                            color: MinikColors.darkGreen,
                          ),
                        )
                      : Text(
                          option,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class QlCombineBoard extends StatefulWidget {
  const QlCombineBoard({
    super.key,
    required this.parts,
    required this.target,
    required this.onCorrect,
    required this.onWrong,
    this.result = '',
    this.won = false,
  });

  final List<String> parts;
  final List<String> target;
  final String result;
  final bool won;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  State<QlCombineBoard> createState() => _QlCombineBoardState();
}

class _QlCombineBoardState extends State<QlCombineBoard> {
  late List<String> _pool;
  late List<String?> _slots;

  List<String> get _target => widget.target;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _pool = List<String>.from(widget.parts)..shuffle(Random());
    _slots = List<String?>.filled(_target.length, null);
  }

  void _check() {
    if (_slots.any((slot) => slot == null)) return;
    final filled = _slots.cast<String>();
    final joined = filled.map(qlNormalizeAnswer).join();
    final result = qlNormalizeAnswer(widget.result);
    final ok = qlSameSequence(filled, _target) ||
        (result.isNotEmpty && joined == result);
    if (ok) {
      widget.onCorrect();
    } else {
      widget.onWrong();
      setState(_reset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.result.isNotEmpty) ...[
          QlBigArabic(widget.result, fontSize: 42),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: [
            for (var i = 0; i < _slots.length; i++)
              DragTarget<String>(
                onAcceptWithDetails: (details) {
                  if (widget.won) return;
                  setState(() {
                    final previous = _slots[i];
                    if (previous != null) _pool.add(previous);
                    _slots[i] = details.data;
                    _pool.remove(details.data);
                  });
                  _check();
                },
                builder: (context, candidate, rejected) {
                  final value = _slots[i];
                  return _ArabicChip(
                    text: value ?? ' ',
                    highlighted: candidate.isNotEmpty,
                    onTap: value == null || widget.won
                        ? null
                        : () => setState(() {
                              _pool.add(value);
                              _slots[i] = null;
                            }),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: [
            for (final part in _pool)
              Draggable<String>(
                data: part,
                feedback: Material(
                  color: Colors.transparent,
                  child: _ArabicChip(text: part, highlighted: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _ArabicChip(text: part),
                ),
                child: _ArabicChip(
                  text: part,
                  onTap: widget.won
                      ? null
                      : () {
                          final empty = _slots.indexWhere((slot) => slot == null);
                          if (empty < 0) return;
                          setState(() {
                            _slots[empty] = part;
                            _pool.remove(part);
                          });
                          _check();
                        },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ArabicChip extends StatelessWidget {
  const _ArabicChip({
    required this.text,
    this.highlighted = false,
    this.onTap,
  });

  final String text;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 56),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted ? MinikColors.mint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: MinikColors.green.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: AssetPaths.arabicFontFamily,
            fontSize: 28,
            color: MinikColors.darkGreen,
          ),
        ),
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
