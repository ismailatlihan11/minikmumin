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

class QuranLearnMahrajPage extends StatelessWidget {
  const QuranLearnMahrajPage({
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
      backgroundColor: MinikColors.background,
      appBar: AppBar(
        title: Text(pack.titleForLevel(levelId, fallback: 'Mahreçler')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          final total = pack.mahrajGroups.length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total grup',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Text(
                  pack.levelById(levelId)?.description ??
                      'Harflerin çıkış yerlerini gruplayarak tanıyalım.',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final group in pack.mahrajGroups)
                ContentTile(
                  title: group.title,
                  subtitle: group.description,
                  color: snap?.isDone('ql_mahraj', group.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: Icon(
                    Icons.record_voice_over_rounded,
                    color: MinikColors.green,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnMahrajDetailPage(
                        pack: pack,
                        group: group,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnMahrajDetailPage extends StatefulWidget {
  const QuranLearnMahrajDetailPage({
    super.key,
    required this.pack,
    required this.group,
  });

  final QuranLearningPack pack;
  final QuranMahrajGroup group;

  @override
  State<QuranLearnMahrajDetailPage> createState() =>
      _QuranLearnMahrajDetailPageState();
}

class _QuranLearnMahrajDetailPageState
    extends State<QuranLearnMahrajDetailPage> {
  final _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _play(QuranArabicLetter letter) async {
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      letter.audio,
    );
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_mahraj',
      id: widget.group.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${widget.group.title} mahrecini öğrendin.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letters = [
      for (final id in widget.group.letterIds)
        if (widget.pack.letterById(id) != null) widget.pack.letterById(id)!,
    ];
    return Scaffold(
      backgroundColor: MinikColors.background,
      appBar: AppBar(title: Text(widget.group.title)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.peach,
            child: Text(widget.group.description),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final letter in letters)
                SizedBox(
                  width: 72,
                  child: MinikCard(
                    padding: const EdgeInsets.all(8),
                    onTap: QuranLearnAudio.resolve(letter.audio) == null
                        ? null
                        : () => _play(letter),
                    child: Column(
                      children: [
                        QlBigArabic(letter.letter, fontSize: 28),
                        Text(
                          letter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}
