import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_practice.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_tajweed_marks.dart';
import 'quran_learn_widgets.dart';
import 'quran_learn_words.dart';

const _qlHarakaReviewKind = 'ql_haraka_review';
Color get _tan =>
    MinikColors.of(const Color(0xFFE6DBC5), const Color(0xFF40392C));
Color get _ink =>
    MinikColors.of(const Color(0xFF3A332C), const Color(0xFFD5CFC8));
Color get _line =>
    MinikColors.of(const Color(0xFF5C5346), const Color(0xFFCFC8BF));
const _markRed = Color(0xFFC62828);

class QlHarakatReviewSection extends StatefulWidget {
  const QlHarakatReviewSection({super.key, required this.pack});

  final QuranLearningPack pack;

  @override
  State<QlHarakatReviewSection> createState() => _QlHarakatReviewSectionState();
}

class _QlHarakatReviewSectionState extends State<QlHarakatReviewSection> {
  final _audio = AudioPlayerService();
  int _index = 0;
  Future<({List<QuranVerse> fatiha, List<QuranVerse> ihlas})>? _future;

  List<QuranWord> get _words => quranLearnHarakatReviewWords(widget.pack.words);

  QuranWord? get _word =>
      _words.isEmpty ? null : _words[_index.clamp(0, _words.length - 1)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<({List<QuranVerse> fatiha, List<QuranVerse> ihlas})> _load() async {
    final quran = context.read<ContentRepositories>().quran;
    return (
      fatiha: await quran.getSurah(1),
      ihlas: await quran.getSurah(112),
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _listen(QuranWord word) async {
    final next = _words.indexWhere((item) => item.id == word.id);
    if (next >= 0) setState(() => _index = next);
    final store = context.read<LocalProgressStore>();
    await QuranLearnAudio.play(_audio, store, word.audio);
    if (!mounted) return;
    final snap = await QuranLearnProgress.load(store, widget.pack);
    if (snap.isDone(_qlHarakaReviewKind, word.id)) return;
    await QuranLearnProgress.complete(
      store,
      pack: widget.pack,
      kind: _qlHarakaReviewKind,
      id: word.id,
    );
    if (mounted) setState(() {});
  }

  void _openDetail(QuranWord word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranLearnWordDetailPage(pack: widget.pack, word: word),
      ),
    );
  }

  void _go(int delta) {
    if (_words.isEmpty) return;
    var next = (_index + delta) % _words.length;
    if (next < 0) next += _words.length;
    _listen(_words[next]);
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    if (word == null) return const SizedBox.shrink();
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder(
      future: QuranLearnProgress.load(store, widget.pack),
      builder: (context, snapShot) {
        final snap = snapShot.data;
        final done = _words
            .where((item) => snap?.isDone(_qlHarakaReviewKind, item.id) == true)
            .length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pekiştirme',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final haraka in widget.pack.harakat)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: QlBigArabic(
                        haraka.symbol,
                        fontSize: 22,
                        color: _markRed,
                      ),
                    ),
                ],
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
                'Öğrendiğin harekeleri ayette dinle.',
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
            const SizedBox(height: 8),
            Text(
              '$done / ${_words.length} kelime',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _line,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<({List<QuranVerse> fatiha, List<QuranVerse> ihlas})>(
              future: _future,
              builder: (context, versesSnap) {
                final data = versesSnap.data;
                if (data == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final ref = quranLearnParseAyahRef(word.quranReference);
                final verses = ref?.$1 == 112 ? data.ihlas : data.fatiha;
                return _PassageCard(
                  verses: verses,
                  focusAyah: ref?.$2,
                  onTap: () => _listen(word),
                );
              },
            ),
            const SizedBox(height: 10),
            Material(
              color: _tan,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => _listen(word),
                onLongPress: () => _openDetail(word),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _line, width: 0.9),
                  ),
                  child: QlBigArabic(
                    word.arabic,
                    fontSize: 42,
                    color: MinikColors.of(
                        const Color(0xFF1A1A1A), const Color(0xFFD5D5D5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              quranLearnTajweedReference(word.quranReference),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _line,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Önceki',
                  onPressed: () => _go(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    '${_index + 1} / ${_words.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontWeight: FontWeight.w700,
                      color: _ink,
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
            QlPlayListen(audio: _audio, path: word.audio),
          ],
        );
      },
    );
  }
}

class _PassageCard extends StatelessWidget {
  const _PassageCard({
    required this.verses,
    required this.focusAyah,
    required this.onTap,
  });

  final List<QuranVerse> verses;
  final int? focusAyah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (verses.isEmpty) return const SizedBox.shrink();
    return Material(
      color: MinikColors.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line, width: 0.9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final verse in verses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: verse.ayahNo == focusAyah
                        ? const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          )
                        : EdgeInsets.zero,
                    decoration: verse.ayahNo == focusAyah
                        ? BoxDecoration(
                            color: _tan,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: QlBigArabic(
                      verse.arabic,
                      fontSize: verse.ayahNo == focusAyah ? 26 : 22,
                      color: MinikColors.of(
                          const Color(0xFF1A1A1A), const Color(0xFFD5D5D5)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
