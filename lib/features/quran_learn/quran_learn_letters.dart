import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import '../elifba_adventure/elifba_letter_truck_drop.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_review.dart';
import 'quran_learn_theme.dart';
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
  bool _shuffled = false;
  bool _introDone = false;
  List<QuranArabicLetter>? _ordered;
  String? _selectedId;

  List<QuranArabicLetter> get _letters {
    final ordered = _ordered;
    if (ordered != null) return ordered;
    return widget.pack.letters;
  }

  void _toggleOrder() {
    setState(() {
      if (_shuffled) {
        _ordered = null;
        _shuffled = false;
      } else {
        _ordered = List<QuranArabicLetter>.of(widget.pack.letters)..shuffle();
        _shuffled = true;
      }
    });
  }

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
    if (mounted) setState(() {});
  }

  void _openDetail(QuranArabicLetter letter) {
    Navigator.push(
      context,
      quranLearnRoute(
        QuranLearnLetterDetailPage(
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
    return Scaffold(
      backgroundColor:
          widget.formsFocus ? const Color(0xFFF5EEDC) : const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(
          widget.pack.titleForLevel(
            widget.levelId,
            fallback: widget.formsFocus ? 'Harfler ve şekilleri' : 'Harfler',
          ),
        ),
      ),
      floatingActionButton: null,
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, widget.pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(widget.levelId) ?? 0;
          final total = widget.pack.letters.length;
          if (widget.formsFocus) {
            return _ElifbaFormsLesson(
              pack: widget.pack,
              letters: widget.pack.letters,
              snap: snap,
              progressKind: widget.progressKind,
              selectedId: _selectedId,
              progressLabel: '$done / $total harf',
              progressValue: total == 0 ? 0 : done / total,
              onListen: _listen,
              onLongPress: _openDetail,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total harf',
              ),
              const SizedBox(height: 8),
              const QlLessonIntro(
                title: 'Harfler',
                cue: 'Harfe dokun, dinle',
                note: 'Kırmızı olanlar kalın harflerdir.',
                hint: 'Uzun basınca şekilleri görürsün.',
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _introDone = false),
                      icon: const Icon(Icons.local_shipping_rounded, size: 20),
                      label: const Text('Kamyonu getir'),
                      style: TextButton.styleFrom(
                        foregroundColor: MinikColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _toggleOrder,
                      icon: Icon(
                        _shuffled
                            ? Icons.sort_rounded
                            : Icons.shuffle_rounded,
                        size: 20,
                      ),
                      label: Text(_shuffled ? 'Sıraya diz' : 'Karıştır'),
                      style: TextButton.styleFrom(
                        foregroundColor: MinikColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showNames = !_showNames),
                      icon: Icon(
                        _showNames
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                      ),
                      label: Text(
                        _showNames ? 'İsimleri gizle' : 'İsimleri göster',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: MinikColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_introDone)
                LetterTruckDropIntro(
                  glyphs: [for (final letter in _letters) letter.letter],
                  names: _showNames
                      ? [for (final letter in _letters) letter.name]
                      : const [],
                  columns: 5,
                  cellWidth: 64,
                  cellHeight: _showNames ? 80 : 68,
                  rtl: true,
                  onFinished: () {
                    if (mounted) setState(() => _introDone = true);
                  },
                )
              else
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _letters.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: _showNames ? 0.78 : 1,
                    ),
                    itemBuilder: (context, index) {
                      final letter = _letters[index];
                      final learned =
                          snap?.isDone(widget.progressKind, letter.id) ?? false;
                      return QlDashTile(
                        arabic: letter.letter,
                        caption: _showNames ? letter.name : null,
                        heavy: letter.isHeavySound,
                        learned: learned,
                        selected: _selectedId == letter.id,
                        fontSize: 28,
                        onTap: () => _listen(letter),
                        onLongPress: () => _openDetail(letter),
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
            quranLearnRoute(
              QuranLearnLetterDetailPage(
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
            ('Sonda', letter.forms.finalForm),
            ('Ortada', letter.forms.medial),
            ('Başta', letter.forms.initial),
          ]
        : <(String, String)>[
            ('Tek başına', letter.forms.isolated),
            if (letter.forms.finalForm.isNotEmpty &&
                letter.forms.finalForm != letter.forms.isolated)
              ('Sonda', letter.forms.finalForm)
            else if (letter.joinsBothSides)
              ('Sonda', letter.forms.finalForm),
            if (letter.joinsBothSides) ...[
              ('Ortada', letter.forms.medial),
              ('Başta', letter.forms.initial),
            ],
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
                      child: Text(
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
                  QlPlayListen(
                    audio: _audio,
                    path: QuranLearnAudio.exercisePath(letter.audio, 'fatha') ??
                        letter.audio,
                  ),
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

class _ElifbaFormsLesson extends StatelessWidget {
  const _ElifbaFormsLesson({
    required this.pack,
    required this.letters,
    required this.snap,
    required this.progressKind,
    required this.selectedId,
    required this.progressLabel,
    required this.progressValue,
    required this.onListen,
    required this.onLongPress,
  });

  final QuranLearningPack pack;
  final List<QuranArabicLetter> letters;
  final QuranLearnSnapshot? snap;
  final String progressKind;
  final String? selectedId;
  final String progressLabel;
  final double progressValue;
  final ValueChanged<QuranArabicLetter> onListen;
  final ValueChanged<QuranArabicLetter> onLongPress;

  List<QuranArabicLetter> get _thin =>
      [for (final letter in letters) if (!letter.isHeavySound) letter];

  List<QuranArabicLetter> get _heavy =>
      [for (final letter in letters) if (letter.isHeavySound) letter];

  List<QuranArabicLetter> get _lisp =>
      [for (final letter in letters) if (letter.isLispSound) letter];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        QlSoftProgress(value: progressValue, label: progressLabel),
        const SizedBox(height: 14),
        const Text(
          'Harfler ve Şekilleri',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3A332C),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6DBC5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC4B79A)),
          ),
          child: const Text(
            'Harf kelimenin başına, ortasına ve sonuna göre değişir. Önce tabloya bak, sonra slaytta büyüt.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A332C),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _FormsGroup(
          title: 'İnce sesli harfler',
          letters: _thin,
          snap: snap,
          progressKind: progressKind,
          selectedId: selectedId,
          onListen: onListen,
          onLongPress: onLongPress,
        ),
        const SizedBox(height: 22),
        _FormsGroup(
          title: 'Kalın sesli harfler',
          letters: _heavy,
          snap: snap,
          progressKind: progressKind,
          selectedId: selectedId,
          onListen: onListen,
          onLongPress: onLongPress,
        ),
        const SizedBox(height: 22),
        _FormsGroup(
          title: 'Peltek harfler',
          letters: _lisp,
          snap: snap,
          progressKind: progressKind,
          selectedId: selectedId,
          onListen: onListen,
          onLongPress: onLongPress,
        ),
        const SizedBox(height: 28),
        QlLetterReviewSection(pack: pack, embedded: true),
      ],
    );
  }
}

class _FormsGroup extends StatelessWidget {
  const _FormsGroup({
    required this.title,
    required this.letters,
    required this.snap,
    required this.progressKind,
    required this.selectedId,
    required this.onListen,
    required this.onLongPress,
  });

  final String title;
  final List<QuranArabicLetter> letters;
  final QuranLearnSnapshot? snap;
  final String progressKind;
  final String? selectedId;
  final ValueChanged<QuranArabicLetter> onListen;
  final ValueChanged<QuranArabicLetter> onLongPress;

  @override
  Widget build(BuildContext context) {
    if (letters.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3A332C),
          ),
        ),
        const SizedBox(height: 10),
        _FormsTable(
          letters: letters,
          snap: snap,
          progressKind: progressKind,
          selectedId: selectedId,
          onListen: onListen,
          onLongPress: onLongPress,
        ),
        const SizedBox(height: 12),
        _FormsSlider(
          letters: letters,
          selectedId: selectedId,
          onListen: onListen,
          onLongPress: onLongPress,
        ),
      ],
    );
  }
}

