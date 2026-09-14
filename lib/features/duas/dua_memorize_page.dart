import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/dua.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/favorite_button.dart';
import '../../shared/widgets/minik_ui.dart';

/// Namaz dua/sûre ezberi: ayet ayet kartlar, tıklayınca ilgili ses.
/// Sûrelerde her ayet için ayrı Husary Muallim kaydı kullanılır (tahmini seek yok).
class DuaMemorizePage extends StatefulWidget {
  const DuaMemorizePage({
    super.key,
    required this.dua,
    this.kind = 'prayer_dua',
  });

  final DuaEntry dua;
  final String kind;

  @override
  State<DuaMemorizePage> createState() => _DuaMemorizePageState();
}

class _DuaMemorizePageState extends State<DuaMemorizePage> {
  final _audio = AudioPlayerService();
  StreamSubscription<bool>? _completedSub;
  int _highlight = -1;
  bool _playingFull = false;
  int _session = 0;

  DuaEntry get _dua => widget.dua;

  List<_MemUnit> get _units => _MemUnit.fromDua(_dua);

  bool get _usesAyahClips {
    final surah = _dua.surahNumber;
    if (surah == null || _dua.verses.isEmpty) return false;
    return _units.every(
      (unit) =>
          unit.ayahNo != null &&
          AssetCatalog.contains(ContentAssets.ayahAudio(surah, unit.ayahNo!)),
    );
  }

  String get _fullPath => _dua.audio.trim();

  bool get _hasAnyAudio {
    if (_usesAyahClips) return true;
    return _fullPath.isNotEmpty && AssetCatalog.contains(_fullPath);
  }

  @override
  void dispose() {
    _session++;
    _completedSub?.cancel();
    _audio.dispose();
    super.dispose();
  }

  Future<void> _cancelSession() async {
    _session++;
    await _completedSub?.cancel();
    _completedSub = null;
  }

  Future<void> _stop() async {
    await _cancelSession();
    await _audio.stop();
    if (!mounted) return;
    setState(() {
      _playingFull = false;
      _highlight = -1;
    });
  }

  Future<void> _playFull() async {
    if (!_hasAnyAudio) return;
    if (_playingFull) {
      await _stop();
      return;
    }
    await _cancelSession();
    final session = ++_session;
    setState(() {
      _playingFull = true;
      _highlight = 0;
    });

    if (_usesAyahClips) {
      final surah = _dua.surahNumber!;
      for (var i = 0; i < _units.length; i++) {
        if (!mounted || session != _session) return;
        final ayah = _units[i].ayahNo!;
        setState(() => _highlight = i);
        final path = ContentAssets.ayahAudio(surah, ayah);
        final ok = await _audio.playAsset(path, waitUntilDone: true);
        if (!ok || !mounted || session != _session) return;
      }
      if (mounted && session == _session) await _stop();
      return;
    }

    // Tek parça dua: baştan sona dinle (parça tahmini yok).
    setState(() => _highlight = 0);
    await _audio.playAsset(_fullPath, waitUntilDone: false);
    _completedSub = _audio.completedStream.listen((done) async {
      if (!done || !mounted || session != _session) return;
      await _stop();
    });
  }

  Future<void> _playUnit(int index) async {
    if (!_hasAnyAudio || index < 0 || index >= _units.length) return;
    await _cancelSession();
    final session = ++_session;
    setState(() {
      _playingFull = false;
      _highlight = index;
    });

    if (_usesAyahClips) {
      final surah = _dua.surahNumber!;
      final ayah = _units[index].ayahNo!;
      await _audio.playAsset(
        ContentAssets.ayahAudio(surah, ayah),
        waitUntilDone: false,
      );
      _completedSub = _audio.completedStream.listen((done) async {
        if (!done || !mounted || session != _session) return;
        await _cancelSession();
        if (mounted) setState(() => _highlight = index);
      });
      return;
    }

    // Sûre dışı dualarda ayrı ayet sesi yok; tüm kaydı çal.
    await _audio.playAsset(_fullPath, waitUntilDone: false);
  }

