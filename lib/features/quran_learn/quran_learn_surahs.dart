import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_follow.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_tajweed_marks.dart';
import 'quran_learn_widgets.dart';

enum QuranLearnReadMode { surah, practice, tajweedRead }

class QuranLearnSurahsPage extends StatelessWidget {
  const QuranLearnSurahsPage({
    super.key,
    required this.pack,
    this.mode = QuranLearnReadMode.surah,
    this.levelId,
  });

  final QuranLearningPack pack;
  final QuranLearnReadMode mode;
  final int? levelId;

  int get _levelId =>
      levelId ??
      switch (mode) {
        QuranLearnReadMode.surah => 5,
        QuranLearnReadMode.practice => 7,
        QuranLearnReadMode.tajweedRead => 8,
      };

  String get _title {
    switch (mode) {
      case QuranLearnReadMode.surah:
        return pack.titleForLevel(_levelId, fallback: 'Uygulama');
      case QuranLearnReadMode.practice:
        return pack.titleForLevel(_levelId, fallback: 'Uygulama — Okuma Pratiği');
      case QuranLearnReadMode.tajweedRead:
        return pack.titleForLevel(
          _levelId,
          fallback: 'Uygulama — Tecvidli Okuma',
        );
    }
  }

  String get _kind {
    switch (mode) {
      case QuranLearnReadMode.surah:
        return 'ql_surah';
      case QuranLearnReadMode.practice:
        return 'ql_practice';
      case QuranLearnReadMode.tajweedRead:
        return 'ql_tajweed_read';
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    final items = pack.surahsForLevel(_levelId, kind: _kind);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(_levelId) ?? 0;
          final total = items.length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total parça',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final surah in items)
                ContentTile(
                  title: surah.nameTr,
                  subtitle: surah.listSubtitle,
                  color: snap?.isDone(_kind, surah.id) == true
                      ? MinikColors.mint
                      : null,
                  leading: NumberBadge('${surah.priority}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranLearnSurahReaderPage(
                        pack: pack,
                        surah: surah,
                        mode: mode,
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

enum _AlongMode { idle, listening, echoPlay, echoWait }

class QuranLearnSurahReaderPage extends StatefulWidget {
  const QuranLearnSurahReaderPage({
    super.key,
    required this.pack,
    required this.surah,
    required this.mode,
  });

  final QuranLearningPack pack;
  final QuranLearningSurah surah;
  final QuranLearnReadMode mode;

  @override
  State<QuranLearnSurahReaderPage> createState() =>
      _QuranLearnSurahReaderPageState();
}

class _QuranLearnSurahReaderPageState extends State<QuranLearnSurahReaderPage> {
  final _audio = AudioPlayerService();
  final _ayahKeys = <int, GlobalKey>{};
  Future<List<QuranVerse>>? _future;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<bool>? _completedSub;
  List<QuranLearnFollowSpan> _spans = const [];
  int _highlight = -1;
  int _session = 0;
  _AlongMode _mode = _AlongMode.idle;

  String get _kind {
    switch (widget.mode) {
      case QuranLearnReadMode.surah:
        return 'ql_surah';
      case QuranLearnReadMode.practice:
        return 'ql_practice';
      case QuranLearnReadMode.tajweedRead:
        return 'ql_tajweed_read';
    }
  }

  String? get _audioPath {
    return QuranLearnAudio.surahPath(
      widget.surah.surahNumber,
      jsonAudio: widget.surah.audio,
      allowFullSurahFallback: widget.surah.ayahFrom == null,
    );
  }

  bool get _isListening => _mode == _AlongMode.listening;

  bool get _isEcho =>
      _mode == _AlongMode.echoPlay || _mode == _AlongMode.echoWait;

  @override
  void dispose() {
    _positionSub?.cancel();
    _completedSub?.cancel();
    _audio.dispose();
    super.dispose();
  }

  Future<List<QuranVerse>> _load() async {
    final verses = await context.read<ContentRepositories>().quran.getSurah(
          widget.surah.surahNumber,
        );
    final from = widget.surah.ayahFrom;
    if (from == null) return verses;
    final to = widget.surah.ayahTo ?? from;
    return [
      for (final verse in verses)
        if (verse.ayahNo >= from && verse.ayahNo <= to) verse,
    ];
  }

  Future<void> _cancelSession() async {
    _session++;
    await _positionSub?.cancel();
    await _completedSub?.cancel();
    _positionSub = null;
    _completedSub = null;
    await _audio.stop();
  }

  Future<Duration?> _prepare(List<QuranVerse> verses, {required bool count}) {
    return QuranLearnAudio.prepare(
      _audio,
      context.read<LocalProgressStore>(),
      _audioPath,
      countPlay: count,
    ).then((duration) {
      if (duration != null) {
        _spans = QuranLearnFollowTimeline.fromArabic(
          [for (final verse in verses) verse.arabic],
          duration,
        );
      }
      return duration;
    });
  }

  void _listenPosition() {
    _positionSub?.cancel();
    _positionSub = _audio.positionStream.listen((position) {
      if (!mounted || !_isListening || _spans.isEmpty) return;
      final next = QuranLearnFollowTimeline.indexAt(_spans, position);
      if (next == _highlight) return;
      setState(() => _highlight = next);
      _scrollTo(next);
    });
    _completedSub?.cancel();
    _completedSub = _audio.completedStream.listen((done) {
      if (!mounted || !done || !_isListening) return;
      setState(() => _mode = _AlongMode.idle);
    });
  }

  void _scrollTo(int index) {
    final context = _ayahKeys[index]?.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _ayahKeys[index]?.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        alignment: 0.18,
      );
    });
  }

  Future<void> _startListen(List<QuranVerse> verses, {int fromAyah = 0}) async {
    if (_audioPath == null) return;
    if (_isListening) {
      await _stopAlong();
      return;
    }
    await _cancelSession();
    final duration = await _prepare(verses, count: true);
    if (!mounted || duration == null || duration <= Duration.zero) return;
    final startIndex = fromAyah.clamp(0, verses.length - 1);
    setState(() {
      _mode = _AlongMode.listening;
      _highlight = startIndex;
    });
    _scrollTo(startIndex);
    await _audio.seek(_spans[startIndex].start);
    _listenPosition();
    await _audio.resume();
  }

  Future<void> _startEcho(List<QuranVerse> verses, {int fromAyah = 0}) async {
    if (_audioPath == null) return;
    if (_isEcho) {
      await _stopAlong();
      return;
    }
    await _cancelSession();
    final duration = await _prepare(verses, count: true);
    if (!mounted || duration == null || duration <= Duration.zero) return;
    await _playEchoAyah(fromAyah.clamp(0, verses.length - 1));
  }

  Future<void> _playEchoAyah(int index) async {
    final session = ++_session;
    if (_spans.isEmpty || index < 0 || index >= _spans.length) return;
    setState(() {
      _mode = _AlongMode.echoPlay;
      _highlight = index;
    });
    _scrollTo(index);
    final span = _spans[index];
    await _audio.seek(span.start);
    await _audio.resume();
    await _waitUntil(
      start: span.start,
      end: span.end,
      session: session,
      timeout: span.end - span.start + const Duration(seconds: 3),
    );
    if (!mounted || session != _session) return;
    await _audio.pause();
    if (!mounted || session != _session) return;
    setState(() => _mode = _AlongMode.echoWait);
  }

  Future<void> _waitUntil({
    required Duration start,
    required Duration end,
    required int session,
    required Duration timeout,
  }) async {
    final done = Completer<void>();
    late final StreamSubscription<Duration> pos;
    late final StreamSubscription<bool> completed;
    var armed = false;
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    pos = _audio.positionStream.listen((position) {
      if (session != _session) {
        finish();
        return;
      }
      final inAyah = position >= start - const Duration(milliseconds: 400) &&
          position < end;
      if (inAyah) armed = true;
      if (armed && position >= end) finish();
    });
    completed = _audio.completedStream.listen((isDone) {
      if (isDone) finish();
    });
    await done.future.timeout(timeout, onTimeout: finish);
    await pos.cancel();
    await completed.cancel();
  }

  Future<void> _stopAlong() async {
    await _cancelSession();
    if (!mounted) return;
    setState(() => _mode = _AlongMode.idle);
  }

  Future<void> _onAyahTap(int index) async {
    setState(() => _highlight = index);
    _scrollTo(index);
    if (_audioPath == null || _spans.isEmpty) return;
    if (_isListening) {
      await _audio.seek(_spans[index].start);
      if (!_audio.isPlaying) await _audio.resume();
      return;
    }
    if (_isEcho) {
      await _playEchoAyah(index);
    }
  }

  Future<void> _mark() async {
    await QuranLearnProgress.complete(
      context.read<LocalProgressStore>(),
      pack: widget.pack,
      kind: _kind,
      id: widget.surah.id,
    );
    if (!mounted) return;
    await showQlCelebration(
      context,
      title: 'Harika!',
      subtitle: widget.surah.ayahFrom == null
          ? '${widget.surah.nameTr} suresini tamamladın.'
          : '${widget.surah.nameTr} okumasını tamamladın.',
      onContinue: () => Navigator.pop(context),
    );
  }

  String get _hint {
    switch (_mode) {
      case _AlongMode.listening:
        return 'Sarı ayeti sesle birlikte takip et. Ayetin üstüne dokunursan oraya atlar.';
      case _AlongMode.echoPlay:
        return 'Dinle. Bitince sen oku.';
      case _AlongMode.echoWait:
        return 'Şimdi sen oku. Hazır olunca sonraki ayete geç.';
      case _AlongMode.idle:
        if (_audioPath == null) {
          return 'Bu parçada eşleşen eğitim sesi yok. Ayet ve meali oku; Öğrendim ile tamamla.';
        }
        return 'Dinle veya Takip Et: sureyi dinlerken ayetler işaretlenir. Benimle Oku: bir ayet dinle, sonra sen oku.';
    }
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(widget.surah.nameTr),
        actions: [
          FavoriteButton(
            kind: 'ql_surah',
            id: widget.surah.id,
            title: widget.surah.nameTr,
          ),
        ],
      ),
      body: AsyncBody<List<QuranVerse>>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(() => _future = _load()),
        builder: (verses) {
          for (var i = 0; i < verses.length; i++) {
            _ayahKeys.putIfAbsent(i, GlobalKey.new);
          }
          return ListView(
            padding: AppSpacing.page,
            children: [
              MinikCard(
                color: MinikColors.mint,
                child: Column(
                  children: [
                    ArabicText(widget.surah.nameAr, fontSize: 28),
                    Text(
                      widget.surah.nameTr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('${verses.length} ayet · doğrulanmış Kur\'an metni'),
                    if (widget.mode == QuranLearnReadMode.tajweedRead) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Öğrendiğin tecvid kurallarını bu ayetlerde fark et. Sarı etiketler derste gördüğün kurallardır.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        color: MinikColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_audioPath != null)
                    FilledButton.icon(
                      onPressed: () => _startListen(verses),
                      icon: Icon(
                        _isListening
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                      ),
                      label: Text(_isListening ? 'Durdur' : 'Dinle'),
                    ),
                  if (_audioPath != null)
                    OutlinedButton.icon(
                      onPressed: () => _startListen(
                        verses,
                        fromAyah: _highlight < 0 ? 0 : _highlight,
                      ),
                      icon: const Icon(Icons.touch_app_rounded),
                      style: _isListening
                          ? OutlinedButton.styleFrom(
                              backgroundColor: MinikColors.butter,
                            )
                          : null,
                      label: Text(_isListening ? 'Takip açık' : 'Takip Et'),
                    ),
                  if (_audioPath != null)
                    OutlinedButton.icon(
                      onPressed: () => _startEcho(
                        verses,
                        fromAyah: _highlight < 0 ? 0 : _highlight,
                      ),
                      icon: const Icon(Icons.record_voice_over_rounded),
                      style: _isEcho
                          ? OutlinedButton.styleFrom(
                              backgroundColor: MinikColors.butter,
                            )
                          : null,
                      label: Text(_isEcho ? 'Okumayı bitir' : 'Benimle Oku'),
                    ),
                ],
              ),
              if (_isEcho) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _mode == _AlongMode.echoPlay
                          ? null
                          : () => _playEchoAyah(_highlight < 0 ? 0 : _highlight),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Tekrar dinle'),
                    ),
                    FilledButton.icon(
                      onPressed: _mode == _AlongMode.echoPlay
                          ? null
                          : () {
                              final next = (_highlight < 0 ? 0 : _highlight) + 1;
                              if (next >= verses.length) {
                                _stopAlong();
                                return;
                              }
                              _playEchoAyah(next);
                            },
                      icon: const Icon(Icons.skip_next_rounded),
                      label: Text(
                        _highlight >= verses.length - 1
                            ? 'Bitti'
                            : 'Sonraki ayet',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < verses.length; i++)
                Padding(
                  key: _ayahKeys[i],
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MinikCard(
                    color: _highlight == i
                        ? MinikColors.butter
                        : MinikColors.surface,
                    onTap: () => _onAyahTap(i),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              SoftBadge(label: '${verses[i].ayahNo}'),
                              const Spacer(),
                              QlColorIconButton(
                                arabic: verses[i].arabic,
                                title:
                                    '${widget.surah.nameTr} ${verses[i].ayahNo}',
                                prompt: 'Bu ayeti boya.',
                                audio: _audioPath,
                              ),
                              CopyIconButton(
                                text: joinCopyParts([
                                  '${widget.surah.nameTr} ${verses[i].ayahNo}',
                                  verses[i].arabic,
                                  verses[i].meal,
                                ]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        IgnorePointer(
                          child: ArabicText(verses[i].arabic, fontSize: 26),
                        ),
                        if (widget.mode == QuranLearnReadMode.tajweedRead) ...[
                          const SizedBox(height: 8),
                          QlTajweedHitChips(
                            quranLearnTajweedHits(
                              arabic: verses[i].arabic,
                              lessons: widget.pack.tajweed,
                            ),
                          ),
                        ],
                        if (widget.surah.ayahFrom != null &&
                            verses[i].hasMeal) ...[
                          const SizedBox(height: 8),
                          Text(
                            verses[i].meal,
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              color: MinikColors.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              QlPrimaryBar(label: 'Öğrendim', onPressed: _mark),
            ],
          );
        },
      ),
    );
  }
}
