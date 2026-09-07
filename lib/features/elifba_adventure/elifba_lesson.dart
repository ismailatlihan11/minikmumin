import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../shared/widgets/buttons.dart';
import 'elifba_audio.dart';
import 'elifba_cards.dart';
import 'elifba_content.dart';
import 'elifba_games.dart';
import 'elifba_models.dart';
import 'elifba_progress.dart';
import 'elifba_reading.dart';
import 'elifba_widgets.dart';
import 'elifba_worlds.dart';

class ElifbaLessonFlowPage extends StatefulWidget {
  const ElifbaLessonFlowPage({
    super.key,
    required this.pack,
    required this.lesson,
    required this.replay,
  });

  final ElifbaPack pack;
  final ElifbaLesson lesson;
  final bool replay;

  @override
  State<ElifbaLessonFlowPage> createState() => _ElifbaLessonFlowPageState();
}

class _ElifbaLessonFlowPageState extends State<ElifbaLessonFlowPage> {
  final _audio = AudioPlayerService();
  var _step = 0;
  var _stars = 0;
  var _quizCorrect = 0;
  String _mascot = '';
  ElifbaGroup? _mahraj;
  ElifbaCategory? _category;

  ElifbaLesson get lesson => widget.lesson;

  List<_FlowStep> get _steps => _buildSteps(lesson);

