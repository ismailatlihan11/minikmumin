import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/dhikr.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/listen_button.dart';
import 'dhikr_logic.dart';
import 'dhikr_store.dart';
import 'tasbih_beads.dart';
import 'zikr_form_page.dart';

class ZikrCounterPage extends StatefulWidget {
  const ZikrCounterPage({super.key, required this.dhikrId});

  final String dhikrId;

  @override
  State<ZikrCounterPage> createState() => _ZikrCounterPageState();
}

class _ZikrCounterPageState extends State<ZikrCounterPage>
    with SingleTickerProviderStateMixin {
  final _phraseAudio = AudioPlayerService();
  var _locked = false;
  var _showDetails = false;
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<DhikrStore>().warmupClick());
    });
  }

  @override
  void dispose() {
    _burst.dispose();
    _phraseAudio.dispose();
    super.dispose();
  }

  Future<void> _tap(Future<dynamic> Function() action,
      {bool completeCheck = false}) async {
    if (_locked) return;
    _locked = true;
    try {
      final result = await action();
      if (!mounted) return;
      if (completeCheck && result is DhikrTapResult && result.completed) {
        await _onCompleted(result.dhikr);
      }
    } finally {
      _locked = false;
    }
  }

  Future<void> _onCompleted(Dhikr dhikr) async {
    _burst.forward(from: 0);
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) => AlertDialog(
        title: const Text('Çok güzel.'),
        content: Text('Bugünkü zikrini tamamladın. ${dhikr.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'again'),
            child: const Text('Bir kez daha'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'new'),
            child: const Text('Yeni zikir'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'ok'),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _burst.reset();
    final store = context.read<DhikrStore>();
    if (choice == 'again' || choice == 'ok') {
      await store.startAgain(widget.dhikrId);
    } else if (choice == 'new') {
      await store.startAgain(widget.dhikrId);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _confirmReset() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bu zikri sıfırlamak istediğine emin misin?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Vazgeç',
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'Sıfırla',
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      await context.read<DhikrStore>().resetCurrent(widget.dhikrId);
    }
  }

  Future<void> _handlePop(bool didPop) async {
    if (didPop) return;
    final store = context.read<DhikrStore>();
    final dhikr = store.byId(widget.dhikrId);
    if (dhikr == null ||
        dhikr.currentCount <= 0 ||
        dhikr.currentCount >= dhikr.targetCount) {
      if (mounted) Navigator.pop(context);
      return;
    }
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Zikri yarım bırakmak ister misin?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Devam et',
              onPressed: () => Navigator.pop(context, 'stay'),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: 'Sonra devam et',
              onPressed: () => Navigator.pop(context, 'pause'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'pause') {
      await store.pause(widget.dhikrId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DhikrStore>();
    final dhikr = store.byId(widget.dhikrId);
    if (dhikr == null) {
      return const Scaffold(body: Center(child: Text('Zikir bulunamadı.')));
    }
    final needsConfirm =
        dhikr.currentCount > 0 && dhikr.currentCount < dhikr.targetCount;
    return PopScope(
      canPop: !needsConfirm,
      onPopInvokedWithResult: (didPop, _) => _handlePop(didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text(dhikr.title),
          actions: [
            IconButton(
              tooltip:
                  dhikr.isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
              onPressed: () => store.toggleFavorite(dhikr.id),
              icon: Icon(
                dhikr.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: dhikr.isFavorite ? const Color(0xFFC45B7A) : null,
              ),
            ),
            CopyIconButton(
              text: joinCopyParts([
                dhikr.title,
                dhikr.arabic,
                dhikr.transliteration,
                dhikr.meaning,
              ]),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _burst,
          builder: (context, _) {
            return Stack(
              children: [
                ListView(
                  padding: AppSpacing.page,
                  children: [
                    if (dhikr.transliteration.isNotEmpty)
                      Text(
                        dhikr.transliteration,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: MinikColors.darkGreen,
                              height: 1.35,
                            ),
                      )
                    else if (dhikr.arabic.isNotEmpty)
                      ArabicText(dhikr.arabic, fontSize: 32),
                    if (_hasDetails(dhikr)) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _showDetails = !_showDetails),
                          icon: Icon(
                            _showDetails
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                          ),
                          label: Text(_showDetails
                              ? 'Detayları gizle'
                              : 'Detay göster'),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _showDetails
                            ? Column(
                                children: [
                                  if (dhikr.arabic.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    ArabicText(dhikr.arabic, fontSize: 28),
                                  ],
                                  if (dhikr.meaning.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    SelectableText(
                                      dhikr.meaning,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                    ListenButton(
                        audio: _phraseAudio, path: store.audioFor(dhikr)),
                    const SizedBox(height: AppSpacing.md),
                    if (DhikrTasbih.showsRounds(dhikr.targetCount))
                      Text(
                        dhikr.currentCount >= dhikr.targetCount
                            ? 'Turlar tamam'
                            : 'Kalan tur: ${DhikrTasbih.remainingRounds(dhikr.currentCount, dhikr.targetCount)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                    Text(
                      '${dhikr.currentCount}',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: MinikColors.darkGreen,
                              ),
                    ),
                    Text(
                      '/ ${dhikr.targetCount}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: dhikr.uiProgress,
                        backgroundColor: MinikColors.creamDark,
                        color: MinikColors.green,
                      ),
                    ),
                    if (dhikr.dailySessionTarget > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Günlük oturum: ${store.todayCompletedCount(dhikr.id)} / ${dhikr.dailySessionTarget}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    TasbihBeadsView(
                      beadCount: DhikrTasbih.visibleBeadCount(
                        dhikr.currentCount,
                        dhikr.targetCount,
                      ),
                      pulled: DhikrTasbih.pulledThisRound(
                        dhikr.currentCount,
                        dhikr.targetCount,
                      ),
                      firstNumber: DhikrTasbih.roundStartNumber(
                        dhikr.currentCount,
                        dhikr.targetCount,
                      ),
                      maxNumber: dhikr.targetCount,
                      burst: _burst.value,
                      onTap: () => _tap(
                        () => store.addCount(dhikr.id),
                        completeCheck: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tesbihe dokun, bir tane çek',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontWeight: FontWeight.w700,
                        color: MinikColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tesbih sesi'),
                      subtitle: const Text('Her çekişte tıklar'),
                      value: store.settings.soundEnabled && dhikr.soundEnabled,
                      onChanged: (value) {
                        store.updateSettings(
                          store.settings.copyWith(soundEnabled: value),
                        );
                        store.updateDhikr(dhikr.copyWith(soundEnabled: value));
                      },
                      secondary: Icon(
                        store.settings.soundEnabled && dhikr.soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: MinikColors.green,
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Titreşim'),
                      subtitle: const Text('Her çekişte titreşim verir'),
                      value: store.settings.vibrationEnabled &&
                          dhikr.vibrationEnabled,
                      onChanged: (value) {
                        store.updateSettings(
                          store.settings.copyWith(vibrationEnabled: value),
                        );
                        store.updateDhikr(
                            dhikr.copyWith(vibrationEnabled: value));
                      },
                      secondary: const Icon(Icons.vibration_rounded),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _RoundControl(
                          icon: Icons.remove_rounded,
                          onTap: () =>
                              _tap(() => store.subtractCount(dhikr.id)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Sıfırla',
                            onPressed: _confirmReset,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _RoundControl(
                          icon: Icons.add_rounded,
                          onTap: () => _tap(() => store.addCount(dhikr.id),
                              completeCheck: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => _editSettings(dhikr),
                      child: const Text('Zikir ayarları'),
                    ),
                  ],
                ),
                ZikrCelebrateBackdrop(
                  progress: _burst.value,
                  beadCount: DhikrTasbih.visibleBeadCount(
                    dhikr.currentCount,
                    dhikr.targetCount,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _editSettings(Dhikr dhikr) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZikrFormPage(existing: dhikr)),
    );
  }

  bool _hasDetails(Dhikr dhikr) {
    return dhikr.arabic.isNotEmpty || dhikr.meaning.isNotEmpty;
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MinikColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: MinikColors.darkGreen),
        ),
      ),
    );
  }
}
