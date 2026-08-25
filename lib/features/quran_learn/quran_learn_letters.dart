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
import 'quran_learn_widgets.dart';

class QuranLearnLettersPage extends StatelessWidget {
  const QuranLearnLettersPage({super.key, required this.pack});

  final QuranLearningPack pack;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(pack.titleForLevel(1, fallback: 'Harfler')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(1) ?? 0;
          final total = pack.letters.length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total harf',
              ),
              const SizedBox(height: AppSpacing.md),
              MinikCard(
                color: MinikColors.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.levelById(1)?.description ??
                          'Harfler ve isimleri, sesleri, şekilleri.',
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w700,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('· Harfler ve İsimleri'),
                    const Text('· Harfler ve Sesleri'),
                    const Text('· Harfler ve Şekilleri'),
                    const Text('· Pekiştirme'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pack.letters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final letter = pack.letters[index];
                  final learned = snap?.isDone('ql_letter', letter.id) ?? false;
                  return MinikCard(
                    color: learned ? MinikColors.mint : Colors.white,
                    padding: const EdgeInsets.all(6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuranLearnLetterDetailPage(
                          pack: pack,
                          letter: letter,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QlBigArabic(letter.letter, fontSize: 28),
                        Text(
                          letter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MinikColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnLetterDetailPage extends StatefulWidget {
  const QuranLearnLetterDetailPage({
    super.key,
    required this.pack,
    required this.letter,
  });

  final QuranLearningPack pack;
  final QuranArabicLetter letter;

  @override
  State<QuranLearnLetterDetailPage> createState() =>
      _QuranLearnLetterDetailPageState();
}

class _QuranLearnLetterDetailPageState extends State<QuranLearnLetterDetailPage> {
  final _audio = AudioPlayerService();

  QuranArabicLetter get letter => widget.letter;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      letter.audio,
    );
  }

  Future<void> _markLearned() async {
    final store = context.read<LocalProgressStore>();
    await QuranLearnProgress.complete(
      store,
      pack: widget.pack,
      kind: 'ql_letter',
      id: letter.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${letter.name} harfini öğrendin.',
      onContinue: () {
        final index = widget.pack.letters.indexWhere((item) => item.id == letter.id);
        if (index >= 0 && index + 1 < widget.pack.letters.length) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuranLearnLetterDetailPage(
                pack: widget.pack,
                letter: widget.pack.letters[index + 1],
              ),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final forms = <(String, String)>[
      ('Tek başına', letter.forms.isolated),
      if (letter.joinsBothSides) ...[
        ('Başta', letter.forms.initial),
        ('Ortada', letter.forms.medial),
      ],
      if (letter.forms.finalForm.isNotEmpty &&
          letter.forms.finalForm != letter.forms.isolated)
        ('Sonda', letter.forms.finalForm)
      else if (letter.joinsBothSides)
        ('Sonda', letter.forms.finalForm),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(letter.name),
        actions: [
          FavoriteButton(
            kind: 'ql_letter',
            id: letter.id,
            title: '${letter.name} (${letter.letter})',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const SectionLabel('Harfler ve İsimleri'),
          MinikCard(
            color: MinikColors.mint,
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: QlBigArabic(
                    letter.letter,
                    fontSize: 86,
                    onTap: QuranLearnAudio.resolve(letter.audio) == null
                        ? null
                        : _play,
                  ),
                ),
                Text(
                  letter.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text('Bu harf ${letter.name}.'),
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: letter.audio),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Harfler ve Sesleri'),
          MinikCard(
            child: Column(
              children: [
                Text('Yaklaşık ses: ${letter.approximateTurkishSound}'),
                if (letter.isHeavySound) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: MinikColors.peach,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Kalın harf',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                QlPlayListen(audio: _audio, path: letter.audio),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Harfler ve Şekilleri'),
          Row(
            children: [
              for (var i = 0; i < forms.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                QlFormChip(
                  label: forms[i].$1,
                  arabic: forms[i].$2,
                  onTap: () => openQlColoring(
                    context,
                    arabic: forms[i].$2,
                    title: '${letter.name} · ${forms[i].$1}',
                    prompt: '${letter.name} harfinin ${forms[i].$1.toLowerCase()} biçimini boya.',
                    audio: letter.audio,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Pekiştirme'),
          Center(
            child: QlColorButton(
              arabic: letter.letter,
              title: '${letter.name} boya',
              prompt: 'Parmağınla ${letter.name} harfini boya.',
              audio: letter.audio,
              pack: widget.pack,
              progressKind: 'ql_color',
              progressId: letter.id,
              celebrationSubtitle: '${letter.name} harfini boyadın.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _markLearned),
        ],
      ),
    );
  }
}