  @override
  void initState() {
    super.initState();
    _mascot = lesson.characterMessage.isNotEmpty
        ? lesson.characterMessage.replaceAll('“', '').replaceAll('”', '')
        : ElifbaVoice.introFor(lesson);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.replay) return;
      await ElifbaProgress(context.read<LocalProgressStore>())
          .markStarted(lesson.id);
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_step >= _steps.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _step += 1;
      _mascot = _steps[_step].cue;
    });
  }

  void _answered({required bool correct}) {
    _scored(correct: correct);
    if (correct) {
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _next();
      });
    }
  }

  /// Çok turlu oyunlarda puanı işler ama adımı otomatik ilerletmez.
  void _scored({required bool correct}) {
    setState(() {
      _mascot = correct
          ? ElifbaVoice.pick(ElifbaVoice.correct, _step)
          : ElifbaVoice.pick(ElifbaVoice.retry, _step);
      if (correct) _stars = (_stars + 1).clamp(0, 99);
    });
  }

  Future<void> _finish() async {
    final progress = ElifbaProgress(context.read<LocalProgressStore>());
    final earned = (_stars >= 3 ? 3 : (_stars == 0 ? 1 : _stars)).clamp(1, 3);
    if (!widget.replay) {
      await progress.completeLesson(
        lessonId: lesson.id,
        starsEarned: earned,
        quizCorrect: _quizCorrect,
        badge: ElifbaWorlds.badgeForLesson(widget.pack, lesson.id),
        nextLessonId: widget.pack.nextOf(lesson.id)?.id,
        lessonLabel: 'Ders ${widget.pack.orderOf(lesson.id)}',
      );
    }
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ElifbaCompletePage(
          pack: widget.pack,
          lesson: lesson,
          stars: earned,
          quizCorrect: _quizCorrect,
          quizTotal: lesson.quiz.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final current = steps[_step.clamp(0, steps.length - 1)];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      appBar: AppBar(
        title: Text('Ders ${widget.pack.orderOf(lesson.id)}'),
        actions: [
          if (kDebugMode)
            TextButton(
              onPressed: _finish,
              child: const Text('Bitir'),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            LinearProgressIndicator(
              value: steps.isEmpty ? 0 : (_step + 1) / steps.length,
              minHeight: 8,
              color: MinikColors.green,
              backgroundColor: MinikColors.creamDark,
            ),
            const SizedBox(height: 12),
            ElifbaMascot(line: _mascot.isEmpty ? current.cue : _mascot),
            const SizedBox(height: AppSpacing.md),
            current.builder(this),
            const SizedBox(height: AppSpacing.lg),
            if (current.showContinue)
              PrimaryButton(label: 'Devam', onPressed: _next),
          ],
        ),
      ),
    );
  }

  List<_FlowStep> _buildSteps(ElifbaLesson lesson) {
    final steps = <_FlowStep>[
      _FlowStep(
        cue: 'Bugün ${lesson.title} öğreneceğiz.',
        builder: (state) => ElifbaSoftCard(
          color: MinikColors.mint,
          child: Column(
            children: [
              const Text('Bugünün Görevi'),
              const SizedBox(height: 8),
              Text(
                lesson.goal,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (lesson.explanation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(lesson.explanation, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    ];

    if (lesson.rich.objective.isNotEmpty &&
        lesson.rich.objective != lesson.goal) {
      steps.add(
        _FlowStep(
          cue: 'Bu derste ne öğreneceğiz?',
          builder: (state) => ElifbaLessonHeader(
            title: lesson.title,
            subtitle: lesson.rich.objective,
          ),
        ),
      );
    }

    if (lesson.letterForms.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Harfe dokun, adını dinle. Dört şekline birlikte bakalım.',
          builder: (state) => ElifbaFormBoard(
            rows: lesson.letterForms,
            audio: state._audio,
          ),
        ),
      );
      steps.add(
        _FlowStep(
          cue: 'Şimdi şekli gören gözlerimizi deneyelim.',
          showContinue: false,
          builder: (state) => ElifbaFormHunt(
            rows: lesson.letterForms,
            onAnswer: state._scored,
            onFinished: state._next,
          ),
        ),
      );
    }

    if (lesson.ruleText.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bugünün kuralı bu.',
          builder: (state) => ElifbaSoftCard(
            color: MinikColors.lavender,
            child: Text(lesson.ruleText, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (lesson.categoryTables.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'İnce, kalın ve peltek harfleri birlikte hatırlayalım.',
          builder: (state) => ElifbaCategoryTablesView(
            tables: lesson.categoryTables,
            audio: state._audio,
            note: lesson.classificationNote,
          ),
        ),
      );
    } else if (lesson.categories.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bir gruba dokun, harflerini gör.',
          builder: (state) => ElifbaCategoryBoard(
            categories: lesson.categories,
            tables: lesson.categoryTables,
            selected: state._category ?? lesson.categories.first,
            onPick: (cat) => setState(() => _category = cat),
            audio: state._audio,
          ),
        ),
      );
    }

    final sortPool = _sortPool(lesson);
    if (sortPool.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Harfi doğru kutuya bırak: ince mi, kalın mı, peltek mi?',
          showContinue: false,
          builder: (state) => ElifbaSortMission(
            letters: sortPool,
            onAnswer: state._scored,
            onFinished: state._next,
          ),
        ),
      );
    }

    if (lesson.specialLetters.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bu harfin özel bir hikâyesi var.',
          builder: (state) => Column(
            children: [
              if (lesson.importantNote.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElifbaSoftCard(
                    color: MinikColors.butter,
                    child: Text(lesson.importantNote, textAlign: TextAlign.center),
                  ),
                ),
              for (final item in lesson.specialLetters)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElifbaSpecialLetterCard(
                    item: item,
                    audio: state._audio,
                  ),
                ),
              for (final preview in lesson.specialPreview)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElifbaSoftCard(
                    child: Column(
                      children: [
                        ElifbaArabicTap(text: preview.text, fontSize: 44),
                        Text(preview.reading),
                        if (preview.note.isNotEmpty)
                          Text(preview.note, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    for (final pair in lesson.askPairs) {
      steps.add(
        _FlowStep(
          cue: 'Bakalım doğru olanı bulabilecek misin?',
          showContinue: false,
          builder: (state) => ElifbaAskPairGame(
            pair: pair,
            onAnswer: state._answered,
          ),
        ),
      );
    }

    if (lesson.comparePairs.isNotEmpty) {
      for (final pair in lesson.comparePairs) {
        steps.add(
          _FlowStep(
            cue: 'Hangisi farklı? Dokun ve seç.',
            showContinue: false,
            builder: (state) => ElifbaCompareGame(
              pair: pair,
              onAnswer: state._answered,
            ),
          ),
        );
      }
    }

    final letters = lesson.letters;
    if (letters.isNotEmpty && letters.first.name.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Harflere dokun, adını dinle.',
          builder: (state) => ElifbaLetterGrid(
            letters: letters,
            audio: state._audio,
          ),
        ),
      );
      steps.add(
        _FlowStep(
          cue: 'Harfin adı ile sesini karıştırma.',
          builder: (state) => ElifbaNameSoundCard(
            letter: letters[1 < letters.length ? 1 : 0],
            audio: state._audio,
          ),
        ),
      );
      final huntPool = letters.take(5).toList();
      if (lesson.comparePairs.isEmpty) {
        steps.add(
          _FlowStep(
            cue: 'Harf avı zamanı!',
            showContinue: false,
            builder: (state) => ElifbaLetterHunt(
              letters: huntPool,
              target: huntPool[1 < huntPool.length ? 1 : 0],
              onAnswer: state._answered,
            ),
          ),
        );
      }
    } else if (lesson.letterGlyphs.isNotEmpty) {
      final bounce = lesson.title.toLowerCase().contains('kalkale') ||
          lesson.memoryPhrase.contains('قطب');
      steps.add(
        _FlowStep(
          cue: bounce
              ? 'Bunlar sükûnlu olduğunda seslerinde küçük bir yankı duyulur.'
              : 'Bu harflere dokun, adını hatırla.',
          builder: (state) => Column(
            children: [
              if (lesson.memoryPhrase.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElifbaArabicTap(
                    text: lesson.memoryPhrase,
                    fontSize: 28,
                  ),
                ),
              if (bounce)
                ElifbaKalkalaRow(letters: lesson.letterGlyphs)
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final glyph in lesson.letterGlyphs)
                      ElifbaArabicTap(
                        text: glyph,
                        fontSize: 48,
                        onTap: () => ElifbaAudio.play(
                          state._audio,
                          ElifbaAudio.letterGlyph(glyph),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    final focus = lesson.focusLetter;
    if (focus != null) {
      steps.add(
        _FlowStep(
          cue: 'Aynı harf kelimenin yerinde şekil değiştirebilir.',
          builder: (state) => ElifbaFormsCard(focus: focus),
        ),
      );
    }

    final rule = lesson.rule;
    if (rule != null) {
      steps.add(
        _FlowStep(
          cue: rule.name.isEmpty
              ? 'Bu işareti birlikte inceleyelim.'
              : 'Bak bakalım! Bu işaretin adı ${rule.name}.',
          builder: (state) => ElifbaSoftCard(
            child: Column(
              children: [
                if (rule.symbol.isNotEmpty)
                  ElifbaArabicTap(text: rule.symbol, fontSize: 72),
                Text(
                  rule.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (rule.sound.isNotEmpty) Text('Ses: ${rule.sound}'),
                if (rule.concept.isNotEmpty) Text(rule.concept),
                if (rule.transformation.isNotEmpty) Text(rule.transformation),
                if (rule.note.isNotEmpty) Text(rule.note),
                if (rule.letter.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('İlgili harf'),
                  ElifbaArabicTap(text: rule.letter, fontSize: 72),
                ],
              ],
            ),
          ),
        ),
      );
      if (rule.symbol.isNotEmpty && 'َُِ'.contains(rule.symbol)) {
        // Oyun tek harf üzerinden gider; hedef okunuş o harfin ince/kalın
        // durumuna göre üretilir (بَ → be).
        const dragLetter = 'ب';
        final target = ElifbaReading.of(dragLetter, rule.symbol, withTag: false);
        steps.add(
          _FlowStep(
            cue: '$target sesi için harekeyi sürükle.',
            showContinue: false,
            builder: (state) => ElifbaHarakaDrag(
              letter: dragLetter,
              targetMark: rule.symbol,
              targetReading: target.isEmpty ? rule.name : target,
              onAnswer: state._answered,
            ),
          ),
        );
      }
    }

    final triple = lesson.tripleFormTable;
    if (triple.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Önce harfin adını söyle, sonra fetha–esre–ötre hâllerini oku.',
          builder: (state) => ElifbaTripleFormTable(
            rows: triple,
            audio: state._audio,
            title: lesson.tableTitle.isEmpty
                ? 'Harfler, İsimleri ve Okunuşları'
                : lesson.tableTitle,
            note: lesson.tableInstruction.isEmpty
                ? 'Örnek: ب = Be, بَ = ba'
                : lesson.tableInstruction,
          ),
        ),
      );
    }

    final shaddaTables = lesson.harakeTables;
    if (shaddaTables.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Şedde tek başına okunmaz; hep bir hareke ile birlikte gelir.',
          builder: (state) => ElifbaShaddaSections(
            tables: shaddaTables,
            audio: state._audio,
            note: lesson.importantNote,
          ),
        ),
      );
      if (lesson.practiceRule.isNotEmpty) {
        steps.add(
          _FlowStep(
            cue: 'Şeddeli kelimeyi okurken sırayla ilerle.',
            builder: (state) => ElifbaSoftCard(
              color: MinikColors.mint,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lesson.practiceRule.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('${i + 1}. ${lesson.practiceRule[i]}'),
                    ),
                ],
              ),
            ),
          ),
        );
      }
      if (lesson.coreExamples.isNotEmpty) {
        steps.add(
          _FlowStep(
            cue: 'Şeddeli heceleri birlikte okuyalım.',
            builder: (state) => Column(
              children: [
                for (final example in lesson.coreExamples)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElifbaExampleCard(
                      example: example,
                      audio: state._audio,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }

    if (lesson.raTable.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Ra her zaman kalın değildir. Bak, hareke belirliyor.',
          builder: (state) => ElifbaRaTableView(
            rows: lesson.raTable,
            audio: state._audio,
          ),
        ),
      );
    }

    final table = widget.pack.teachingTableFor(lesson);
    if (table.isNotEmpty) {
      final mark = table.first.marked;
      final extraNote = mark.contains('ْ')
          ? 'Cezmli harf genellikle kendinden önceki harfle birleşerek okunur.'
          : mark.contains('ّ')
              ? 'Şedde, harfin iki harf değerinde/kuvvetli okunmasını gösterir.'
              : '';
      steps.add(
        _FlowStep(
          cue: table.first.marked.isEmpty
              ? 'Bu kuralın harflerine dokun.'
              : 'Harfin adı ile okunuşunu karıştırma. Önce adı, sonra sesi.',
          builder: (state) => Column(
            children: [
              if (extraNote.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElifbaSoftCard(
                    color: MinikColors.butter,
                    child: Text(extraNote, textAlign: TextAlign.center),
                  ),
                ),
              ElifbaLetterTable(
                rows: table,
                audio: state._audio,
                title: widget.pack.teachingTitleFor(lesson).isEmpty
                    ? (table.first.category.isEmpty
                        ? 'Bütün ilgili harfler'
                        : table.first.category)
                    : widget.pack.teachingTitleFor(lesson),
                instruction: widget.pack.teachingInstructionFor(lesson),
                allowFavorite: lesson.uiPattern.allowFavorite,
              ),
            ],
          ),
        ),
      );
    }

    final words = lesson.wordExamples;
    if (words.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Şimdi kelime okuma zamanı! Önce dinle, sonra sen oku.',
          builder: (state) => ElifbaWordSection(
            words: words,
            audio: state._audio,
            title: lesson.wordSectionTitle,
            instruction: lesson.wordSectionInstruction.isEmpty
                ? lesson.manyExampleRule
                : lesson.wordSectionInstruction,
          ),
        ),
      );
    }

    if (shaddaTables.isNotEmpty) {
      final shaddaWord = words.where((w) => w.text.contains('ّ')).toList();
      if (shaddaWord.isNotEmpty) {
        steps.add(
          _FlowStep(
            cue: 'Şedde oyunu! Şeddeli harfi bulalım.',
            builder: (state) => ElifbaShaddaHunt(
              word: shaddaWord.first,
              onAnswer: state._scored,
            ),
          ),
        );
      }
    }

    if (lesson.comparison.isNotEmpty) {
      final item = lesson.comparison.last;
      steps.add(
        _FlowStep(
          cue: 'Kısa sesleri yan yana görelim.',
          builder: (state) => Column(
            children: [
              for (var i = 0; i + 1 < lesson.comparison.length; i += 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElifbaComparisonCard(
                    left: lesson.comparison[i].text,
                    right: lesson.comparison[i + 1].text,
                    leftCaption: lesson.comparison[i].reading,
                    rightCaption: lesson.comparison[i + 1].reading,
                  ),
                ),
            ],
          ),
        ),
      );
      steps.add(
        _FlowStep(
          cue: 'Bu işaret hangi sesi çıkarıyor?',
          showContinue: false,
          builder: (state) => ElifbaChoiceRow(
            prompt: item.text,
            options: [for (final ex in lesson.comparison) ex.reading],
            answer: item.reading,
            onAnswer: state._answered,
          ),
        ),
      );
    }

    if (lesson.examples.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Örneklere dokun, dinle, tekrarla.',
          builder: (state) => Column(
            children: [
              for (final example in lesson.examples)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElifbaExampleCard(
                    example: example,
                    audio: state._audio,
                  ),
                ),
            ],
          ),
        ),
      );
      final wordLike = lesson.examples.where((e) => e.focus.isNotEmpty).toList();
      if (wordLike.isNotEmpty &&
          (lesson.title.toLowerCase().contains('kelime') ||
              lesson.examples.any((e) => e.reading.isNotEmpty && e.focus.isNotEmpty))) {
        steps.add(
          _FlowStep(
            cue: 'Kelimenin içinde hangi kural var?',
            showContinue: false,
            builder: (state) => ElifbaPracticeCard(
              example: wordLike.first,
              audio: state._audio,
              onAnswer: state._answered,
            ),
          ),
        );
      }
    }

    if (lesson.practice.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Şimdi sen dene.',
          builder: (state) => ElifbaExampleList(
            examples: lesson.practice,
            audio: state._audio,
          ),
        ),
      );
    }

    if (lesson.blending.isNotEmpty) {
      final blend = lesson.blending.first;
      final parts = blend.text.split('+');
      steps.add(
        _FlowStep(
          cue: 'Kartları birleştir, sesleri birleştir.',
          builder: (state) => ElifbaBlendGame(
            parts: parts,
            result: blend.text.replaceAll(' ', '').replaceAll('+', ''),
            onDone: state._next,
          ),
          showContinue: false,
        ),
      );
    }

    if (lesson.types.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Kartlara dokun, tenvin sesini duy.',
          builder: (state) => ElifbaTenvinCards(
            types: lesson.types,
            audio: state._audio,
          ),
        ),
      );
    }

    if (lesson.medLetters.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Kısa ses uzayınca med olur. Bak, ses dalgası uzuyor.',
          builder: (state) => ElifbaMedCompare(
            items: lesson.medLetters,
            audio: state._audio,
          ),
        ),
      );
    }

    final medRows = widget.pack.medTableFor(lesson);
    if (medRows.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Elif, vav ve ya ile uzun ses.',
          builder: (state) => ElifbaMedTableView(
            rows: medRows,
            audio: state._audio,
          ),
        ),
      );
    }

    // Şedde için ayrı oyun var; burada yalnızca cezm aranır.
    final mark = lesson.rule?.symbol ?? '';
    if (mark == 'ْ' && lesson.examples.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Cezm nerede?',
          showContinue: false,
          builder: (state) => ElifbaFindMark(
            word: lesson.examples.first.text,
            mark: mark,
            onAnswer: state._answered,
          ),
        ),
      );
    }

    if (lesson.stepExample != null) {
      steps.add(
        _FlowStep(
          cue: 'Şşş! Bu harf biraz daha güçlü okunuyor.',
          builder: (state) => ElifbaSoftCard(
            child: Column(
              children: [
                ElifbaArabicTap(text: lesson.stepExample!.text, fontSize: 56),
                Text(lesson.stepExample!.explanation),
              ],
            ),
          ),
        ),
      );
    }

    if (lesson.examples.any((e) => e.rule.isNotEmpty)) {
      final sample = lesson.examples.firstWhere((e) => e.rule.isNotEmpty);
      const options = ['İzhâr', 'İdğam', 'İklâb', 'İhfâ'];
      final mapped = options.firstWhere(
        (item) =>
            sample.rule.toLowerCase().contains(item.toLowerCase()) ||
            item.toLowerCase().contains(sample.rule.toLowerCase()),
        orElse: () => sample.rule,
      );
      steps.add(
        _FlowStep(
          cue: 'Burada hangi kural gizlenmiş?',
          showContinue: false,
          builder: (state) => ElifbaTajweedGuess(
            example: sample,
            options: options,
            answer: mapped,
            onAnswer: state._answered,
          ),
        ),
      );
    }

    for (final block in [
      ...lesson.rulesSummary,
      ...lesson.rules,
      ...lesson.basicRules,
      ...lesson.concepts,
      ...lesson.signs,
    ]) {
      if (block.title.isEmpty) continue;
      steps.add(
        _FlowStep(
          cue: block.title,
          builder: (state) => ElifbaRuleCard(
            title: block.title,
            detail: block.detail,
            extra: block.extra,
          ),
        ),
      );
    }

    if (lesson.basicRules.isNotEmpty &&
        lesson.title.toLowerCase().contains('ra')) {
      steps.add(
        _FlowStep(
          cue: 'Ra bazen kalın, bazen ince okunur.',
          builder: (state) => const ElifbaSoftCard(
            color: MinikColors.butter,
            child: Text(
              "Ra'nın bütün durumları bu üç örnekten ibaret değildir.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (lesson.title.toLowerCase().contains('lafzatullah') ||
        lesson.title.contains('الل')) {
      steps.add(
        _FlowStep(
          cue: 'Allah lafzını büyük görelim.',
          builder: (state) => const ElifbaSoftCard(
            color: MinikColors.mint,
            child: Column(
              children: [
                ElifbaArabicTap(text: 'اللّٰه', fontSize: 64),
                Text('Lafzatullah'),
              ],
            ),
          ),
        ),
      );
    }

    final decisionTree = widget.pack.decisionTreeFor(lesson);
    if (decisionTree.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Sırayla soralım, kuralı bulalım.',
          builder: (state) => ElifbaSoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in decisionTree)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $item'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (lesson.groups.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bölgeye dokun, harfleri gör.',
          builder: (state) => Column(
            children: [
              ElifbaMahrajBoard(
                groups: lesson.groups,
                onPick: (group) => setState(() => _mahraj = group),
              ),
              if (_mahraj != null) ...[
                const SizedBox(height: 12),
                Text(_mahraj!.name),
                ElifbaKalkalaRow(letters: _mahraj!.letters),
              ],
            ],
          ),
        ),
      );
    }

    if (lesson.pairs.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Benzer harfleri ayıralım.',
          builder: (state) => Column(
            children: [
              for (final pair in lesson.pairs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElifbaSoftCard(
                    child: Column(
                      children: [
                        ElifbaArabicTap(text: pair.group, fontSize: 32),
                        Text(pair.details, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (lesson.verses.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Kelimeye dokun, işareti gör.',
          builder: (state) => ElifbaVerseStudy(verses: lesson.verses),
        ),
      );
    }

    if (lesson.surahs.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Dinle, incele, oku, tekrar et.',
          builder: (state) => ElifbaSurahPractice(
            surahs: lesson.surahs,
            flow: lesson.practiceFlow,
          ),
        ),
      );
    }

    if (lesson.interactiveActivities.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bunları da birlikte yapalım.',
          builder: (state) => ElifbaActivityList(
            activities: lesson.interactiveActivities,
          ),
        ),
      );
    }

    if (lesson.activities.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Küçük görevler.',
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final activity in lesson.activities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $activity'),
                ),
            ],
          ),
        ),
      );
    }

    if (lesson.noteForApp.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Birlikte dikkatli olalım.',
          builder: (state) => ElifbaSoftCard(
            color: MinikColors.butter,
            child: Text(lesson.noteForApp, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (lesson.summaryPoints.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Bugünü birlikte hatırlayalım.',
          builder: (state) => ElifbaLessonSummary(points: lesson.summaryPoints),
        ),
      );
    }

    if (lesson.isFinal && lesson.quiz.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Son görevimize geldik!',
          showContinue: false,
          builder: (state) => ElifbaFinalRooms(
            items: lesson.quiz,
            passPercent: lesson.completion?.passPercent ?? 70,
            onFinished: (correct) {
              state._quizCorrect = correct;
              state._next();
            },
          ),
        ),
      );
    } else if (lesson.quiz.isNotEmpty) {
      steps.add(
        _FlowStep(
          cue: 'Mini quiz zamanı.',
          showContinue: false,
          builder: (state) => ElifbaQuizPage(
            items: lesson.quiz,
            onFinished: (correct) {
              state._quizCorrect = correct;
              state._stars += correct;
              state._next();
            },
          ),
        ),
      );
    }

    return steps;
  }

  /// Sürükle-bırak görevinin harfleri JSON gruplarından toplanır.
  List<String> _sortPool(ElifbaLesson lesson) {
    final groups = lesson.reviewGroups;
    if (groups.isEmpty) return const [];
    final pool = <String>[];
    for (final group in groups) {
      for (final letter in group.letters) {
        if (!pool.contains(letter)) pool.add(letter);
      }
    }
    final thin = lesson.categoryTables['ince_harfler'] ?? const [];
    for (final row in thin.take(2)) {
      if (!pool.contains(row.letter)) pool.add(row.letter);
    }
    return pool.take(6).toList(growable: false);
  }
}

