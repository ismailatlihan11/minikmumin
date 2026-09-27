import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_tajweed_marks.dart';
import 'quran_learn_widgets.dart';

class QuranLearnTajweedPage extends StatelessWidget {
  const QuranLearnTajweedPage({
    super.key,
    required this.pack,
    this.levelId = 6,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final lessons = pack.tajweedForLevel(levelId);
    final games = pack.gamesForLevel(levelId);
    return Scaffold(
      backgroundColor: MinikColors.background,
      appBar: AppBar(
        title:
            Text(pack.titleForLevel(levelId, fallback: 'Tecvid Uygulamaları')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: lessons.isEmpty ? 0 : done / lessons.length,
                label: '$done / ${lessons.length} ders',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Text(
                  pack.levelById(levelId)?.description ??
                      'Tecvid kurallarını gerçek ayetlerde uygulayalım.',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final lesson in lessons)
                ContentTile(
                  title: lesson.title,
                  subtitle: lesson.shortDescription,
                  color: snap?.isDone('ql_tajweed', lesson.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: NumberBadge('${lesson.order}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnTajweedDetailPage(
                        pack: pack,
                        lesson: lesson,
                      ),
                    ),
                  ),
                ),
              if (games.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                QlGamesStrip(games: games, title: 'Tecvid oyunları'),
              ],
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnTajweedDetailPage extends StatefulWidget {
  const QuranLearnTajweedDetailPage({
    super.key,
    required this.pack,
    required this.lesson,
  });

  final QuranLearningPack pack;
  final QuranTajweedLesson lesson;

  @override
  State<QuranLearnTajweedDetailPage> createState() =>
      _QuranLearnTajweedDetailPageState();
}

class _QuranLearnTajweedDetailPageState
    extends State<QuranLearnTajweedDetailPage> {
  final _audio = AudioPlayerService();
  Future<List<QuranVerse>>? _practiceAyahs;

  QuranTajweedLesson get lesson => widget.lesson;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_tajweed',
      id: lesson.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${lesson.title} dersini tamamladın.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinikColors.background,
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          FavoriteButton(
            kind: 'ql_tajweed',
            id: lesson.id,
            title: lesson.title,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.peach,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SoftBadge(label: 'Nedir?'),
                const SizedBox(height: 8),
                Text(lesson.shortDescription),
                const SizedBox(height: 12),
                const SoftBadge(label: 'Nasıl okunur?'),
                const SizedBox(height: 8),
                Text(lesson.explanation),
                if (lesson.qalqalaLetters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final letter in lesson.qalqalaLetters)
                        SoftBadge(label: letter, color: MinikColors.mint),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(
                  audio: _audio,
                  path: QuranLearnAudio.resolve(lesson.audio) ??
                      QuranLearnAudio.tajweedExamplePath(lesson.id, index: 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _QlTajweedCompareStrip(
            pack: widget.pack,
            lesson: lesson,
            audio: _audio,
          ),
          const SectionLabel('Kural örnekleri'),
          for (var i = 0; i < lesson.examples.length; i++)
            MinikCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (quranLearnTajweedExampleLabel(lesson.id, i) != null) ...[
                    SoftBadge(
                      label: quranLearnTajweedExampleLabel(lesson.id, i)!,
                    ),
                    const SizedBox(height: 8),
                  ],
                  QlTajweedFocusArabic(
                    lesson.examples[i].arabic,
                    focus: lesson.examples[i].focus,
                    fontSize: 32,
                  ),
                  const SizedBox(height: 6),
                  Text('Odak: ${lesson.examples[i].focus}'),
                  Text(
                      quranLearnTajweedReference(lesson.examples[i].reference)),
                  const SizedBox(height: 8),
                  QlPlayListen(
                    audio: _audio,
                    path: QuranLearnAudio.tajweedExamplePath(
                      lesson.id,
                      index: i,
                      jsonAudio: lesson.examples[i].audio,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: QlColorButton(
                      arabic: lesson.examples[i].arabic,
                      title: lesson.title,
                      prompt: 'Bu örneği boya.',
                      audio: QuranLearnAudio.tajweedExamplePath(
                        lesson.id,
                        index: i,
                        jsonAudio: lesson.examples[i].audio,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          QlTajweedAyahPractice(
            lesson: lesson,
            future: _practiceAyahs ??= _loadPracticeAyahs(),
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }

  Future<List<QuranVerse>> _loadPracticeAyahs() async {
    final quran = context.read<ContentRepositories>().quran;
    final seen = <String>{};
    final out = <QuranVerse>[];
    for (final surah in widget.pack.surahs) {
      final verses = await quran.getSurah(surah.surahNumber);
      final from = surah.ayahFrom;
      final to = surah.ayahTo ?? from;
      for (final verse in verses) {
        if (from != null &&
            (verse.ayahNo < from || verse.ayahNo > (to ?? from))) {
          continue;
        }
        if (!quranLearnLessonMatchesAyah(
          lesson: lesson,
          arabic: verse.arabic,
        )) {
          continue;
        }
        final key = '${verse.surahId}:${verse.ayahNo}';
        if (!seen.add(key)) continue;
        out.add(verse);
        if (out.length >= 12) return out;
      }
    }
    return out;
  }
}

class _QlTajweedCompareStrip extends StatelessWidget {
  const _QlTajweedCompareStrip({
    required this.pack,
    required this.lesson,
    required this.audio,
  });

  final QuranLearningPack pack;
  final QuranTajweedLesson lesson;
  final AudioPlayerService audio;

  @override
  Widget build(BuildContext context) {
    final cards = quranLearnCompareCards(
      lessonId: lesson.id,
      lessons: pack.tajweed,
    );
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Karşılaştırma'),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Kuralları dinleyerek ayırt et.'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final card in cards)
              SizedBox(
                width: 156,
                child: MinikCard(
                  color: MinikColors.mint,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  onTap: () {
                    final path = QuranLearnAudio.tajweedExamplePath(
                      card.lessonId ?? lesson.id,
                      index: card.exampleIndex,
                      jsonAudio: card.audio,
                    );
                    if (path == null) return;
                    QuranLearnAudio.play(
                      audio,
                      context.read<LocalProgressStore>(),
                      path,
                    );
                  },
                  child: Column(
                    children: [
                      SoftBadge(label: card.label),
                      const SizedBox(height: 8),
                      QlTajweedFocusArabic(
                        card.arabic,
                        focus: card.arabic,
                        fontSize: 22,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class QlTajweedAyahPractice extends StatelessWidget {
  const QlTajweedAyahPractice({
    super.key,
    required this.lesson,
    required this.future,
  });

  final QuranTajweedLesson lesson;
  final Future<List<QuranVerse>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuranVerse>>(
      future: future,
      builder: (context, snapshot) {
        final verses = snapshot.data;
        if (verses == null || verses.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Ayetlerde uygula'),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Bu kuralı öğrendiğin surelerde bul. Sarı yer kuralın geçtiği kısımdır.',
              ),
            ),
            for (final verse in verses)
              MinikCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SoftBadge(
                        label: quranLearnTajweedReference(
                          '${verse.surahId}:${verse.ayahNo}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    QlTajweedFocusArabic(
                      verse.arabic,
                      focus: quranLearnLessonFocusInAyah(
                            lesson: lesson,
                            arabic: verse.arabic,
                          ) ??
                          '',
                      fontSize: 26,
                    ),
                    if (verse.hasMeal) ...[
                      const SizedBox(height: 8),
                      Text(
                        verse.meal,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          color: MinikColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: QlColorButton(
                        arabic: verse.arabic,
                        title: lesson.title,
                        prompt: 'Bu ayette kuralı boya.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
