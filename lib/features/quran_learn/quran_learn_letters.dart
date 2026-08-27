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
import 'quran_learn_games.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnLettersPage extends StatefulWidget {
  const QuranLearnLettersPage({
    super.key,
    required this.pack,
    this.levelId = 1,
    this.formsFocus = false,
  });

  final QuranLearningPack pack;
  final int levelId;
  final bool formsFocus;

  String get progressKind => formsFocus ? 'ql_letter_form' : 'ql_letter';

  @override
  State<QuranLearnLettersPage> createState() => _QuranLearnLettersPageState();
}

class _QuranLearnLettersPageState extends State<QuranLearnLettersPage> {
  final _audio = AudioPlayerService();
  bool _showNames = true;
  String? _selectedId;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _listen(QuranArabicLetter letter) async {
    setState(() => _selectedId = letter.id);
    final store = context.read<LocalProgressStore>();
    await QuranLearnAudio.play(_audio, store, letter.audio);
    if (!mounted) return;
    final snap = await QuranLearnProgress.load(store, widget.pack);
    if (snap.isDone(widget.progressKind, letter.id)) return;
    await QuranLearnProgress.complete(
      store,
      pack: widget.pack,
      kind: widget.progressKind,
      id: letter.id,
    );
  }

  void _openDetail(QuranArabicLetter letter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranLearnLetterDetailPage(
          pack: widget.pack,
          letter: letter,
          levelId: widget.levelId,
          formsFocus: widget.formsFocus,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final games = widget.pack.gamesForLevel(widget.levelId);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          widget.pack.titleForLevel(
            widget.levelId,
            fallback: widget.formsFocus ? 'Harf şekilleri' : 'Harfler',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: _showNames ? 'İsimleri gizle' : 'İsimleri göster',
        backgroundColor: Colors.white,
        foregroundColor: MinikColors.green,
        onPressed: () => setState(() => _showNames = !_showNames),
        child: Icon(
          _showNames ? Icons.visibility_rounded : Icons.visibility_off_rounded,
        ),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, widget.pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(widget.levelId) ?? 0;
          final total = widget.pack.letters.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total harf',
              ),
              const SizedBox(height: 8),
              QlLessonIntro(
                title: widget.formsFocus
                    ? 'Ders 1: Harflerin kelimedeki şekilleri'
                    : 'Ders 1: Harflerin bağımsız isimleri',
                cue: 'Harfin üzerine tıkla / dinleyerek öğren',
                note: 'Kırmızı olanlar kalın harflerdir.',
                hint: _showNames
                    ? 'Göz ile isimleri gizleyebilirsin. Uzun basınca şekilleri görürsün.'
                    : 'Uzun basınca isim ve şekilleri görürsün.',
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.pack.letters.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: _showNames ? 0.78 : 1,
                  ),
                  itemBuilder: (context, index) {
                    final letter = widget.pack.letters[index];
                    final learned =
                        snap?.isDone(widget.progressKind, letter.id) ?? false;
                    final arabic = widget.formsFocus
                        ? letter.forms.isolated
                        : letter.letter;
                    return QlDashTile(
                      arabic: arabic,
                      caption: _showNames ? letter.name : null,
                      heavy: letter.isHeavySound,
                      learned: learned,
                      selected: _selectedId == letter.id,
                      fontSize: 28,
                      onTap: QuranLearnAudio.resolve(letter.audio) == null
                          ? () => _openDetail(letter)
                          : () => _listen(letter),
                      onLongPress: () => _openDetail(letter),
                    );
                  },
                ),
              ),
              if (games.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                QlGamesStrip(games: games, title: 'Harf oyunları'),
              ],
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
    this.levelId,
    this.formsFocus = false,
  });

  final QuranLearningPack pack;
  final QuranArabicLetter letter;
  final int? levelId;
  final bool formsFocus;

  String get progressKind => formsFocus ? 'ql_letter_form' : 'ql_letter';

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
      kind: widget.progressKind,
      id: letter.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: widget.formsFocus
          ? '${letter.name} harfinin şekillerini öğrendin.'
          : '${letter.name} harfini öğrendin.',
      onContinue: () {
        final index = widget.pack.letters.indexWhere((item) => item.id == letter.id);
        if (index >= 0 && index + 1 < widget.pack.letters.length) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuranLearnLetterDetailPage(
                pack: widget.pack,
                letter: widget.pack.letters[index + 1],
                levelId: widget.levelId,
                formsFocus: widget.formsFocus,
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
    final forms = widget.formsFocus
        ? <(String, String)>[
            ('Tek başına', letter.forms.isolated),
            ('Başta', letter.forms.initial),
            ('Ortada', letter.forms.medial),
            ('Sonda', letter.forms.finalForm),
          ]
        : <(String, String)>[
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
            kind: widget.progressKind,
            id: letter.id,
            title: '${letter.name} (${letter.letter})',
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          if (widget.formsFocus) ...[
            const SectionLabel('Harfler ve Şekilleri'),
            MinikCard(
              color: MinikColors.mint,
              child: Column(
                children: [
                  QlBigArabic(letter.letter, fontSize: 64),
                  Text(
                    letter.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text('Bu harfin kelimedeki dört şekli.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
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
                      color: letter.isHeavySound
                          ? QlDashTile.heavyLetter
                          : MinikColors.darkGreen,
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
          ],
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
