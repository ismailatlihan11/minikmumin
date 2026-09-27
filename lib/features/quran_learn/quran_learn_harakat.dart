import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../shared/widgets/favorite_button.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_harakat_review.dart';
import 'quran_learn_practice.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_theme.dart';
import 'quran_learn_widgets.dart';

Color get _cream =>
    MinikColors.of(const Color(0xFFF5EEDC), const Color(0xFF373121));
Color get _tan =>
    MinikColors.of(const Color(0xFFE6DBC5), const Color(0xFF40392C));
Color get _ink =>
    MinikColors.of(const Color(0xFF3A332C), const Color(0xFFD5CFC8));
Color get _line =>
    MinikColors.of(const Color(0xFF5C5346), const Color(0xFFCFC8BF));

class QuranLearnHarakatPage extends StatelessWidget {
  const QuranLearnHarakatPage({
    super.key,
    required this.pack,
    this.levelId = 2,
  });

  final QuranLearningPack pack;
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final items = pack.harakatForLevel(levelId);
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: Text(pack.titleForLevel(levelId, fallback: 'Harekeler')),
      ),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              QlSoftProgress(
                value: items.isEmpty ? 0 : done / items.length,
                label: '$done / ${items.length} hareke',
              ),
              const SizedBox(height: 14),
              Text(
                'Harekeler',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: _tan,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC4B79A)),
                ),
                child: Text(
                  'Her hareke ayrı bir ders. Harfe dokun, dinle, bütün harflerle tekrarla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: snap?.isDone('ql_haraka', item.id) == true
                        ? MinikColors.of(
                            const Color(0xFFE8F3E4), const Color(0xFF273223))
                        : MinikColors.card,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        quranLearnRoute(QuranLearnHarakaDetailPage(
                          pack: pack,
                          haraka: item,
                          levelId: levelId,
                        )),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _line, width: 0.9),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: MinikColors.pastelAt(item.order),
                              child: Text(
                                '${item.order}',
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.w800,
                                  color: MinikColors.darkGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    quranLearnHarakatTeachLine(item),
                                    style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 13,
                                      height: 1.3,
                                      color: MinikColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            QlBigArabic(
                              item.symbol,
                              fontSize: 28,
                              color: _ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              QlHarakatReviewSection(pack: pack),
            ],
          );
        },
      ),
    );
  }
}

class QuranLearnHarakaDetailPage extends StatefulWidget {
  const QuranLearnHarakaDetailPage({
    super.key,
    required this.pack,
    required this.haraka,
    this.levelId,
  });

  final QuranLearningPack pack;
  final QuranHaraka haraka;
  final int? levelId;

  @override
  State<QuranLearnHarakaDetailPage> createState() =>
      _QuranLearnHarakaDetailPageState();
}

class _QuranLearnHarakaDetailPageState
    extends State<QuranLearnHarakaDetailPage> {
  final _audio = AudioPlayerService();

  QuranHaraka get haraka => widget.haraka;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _play(String? path) {
    return QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      path,
    );
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: 'ql_haraka',
      id: haraka.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: '${haraka.name} dersini tamamladın.',
      onContinue: () {
        final items = widget.levelId == null
            ? widget.pack.harakat
            : widget.pack.harakatForLevel(widget.levelId!);
        final index = items.indexWhere((item) => item.id == haraka.id);
        if (index >= 0 && index + 1 < items.length) {
          Navigator.pushReplacement(
            context,
            quranLearnRoute(QuranLearnHarakaDetailPage(
              pack: widget.pack,
              haraka: items[index + 1],
              levelId: widget.levelId,
            )),
          );
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachGlyph = quranLearnTeachingGlyph(haraka.id);
    final teachAudio = quranLearnTeachingAudio(widget.pack.letters, haraka.id);
    final teachLine = quranLearnHarakatTeachLine(haraka);
    final listenPath = teachAudio ?? haraka.audio;
    final compare = quranLearnHasComparison(haraka.id);
    final examples = (haraka.id == 'sukun' || haraka.id == 'shadda')
        ? const <QuranHarakaExample>[]
        : haraka.examples;
    final uygulamaWords = haraka.id == 'sukun'
        ? quranLearnWordsWithMark(widget.pack.words, 'ْ')
        : haraka.id == 'shadda'
            ? quranLearnWordsWithMark(widget.pack.words, 'ّ')
            : const <QuranWord>[];
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: Text(haraka.name),
        actions: [
          FavoriteButton(
            kind: 'ql_haraka',
            id: haraka.id,
            title: haraka.name,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Ders ${haraka.order}: ${haraka.name}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: _tan,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC4B79A)),
            ),
            child: Text(
              teachLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: _tan,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: QuranLearnAudio.resolve(listenPath) == null
                  ? null
                  : () => _play(listenPath),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _line, width: 0.9),
                ),
                child: Column(
                  children: [
                    QlBigArabic(
                      teachGlyph.isEmpty ? haraka.symbol : teachGlyph,
                      fontSize: 64,
                      color: _ink,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      haraka.name,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    if (haraka.id == 'shadda') ...[
                      const SizedBox(height: 6),
                      Text(
                        quranLearnShaddaEquation('ب'),
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    QlPlayListen(audio: _audio, path: listenPath),
                  ],
                ),
              ),
            ),
          ),
          if (haraka.id == 'sukun') ...[
            const SizedBox(height: 18),
            const _SectionTitle('Kavrama'),
            const SizedBox(height: 8),
            QlCezmKavrama(audio: _audio, letters: widget.pack.letters),
          ] else if (haraka.id == 'shadda') ...[
            const SizedBox(height: 18),
            const _SectionTitle('Kavrama'),
            const SizedBox(height: 8),
            QlShaddaKavrama(audio: _audio, letters: widget.pack.letters),
          ],
          const SizedBox(height: 18),
          const _SectionTitle('Bütün harfler'),
          const SizedBox(height: 8),
          Text(
            haraka.id == 'sukun'
                ? 'Her karede üç hareke vardır. Dokun, dinle.'
                : haraka.id == 'shadda'
                    ? 'Üstün şedde. Kırmızı olanlar kalın harflerdir. Dokun, dinle.'
                    : 'Kırmızı olanlar kalın harflerdir. Dokun, dinle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (haraka.id == 'sukun')
            QlSukunTripletGrid(audio: _audio, letters: widget.pack.letters)
          else
            QlPracticeGrid(
              audio: _audio,
              items: quranLearnPracticeItems(
                letters: widget.pack.letters,
                harakaId: haraka.id,
              ),
              columns: 4,
              fontSize: 26,
              aspect: 0.92,
            ),
          if (compare) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Karşılaştırma'),
            const SizedBox(height: 8),
            QlPracticeTable(
              audio: _audio,
              items: quranLearnPracticeItems(
                letters: widget.pack.letters,
                harakaId: haraka.id,
              ),
              compare: true,
            ),
          ],
          if (examples.isNotEmpty || uygulamaWords.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Uygulama'),
            const SizedBox(height: 8),
            if (uygulamaWords.isNotEmpty)
              QlWordListenList(audio: _audio, words: uygulamaWords),
            for (final example in examples)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: _tan,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: QuranLearnAudio.resolve(example.audio) == null
                        ? null
                        : () => _play(example.audio),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _line, width: 0.9),
                      ),
                      child: Column(
                        children: [
                          QlBigArabic(
                            example.arabic,
                            fontSize: 36,
                            color: _ink,
                          ),
                          if (example.reading.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              example.reading,
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: MinikColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: _ink,
      ),
    );
  }
}
