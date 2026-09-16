import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_theme.dart';
import 'quran_learn_widgets.dart';

class QuranLearnWordsPage extends StatefulWidget {
  const QuranLearnWordsPage({
    super.key,
    required this.pack,
    this.levelId = 4,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  State<QuranLearnWordsPage> createState() => _QuranLearnWordsPageState();
}

class _QuranLearnWordsPageState extends State<QuranLearnWordsPage> {
  final _audio = AudioPlayerService();
  String? _selectedId;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _openDetail(QuranWord word) {
    Navigator.push(
      context,
      quranLearnRoute(QuranLearnWordDetailPage(pack: widget.pack, word: word)),
    );
  }

  Future<void> _listen(QuranWord word) async {
    setState(() => _selectedId = word.id);
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      word.audio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          widget.pack.titleForLevel(widget.levelId, fallback: 'Pekiştirme'),
        ),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, widget.pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(widget.levelId) ?? 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            children: [
              QlSoftProgress(
                value: widget.pack.words.isEmpty
                    ? 0
                    : done / widget.pack.words.length,
                label: '$done / ${widget.pack.words.length} kelime',
              ),
              const SizedBox(height: 8),
              QlLessonIntro(
                title: widget.pack.titleForLevel(
                  widget.levelId,
                  fallback: 'Kelime okuma',
                ),
                cue: 'Kelimenin üzerine tıkla / dinleyerek öğren',
                rule: widget.pack.levelById(widget.levelId)?.description,
                hint: 'Uzun basınca anlamı ve kaynağı görürsün.',
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.pack.words.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final word = widget.pack.words[index];
                    final learned =
                        snap?.isDone('ql_word', word.id) ?? false;
                    return QlDashTile(
                      arabic: word.arabic,
                      learned: learned,
                      selected: _selectedId == word.id,
                      fontSize: 22,
                      fillColor: index.isOdd
                          ? const Color(0xFFEAF4F8)
                          : Colors.white,
                      onTap: QuranLearnAudio.resolve(word.audio) == null
                          ? () => _openDetail(word)
                          : () => _listen(word),
                      onLongPress: () => _openDetail(word),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnWordDetailPage extends StatefulWidget {
  const QuranLearnWordDetailPage({
    super.key,
    required this.pack,
    required this.word,
  });

  final QuranLearningPack pack;
  final QuranWord word;

  @override
  State<QuranLearnWordDetailPage> createState() =>
      _QuranLearnWordDetailPageState();
}

class _QuranLearnWordDetailPageState extends State<QuranLearnWordDetailPage> {
  final _audio = AudioPlayerService();

  QuranWord get word => widget.word;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_word',
      id: word.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: 'Bu kelimeyi öğrendin.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(word.reading),
        actions: [
          FavoriteButton(
            kind: 'ql_word',
            id: word.id,
            title: '${word.reading} · ${word.arabic}',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.lavender,
            child: Column(
              children: [
                QlBigArabic(word.arabic, fontSize: 56),
                Text(word.reading, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('“${word.meaningTr}”'),
                const SizedBox(height: 6),
                SoftBadge(label: word.quranReference),
                if (word.teachingNote.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(word.teachingNote, textAlign: TextAlign.center),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: word.audio),
                const SizedBox(height: 8),
                QlColorButton(
                  arabic: word.arabic,
                  title: word.reading,
                  prompt: 'Bu kelimeyi boya.',
                  audio: word.audio,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}