  @override
  Widget build(BuildContext context) {
    final units = _units;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        title: Text(_dua.title),
        actions: [
          FavoriteButton(
            kind: widget.kind,
            id: _dua.id,
            title: _dua.title,
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.mint,
            child: Column(
              children: [
                if (units.length == 1 && units.first.arabic.isNotEmpty) ...[
                  ArabicText(units.first.arabic, fontSize: 26),
                  const SizedBox(height: 6),
                ],
                Text(
                  _dua.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _usesAyahClips
                      ? '${units.length} ayet · her ayetin kendi sesi'
                      : (units.length > 1
                          ? '${units.length} parça · ezber için dinle'
                          : 'Ezber için Dinle butonuna dokun.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _usesAyahClips
                      ? '“Bu ayeti dinle”ye dokun: yalnızca o ayet okunur. Üstteki Dinle: ayetleri sırayla dinlersin.'
                      : (units.length > 1
                          ? 'Her karttaki “Dinle” ile o parçayı dinlersin. Üstteki Dinle: hepsini sırayla çalar.'
                          : '“Dinle”ye dokununca dua sesi çalar.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    color: MinikColors.textMuted,
                  ),
                ),
                if (_hasAnyAudio) ...[
                  const SizedBox(height: 12),
                  StreamBuilder<bool>(
                    stream: _audio.playingStream,
                    initialData: _audio.isPlaying,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      final fullActive = _playingFull && isPlaying;
                      return FilledButton.icon(
                        onPressed: _playFull,
                        icon: Icon(
                          fullActive
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                        ),
                        label: Text(fullActive ? 'Durdur' : 'Dinle'),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < units.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MinikCard(
                color: _highlight == i
                    ? MinikColors.butter
                    : MinikColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SoftBadge(label: '${units[i].no}'),
                        const Spacer(),
                        CopyIconButton(
                          text: joinCopyParts([
                            '${_dua.title} ${units[i].no}',
                            units[i].arabic,
                            units[i].reading,
                            units[i].meal,
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ArabicText(units[i].arabic, fontSize: 26),
                    if (units[i].reading.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        units[i].reading,
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          color: MinikColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (units[i].meal.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        units[i].meal,
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          color: MinikColors.textMuted,
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (_hasAnyAudio) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StreamBuilder<bool>(
                          stream: _audio.playingStream,
                          initialData: _audio.isPlaying,
                          builder: (context, snapshot) {
                            final playing = (snapshot.data ?? false) &&
                                _highlight == i &&
                                !_playingFull;
                            return FilledButton.tonalIcon(
                              onPressed: () {
                                if (playing) {
                                  _stop();
                                } else {
                                  _playUnit(i);
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: playing
                                    ? MinikColors.green
                                    : const Color(0xFFE7F4EC),
                                foregroundColor: playing
                                    ? Colors.white
                                    : MinikColors.darkGreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 42),
                              ),
                              icon: Icon(
                                playing
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                size: 22,
                              ),
                              label: Text(
                                playing
                                    ? 'Durdur'
                                    : (_usesAyahClips
                                        ? 'Bu ayeti dinle'
                                        : 'Dinle'),
                                style: const TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemUnit {
  const _MemUnit({
    required this.no,
    required this.arabic,
    this.reading = '',
    this.meal = '',
    this.ayahNo,
  });

  final int no;
  final String arabic;
  final String reading;
  final String meal;
  final int? ayahNo;

  static List<_MemUnit> fromDua(DuaEntry dua) {
    if (dua.verses.isNotEmpty) {
      return [
        for (final verse in dua.verses)
          _MemUnit(
            no: verse.ayahNo,
            ayahNo: verse.ayahNo,
            arabic: verse.arabic,
            reading: verse.transliteration,
            meal: verse.meal,
          ),
      ];
    }
    // Sûre dışı duaları tek parça tut: satır satır ayırmak sesle uyuşmaz.
    return [
      _MemUnit(
        no: 1,
        arabic: dua.fullArabic.isNotEmpty ? dua.fullArabic : dua.arabic,
        reading: dua.transliteration,
        meal: dua.meaning,
      ),
    ];
  }
}
