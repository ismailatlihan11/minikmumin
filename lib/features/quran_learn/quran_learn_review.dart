import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_theme.dart';
import 'quran_learn_widgets.dart';
import 'quran_learn_words.dart';

class QuranLearnReviewPage extends StatelessWidget {
  const QuranLearnReviewPage({
    super.key,
    required this.pack,
    this.levelId = 10,
  });

  final QuranLearningPack pack;
  final int levelId;

  static const progressKind = 'ql_letter_review';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEDC),
      appBar: AppBar(
        title: Text(
          pack.titleForLevel(levelId, fallback: 'Pekiştirme'),
        ),
      ),
      body: QlLetterReviewSection(pack: pack, levelId: levelId),
    );
  }
}

class QlLetterReviewSection extends StatefulWidget {
  const QlLetterReviewSection({
    super.key,
    required this.pack,
    this.levelId = 10,
    this.embedded = false,
  });

  final QuranLearningPack pack;
  final int levelId;
  final bool embedded;

  @override
  State<QlLetterReviewSection> createState() => _QlLetterReviewSectionState();
}

class _QlLetterReviewSectionState extends State<QlLetterReviewSection> {
  final _audio = AudioPlayerService();
  String? _selectedId;

  List<QuranWord> get _words => widget.pack.words;

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _listen(QuranWord word) async {
    setState(() => _selectedId = word.id);
    final store = context.read<LocalProgressStore>();
    await QuranLearnAudio.play(_audio, store, word.audio);
    if (!mounted) return;
    final snap = await QuranLearnProgress.load(store, widget.pack);
    if (snap.isDone(QuranLearnReviewPage.progressKind, word.id)) return;
    await QuranLearnProgress.complete(
      store,
      pack: widget.pack,
      kind: QuranLearnReviewPage.progressKind,
      id: word.id,
    );
    if (mounted) setState(() {});
  }

  void _openDetail(QuranWord word) {
    Navigator.push(
      context,
      quranLearnRoute(QuranLearnWordDetailPage(pack: widget.pack, word: word)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder<QuranLearnSnapshot>(
      future: QuranLearnProgress.load(store, widget.pack),
      builder: (context, snapshot) {
        final snap = snapshot.data;
        final done = snap?.completedCount(widget.levelId) ?? 0;
        final total = _words.length;
        final body = <Widget>[
          if (!widget.embedded) ...[
            QlSoftProgress(
              value: total == 0 ? 0 : done / total,
              label: '$done / $total kelime',
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'Pekiştirme',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: widget.embedded ? 16 : 22,
              fontWeight: widget.embedded ? FontWeight.w800 : FontWeight.w500,
              color: const Color(0xFF3A332C),
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
              'Öğrendiğin harfleri kelimede bul. Dokun, dinle.',
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
          if (widget.embedded && total > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$done / $total kelime',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C5346),
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final word in _words)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: snap?.isDone(
                          QuranLearnReviewPage.progressKind,
                          word.id,
                        ) ==
                        true
                    ? const Color(0xFFE8F3E4)
                    : _selectedId == word.id
                        ? const Color(0xFFD9CDB3)
                        : const Color(0xFFE6DBC5),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _listen(word),
                  onLongPress: () => _openDetail(word),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF5C5346),
                        width: 0.9,
                      ),
                    ),
                    child: QlBigArabic(
                      word.arabic,
                      fontSize: 36,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (_words.isNotEmpty)
            _ReviewSlider(
              words: _words,
              selectedId: _selectedId,
              onListen: _listen,
              onLongPress: _openDetail,
            ),
        ];
        if (widget.embedded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: body,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: body,
        );
      },
    );
  }
}

class _ReviewSlider extends StatefulWidget {
  const _ReviewSlider({
    required this.words,
    required this.selectedId,
    required this.onListen,
    required this.onLongPress,
  });

  final List<QuranWord> words;
  final String? selectedId;
  final ValueChanged<QuranWord> onListen;
  final ValueChanged<QuranWord> onLongPress;

  @override
  State<_ReviewSlider> createState() => _ReviewSliderState();
}

class _ReviewSliderState extends State<_ReviewSlider> {
  int _index = 0;

  QuranWord get _word => widget.words[_index];

  @override
  void didUpdateWidget(_ReviewSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = widget.selectedId;
    if (id == null || id == oldWidget.selectedId) return;
    final next = widget.words.indexWhere((word) => word.id == id);
    if (next >= 0 && next != _index) {
      setState(() => _index = next);
    }
  }

  void _go(int delta) {
    if (widget.words.isEmpty) return;
    setState(() {
      _index = (_index + delta) % widget.words.length;
      if (_index < 0) _index += widget.words.length;
    });
    widget.onListen(_word);
  }

  @override
  Widget build(BuildContext context) {
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
                '${_index + 1} / ${widget.words.length}',
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
        Material(
          color: const Color(0xFFE6DBC5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => widget.onListen(_word),
            onLongPress: () => widget.onLongPress(_word),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5C5346), width: 0.9),
              ),
              child: QlBigArabic(
                _word.arabic,
                fontSize: 48,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
