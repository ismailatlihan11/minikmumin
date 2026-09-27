import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnHeavyPage extends StatelessWidget {
  const QuranLearnHeavyPage({
    super.key,
    required this.pack,
    required this.levelId,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          pack.titleForLevel(levelId, fallback: 'Kalın / ince harfler'),
        ),
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
                label: '$done / $total',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Text(
                  pack.levelById(levelId)?.description ??
                      'Kalın ve ince harfleri ayırt edelim.',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _HeavyGroupCard(
                pack: pack,
                title: 'Kalın harfler',
                id: 'heavy',
                letters: pack.heavyLetters,
                learned: snap?.isDone('ql_heavy', 'heavy') ?? false,
              ),
              const SizedBox(height: AppSpacing.md),
              _HeavyGroupCard(
                pack: pack,
                title: 'İnce harfler',
                id: 'light',
                letters: pack.lightLetters,
                learned: snap?.isDone('ql_heavy', 'light') ?? false,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeavyGroupCard extends StatefulWidget {
  const _HeavyGroupCard({
    required this.pack,
    required this.title,
    required this.id,
    required this.letters,
    required this.learned,
  });

  final QuranLearningPack pack;
  final String title;
  final String id;
  final List<QuranArabicLetter> letters;
  final bool learned;

  @override
  State<_HeavyGroupCard> createState() => _HeavyGroupCardState();
}

class _HeavyGroupCardState extends State<_HeavyGroupCard> {
  final _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_heavy',
      id: widget.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${widget.title} grubunu tamamladın.',
      continueLabel: 'Tamam',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MinikCard(
      color: widget.learned ? MinikColors.mint : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final letter in widget.letters)
                GestureDetector(
                  onTap: QuranLearnAudio.resolve(letter.audio) == null
                      ? null
                      : () => QuranLearnAudio.play(
                            _audio,
                            context.read<LocalProgressStore>(),
                            letter.audio,
                          ),
                  child: Column(
                    children: [
                      QlBigArabic(letter.letter, fontSize: 28),
                      Text(
                        letter.name,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          QlPrimaryBar(
            label: widget.learned ? 'Tekrar işaretle' : 'Öğrendim',
            onPressed: _mark,
          ),
        ],
      ),
    );
  }
}