class _FlowStep {
  const _FlowStep({
    required this.cue,
    required this.builder,
    this.showContinue = true,
  });

  final String cue;
  final Widget Function(_ElifbaLessonFlowPageState state) builder;
  final bool showContinue;
}

class ElifbaIntroPage extends StatelessWidget {
  const ElifbaIntroPage({
    super.key,
    required this.pack,
    required this.lesson,
    required this.replay,
  });

  final ElifbaPack pack;
  final ElifbaLesson lesson;
  final bool replay;

  void _open(BuildContext context) {
    ElifbaProgress(context.read<LocalProgressStore>()).markStarted(lesson.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ElifbaLessonFlowPage(
          pack: pack,
          lesson: lesson,
          replay: replay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElifbaWorlds.forLesson(pack, lesson.id).color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => _open(context),
            child: const Text('Atla'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            children: [
              const Spacer(),
              const Text('⭐', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              ElifbaMascot(line: ElifbaVoice.introFor(lesson), size: 96),
              const SizedBox(height: 24),
              Text(
                'Ders ${pack.orderOf(lesson.id)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                lesson.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Keşfet',
                onPressed: () => _open(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElifbaCompletePage extends StatelessWidget {
  const ElifbaCompletePage({
    super.key,
    required this.pack,
    required this.lesson,
    required this.stars,
    required this.quizCorrect,
    required this.quizTotal,
  });

  final ElifbaPack pack;
  final ElifbaLesson lesson;
  final int stars;
  final int quizCorrect;
  final int quizTotal;

  @override
  Widget build(BuildContext context) {
    final next = pack.nextOf(lesson.id);
    final world = ElifbaWorlds.forLesson(pack, lesson.id);
    final badge = ElifbaWorlds.badgeForLesson(pack, lesson.id);
    final worldDone = world.lastId == lesson.id;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            children: [
              const Spacer(),
              ElifbaRewardCard(
                stars: stars,
                quizCorrect: quizCorrect,
                quizTotal: quizTotal,
              ),
              Text(
                'Ders ${pack.orderOf(lesson.id)} · ${lesson.title}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (badge.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('🏅 $badge'),
              ],
              if (worldDone) ...[
                const SizedBox(height: 12),
                Text(
                  '${world.emoji} ${world.title} tamamlandı!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
              const SizedBox(height: 16),
              const ElifbaMascot(line: 'Bir sonraki maceraya hazır mısın?'),
              const Spacer(),
              if (next != null)
                PrimaryButton(
                  label: 'Sonraki Ders',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ElifbaIntroPage(
                          pack: pack,
                          lesson: next,
                          replay: false,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'Dersi Tekrar Et',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ElifbaIntroPage(
                        pack: pack,
                        lesson: lesson,
                        replay: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('${world.emoji} Haritaya dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElifbaFinalRooms extends StatefulWidget {
  const ElifbaFinalRooms({
    super.key,
    required this.items,
    required this.passPercent,
    required this.onFinished,
  });

  final List<ElifbaQuizItem> items;
  final int passPercent;
  final void Function(int correct) onFinished;

  @override
  State<ElifbaFinalRooms> createState() => _ElifbaFinalRoomsState();
}

class _ElifbaFinalRoomsState extends State<ElifbaFinalRooms> {
  static const _rooms = ['Harf Odası', 'Hareke Odası', 'Okuma Odası', 'Tecvid Odası'];
  var _room = 0;
  var _correct = 0;

  List<List<ElifbaQuizItem>> get _chunks {
    if (widget.items.isEmpty) return const [];
    final size = (widget.items.length / _rooms.length).ceil();
    return [
      for (var i = 0; i < _rooms.length; i++)
        widget.items.skip(i * size).take(size).toList(),
    ].where((chunk) => chunk.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chunks = _chunks;
    if (chunks.isEmpty) {
      return PrimaryButton(
        label: 'Kale kapısını aç',
        onPressed: () => widget.onFinished(0),
      );
    }
    final roomItems = chunks[_room.clamp(0, chunks.length - 1)];
    return Column(
      children: [
        Text('🏰 ${_rooms[_room.clamp(0, _rooms.length - 1)]}'),
        const SizedBox(height: 12),
        ElifbaQuizPage(
          key: ValueKey(_room),
          items: roomItems,
          onFinished: (correct) {
            _correct += correct;
            if (_room >= chunks.length - 1) {
              widget.onFinished(_correct);
            } else {
              setState(() => _room += 1);
            }
          },
        ),
      ],
    );
  }
}
