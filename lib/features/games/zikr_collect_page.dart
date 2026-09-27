import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/asset_paths.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/dhikr.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import 'zikr_collect_logic.dart';

class ZikrCollectPage extends StatefulWidget {
  const ZikrCollectPage({super.key});

  @override
  State<ZikrCollectPage> createState() => _ZikrCollectPageState();
}

class _ZikrCollectPageState extends State<ZikrCollectPage> {
  Future<List<Dhikr>>? _future;
  final _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.dhikr.loadCatalog();
    return Scaffold(
      appBar: AppBar(title: const Text('Zikirleri topla')),
      body: AsyncBody<List<Dhikr>>(
        future: _future!,
        onRetry: () => setState(() {
          _future = repos.dhikr.loadCatalog();
        }),
        builder: (catalog) => _ZikrCollectPlay(
          catalog: catalog,
          audio: _audio,
        ),
      ),
    );
  }
}

class _ZikrCollectPlay extends StatefulWidget {
  const _ZikrCollectPlay({required this.catalog, required this.audio});

  final List<Dhikr> catalog;
  final AudioPlayerService audio;

  @override
  State<_ZikrCollectPlay> createState() => _ZikrCollectPlayState();
}

class _ZikrCollectPlayState extends State<_ZikrCollectPlay> {
  late List<ZikrCollectRound> _rounds;
  int _index = 0;
  String? _wrongId;
  bool _revealing = false;
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _rounds = ZikrCollectGame.build(widget.catalog);
    _index = 0;
    _wrongId = null;
    _revealing = false;
    _awarded = false;
  }

  ZikrCollectRound? get _current =>
      _index < _rounds.length ? _rounds[_index] : null;

  Future<void> _tap(Dhikr choice) async {
    final round = _current;
    if (round == null || _revealing) return;
    if (choice.id != round.target.id) {
      setState(() => _wrongId = choice.id);
      await widget.audio.playAsset(EffectAudio.retry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tekrar deneyelim.')),
      );
      return;
    }
    setState(() {
      _wrongId = null;
      _revealing = true;
    });
    await widget.audio.playAsset(EffectAudio.correct);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final next = _index + 1;
    final done = next >= _rounds.length;
    if (done && !_awarded) {
      _awarded = true;
      await widget.audio.playAsset(EffectAudio.complete);
      await context.read<LocalProgressStore>().addXp(8);
      await context
          .read<LocalProgressStore>()
          .markCompleted('game', 'zikr_collect');
    }
    if (!mounted) return;
    setState(() {
      _index = next;
      _revealing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
      return const Center(child: Text('Zikir bulunamadı.'));
    }
    final done = _index >= _rounds.length;
    if (done) return _doneView();
    final round = _current!;
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        children: [
          LessonProgressBar(current: _index, total: _rounds.length),
          const SizedBox(height: AppSpacing.sm),
          _BeadRow(filled: _index, total: _rounds.length),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            color: MinikColors.mint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hangisini topluyoruz?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  round.target.meaning,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_revealing)
            Expanded(
              child: SingleChildScrollView(
                child: MinikCard(
                  color: MinikColors.butter,
                  child: Column(
                    children: [
                      ArabicText(round.target.arabic, fontSize: 28),
                      const SizedBox(height: 8),
                      Text(
                        round.target.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (round.target.transliteration.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(round.target.transliteration),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
                children: [
                  for (var i = 0; i < round.choices.length; i++)
                    _ZikrBubble(
                      dhikr: round.choices[i],
                      color: MinikColors.pastelAt(i),
                      wrong: round.choices[i].id == _wrongId,
                      onTap: () => _tap(round.choices[i]),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _doneView() {
    return ListView(
      padding: AppSpacing.page,
      children: [
        MinikImage.asset(
          'assets/images/home/success.png',
          height: 120,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Maşallah!', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        const MinikCard(
          child: Text('Zikirleri doğru topladın. Tesbih tanelerin tamam.'),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(label: 'Tekrar dene', onPressed: () => setState(_reset)),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          label: 'Zikirmatikte çek',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.zikr),
        ),
      ],
    );
  }
}

class _BeadRow extends StatelessWidget {
  const _BeadRow({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0)
            Container(width: 8, height: 2, color: const Color(0xFFC9B48A)),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled
                  ? MinikColors.green
                  : MinikColors.of(
                      const Color(0xFFE8D9B0), const Color(0xFF49412C)),
              border: Border.all(color: const Color(0xFFC9B48A)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ZikrBubble extends StatelessWidget {
  const _ZikrBubble({
    required this.dhikr,
    required this.color,
    required this.wrong,
    required this.onTap,
  });

  final Dhikr dhikr;
  final Color color;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: wrong ? MinikColors.blush : color,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dhikr.arabic.isNotEmpty)
                Text(
                  dhikr.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AssetPaths.arabicFontFamily,
                    fontSize: 18,
                    height: 1.4,
                    color: MinikColors.darkGreen,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                dhikr.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