class _FormsTable extends StatelessWidget {
  const _FormsTable({
    required this.letters,
    required this.snap,
    required this.progressKind,
    required this.selectedId,
    required this.onListen,
    required this.onLongPress,
  });

  final List<QuranArabicLetter> letters;
  final QuranLearnSnapshot? snap;
  final String progressKind;
  final String? selectedId;
  final ValueChanged<QuranArabicLetter> onListen;
  final ValueChanged<QuranArabicLetter> onLongPress;

  static const _border = Color(0xFF5C5346);
  static const _header = Color(0xFFD9CDB3);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _border, width: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: _header,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Expanded(child: _FormsHead('Tek başına')),
                Expanded(child: _FormsHead('Sonda')),
                Expanded(child: _FormsHead('Ortada')),
                Expanded(child: _FormsHead('Başta')),
              ],
            ),
          ),
          for (final letter in letters)
            Material(
              color: snap?.isDone(progressKind, letter.id) == true
                  ? const Color(0xFFE8F3E4)
                  : selectedId == letter.id
                      ? const Color(0xFFE6DBC5)
                      : const Color(0xFFF8F3E6),
              child: InkWell(
                onTap: () => onListen(letter),
                onLongPress: () => onLongPress(letter),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _border, width: 0.6),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FormsGlyph(
                          letter.forms.isolated,
                          heavy: letter.isHeavySound,
                        ),
                      ),
                      Expanded(child: _FormsGlyph(letter.forms.finalForm)),
                      Expanded(child: _FormsGlyph(letter.forms.medial)),
                      Expanded(child: _FormsGlyph(letter.forms.initial)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormsHead extends StatelessWidget {
  const _FormsHead(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF3A332C),
      ),
    );
  }
}

