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
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_audio.dart';
import 'quran_learn_color_page.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_tajweed_marks.dart';
import 'quran_learn_widgets.dart';

enum QuranLearnReadMode { surah, practice, tajweedRead }

class QuranLearnSurahsPage extends StatelessWidget {
  const QuranLearnSurahsPage({
    super.key,
    required this.pack,
    this.mode = QuranLearnReadMode.surah,
  });

  final QuranLearningPack pack;
  final QuranLearnReadMode mode;

  String get _title {
    switch (mode) {
      case QuranLearnReadMode.surah:
        return 'Kısa Sureler';
      case QuranLearnReadMode.practice:
        return 'Kur\'an Okuma Pratiği';
      case QuranLearnReadMode.tajweedRead:
        return 'Tecvidli Okuma';
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
    final levelId = switch (mode) {
      QuranLearnReadMode.surah => 5,
      QuranLearnReadMode.practice => 7,
      QuranLearnReadMode.tajweedRead => 8,
    };
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(_title)),
      body: FutureBuilder<QuranLearnSnapshot>(
        future: QuranLearnProgress.load(store, pack),
        builder: (context, snapshot) {
          final snap = snapshot.data;
          final done = snap?.completedCount(levelId) ?? 0;
          final total = pack.surahs.length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              QlSoftProgress(
                value: total == 0 ? 0 : done / total,
                label: '$done / $total sure',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final surah in pack.surahs)
                ContentTile(
                  title: surah.nameTr,
                  subtitle: '${surah.nameAr} · ${surah.ayahCount} ayet',
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
  Future<List<QuranVerse>>? _future;
  int _highlight = -1;
  bool _follow = false;

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

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<List<QuranVerse>> _load() {
    return context.read<ContentRepositories>().quran.getSurah(
          widget.surah.surahNumber,
        );
  }

  Future<void> _listen(List<QuranVerse> verses) async {
    final path = QuranLearnAudio.surahPath(
      widget.surah.surahNumber,
      jsonAudio: widget.surah.audio,
    );
    if (path == null) return;
    setState(() {
      _follow = true;
      _highlight = 0;
    });
    await QuranLearnAudio.play(
      _audio,
      context.read<LocalProgressStore>(),
      path,
    );
    if (!mounted) return;
    // Ayah-level highlight only; word sync can be added later.
    for (var i = 0; i < verses.length; i++) {
      if (!mounted || !_follow) return;
      setState(() => _highlight = i);
      await Future<void>.delayed(const Duration(seconds: 4));
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
      subtitle: '${widget.surah.nameTr} suresini tamamladın.',
      onContinue: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    final audioPath = QuranLearnAudio.surahPath(
      widget.surah.surahNumber,
      jsonAudio: widget.surah.audio,
    );
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (audioPath != null)
                    FilledButton.icon(
                      onPressed: () => _listen(verses),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Dinle'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _follow = !_follow;
                      if (_follow && _highlight < 0) _highlight = 0;
                    }),
                    icon: const Icon(Icons.touch_app_rounded),
                    label: Text(_follow ? 'Takip açık' : 'Takip Et'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _highlight = 0),
                    icon: const Icon(Icons.record_voice_over_rounded),
                    label: const Text('Benimle Oku'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _follow = true;
                      _highlight = 0;
                    }),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Oku'),
                  ),
                  if (QuranLearnAudio.canRecord)
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_rounded),
                      label: const Text('Kaydet'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < verses.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MinikCard(
                    color: _highlight == i
                        ? MinikColors.butter
                        : MinikColors.surface,
                    onTap: () => setState(() => _highlight = i),
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
                                title: '${widget.surah.nameTr} ${verses[i].ayahNo}',
                                prompt: 'Bu ayeti boya.',
                                audio: QuranLearnAudio.surahPath(
                                  widget.surah.surahNumber,
                                  jsonAudio: widget.surah.audio,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ArabicText(verses[i].arabic, fontSize: 26),
                        if (widget.mode == QuranLearnReadMode.tajweedRead) ...[
                          const SizedBox(height: 8),
                          QlTajweedHitChips(
                            quranLearnTajweedHits(
                              arabic: verses[i].arabic,
                              lessons: widget.pack.tajweed,
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