class _FormsGlyph extends StatelessWidget {
  const _FormsGlyph(this.arabic, {this.heavy = false});

  final String arabic;
  final bool heavy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: QlBigArabic(
          arabic,
          fontSize: 26,
          color: heavy ? QlDashTile.heavyLetter : const Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _FormsSlider extends StatefulWidget {
  const _FormsSlider({
    required this.letters,
    required this.selectedId,
    required this.onListen,
    required this.onLongPress,
  });

  final List<QuranArabicLetter> letters;
  final String? selectedId;
  final ValueChanged<QuranArabicLetter> onListen;
  final ValueChanged<QuranArabicLetter> onLongPress;

  @override
  State<_FormsSlider> createState() => _FormsSliderState();
}

class _FormsSliderState extends State<_FormsSlider> {
  static const _tabs = ['Tek başına', 'Sonda', 'Ortada', 'Başta'];

  int _index = 0;
  int _slot = 0;

  @override
  void didUpdateWidget(_FormsSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = widget.selectedId;
    if (id == null || id == oldWidget.selectedId) return;
    final next = widget.letters.indexWhere((letter) => letter.id == id);
    if (next >= 0 && next != _index) {
      setState(() => _index = next);
    }
  }

  QuranArabicLetter get _letter => widget.letters[_index];

  String get _glyph {
    final forms = _letter.forms;
    return switch (_slot) {
      1 => forms.finalForm,
      2 => forms.medial,
      3 => forms.initial,
      _ => forms.isolated,
    };
  }

  void _go(int delta) {
    if (widget.letters.isEmpty) return;
    setState(() {
      _index = (_index + delta) % widget.letters.length;
      if (_index < 0) _index += widget.letters.length;
    });
    widget.onListen(_letter);
  }

  @override
  Widget build(BuildContext context) {
    final letter = _letter;
    final arabicColor =
        letter.isHeavySound ? QlDashTile.heavyLetter : const Color(0xFF1A1A1A);
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Önceki',
              onPressed: () => _go(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${_index + 1} / ${widget.letters.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A332C),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sonraki',
              onPressed: () => _go(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < _tabs.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: _slot == i
                        ? const Color(0xFFD9CDB3)
                        : const Color(0xFFF8F3E6),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        setState(() => _slot = i);
                        widget.onListen(letter);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _slot == i
                                ? const Color(0xFF3A332C)
                                : MinikColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: const Color(0xFFE6DBC5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => widget.onListen(letter),
            onLongPress: () => widget.onLongPress(letter),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5C5346), width: 0.9),
              ),
              child: Column(
                children: [
                  QlBigArabic(_glyph, fontSize: 64, color: arabicColor),
                  const SizedBox(height: 6),
                  Text(
                    letter.name,
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A332C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
