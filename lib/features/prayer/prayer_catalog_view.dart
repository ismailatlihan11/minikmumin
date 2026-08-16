import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../../features/duas/duas_page.dart';
import '../../shared/widgets/minik_ui.dart';
import 'prayer_visual_catalog.dart';

class PrayerCatalogView extends StatefulWidget {
  const PrayerCatalogView({
    super.key,
    required this.onBack,
    required this.onHome,
    required this.onOpenStep,
  });

  final VoidCallback onBack;
  final VoidCallback onHome;
  final ValueChanged<PrayerVisualStep> onOpenStep;

  @override
  State<PrayerCatalogView> createState() => _PrayerCatalogViewState();
}

class _PrayerCatalogViewState extends State<PrayerCatalogView> {
  final _scroll = ScrollController();
  List<PrayerVisualStep> _steps = PrayerVisualCatalog.steps;
  List<PrayerTip> _tips = PrayerVisualCatalog.tips;
  List<PrayerRakat> _rakats = PrayerVisualCatalog.rakats;
  List<String> _farzLabels = PrayerVisualCatalog.farzLabels;
  List<String> _farzIds = PrayerVisualCatalog.farzIds;
  List<({String id, String title})> _duaList = PrayerVisualCatalog.duaList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindJson());
  }

  Future<void> _bindJson() async {
    final lesson = await context.read<ContentRepositories>().prayer.getLesson();
    if (!mounted) return;
    setState(() {
      _steps = PrayerVisualCatalog.resolveSteps(lesson.visualSteps);
      _tips = PrayerVisualCatalog.resolveTips(lesson.tips);
      _rakats = PrayerVisualCatalog.resolveRakats(lesson.rakats);
      if (lesson.farzLabels.isNotEmpty) _farzLabels = lesson.farzLabels;
      if (lesson.farzIds.isNotEmpty) _farzIds = lesson.farzIds;
      _duaList = PrayerVisualCatalog.resolveDuaList(lesson.duaList);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F6F8),
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Expanded(
                child: Text(
                  'NAMAZI ÖĞREN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF163A4A),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const Text(
            'Adım adım namaz kılmayı öğrenelim',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _LegendChip(
                icon: Icons.check_rounded,
                color: Color(0xFF3D8B6E),
                label: 'Farz',
              ),
              _LegendChip(
                icon: Icons.star_rounded,
                color: Color(0xFFE0A21A),
                label: 'Sünnet',
              ),
              _LegendChip(
                icon: Icons.info_rounded,
                color: Color(0xFF4C8ED9),
                label: 'Öğüt / Adab',
              ),
            ],
          ),
          const SizedBox(height: 12),
          MinikCard(
            color: Colors.white,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/prayer/prayer_intro_boy.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Namazın 5 Farzı',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: MinikColors.darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                for (final label in _farzLabels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: MinikColors.green),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () => _scroll.animateTo(
                    280,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: MinikColors.green,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Başlayalım'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hangi namaz kaç rekattır?',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Beş vakit namazın farz rekâtları',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          MinikCard(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                for (var i = 0; i < _rakats.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: Color(0xFFE8EEEA)),
                  _RakatRow(item: _rakats[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.72,
            children: [
              for (final step in _steps)
                _PrayerStepCard(
                  step: step,
                  onTap: () => widget.onOpenStep(step),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Namazda okunan Ayetler ve Dualar',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          MinikCard(
            color: Colors.white,
            onTap: () => Navigator.pushNamed(context, AppRoutes.learnPrayerDuas),
            child: Column(
              children: [
                for (final item in _duaList)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: MinikColors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Biliyor musun?',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _tips.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _TipTile(tip: _tips[i])),
              ],
            ],
          ),
          const SizedBox(height: 16),
          MinikCard(
            color: const Color(0xFFEDE4F8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mini Test',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Öğrendiklerini pekiştir.',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    color: MinikColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.quiz),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5EA7),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Teste Başla'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Namazın 5 Farzı',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _farzIds.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _FarzTile(
                    step: _steps.firstWhere(
                      (item) => item.id == _farzIds[i],
                      orElse: () => _steps.first,
                    ),
                    label: i < _farzLabels.length ? _farzLabels[i] : _farzIds[i],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          MinikCard(
            color: const Color(0xFFFFF6DC),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/prayer/prayer_trophy.png',
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tebrikler!',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Harikasın! Namazı çok güzel öğrendin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MinikColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: widget.onHome,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5EA7),
                    minimumSize: const Size.fromHeight(46),
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Ana Sayfaya Dön'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _scroll.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: const Color(0xFF4C8ED9),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Baştan Tekrar Et'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RakatRow extends StatelessWidget {
  const _RakatRow({required this.item});

  final PrayerRakat item;

  static const _colors = {
    'fajr': Color(0xFFE0A21A),
    'dhuhr': Color(0xFF4C8ED9),
    'asr': Color(0xFFE07A3D),
    'maghrib': Color(0xFF7B5EA7),
    'isha': Color(0xFF3D8B6E),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[item.id] ?? MinikColors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              '${item.farz}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                Text(
                  item.summary,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.2,
                  ),
                ),
                Text(
                  item.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MinikColors.textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: MinikColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerStepCard extends StatelessWidget {
  const _PrayerStepCard({required this.step, required this.onTap});

  final PrayerVisualStep step;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: MinikColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      step.number.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      step.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(child: Image.asset(step.image, fit: BoxFit.contain)),
              Text(
                step.prompt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: MinikColors.textMuted,
                  height: 1.2,
                ),
              ),
              if (step.caption.isNotEmpty)
                Text(
                  step.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: MinikColors.green,
                  ),
                ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: _KindMark(kind: step.kind),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindMark extends StatelessWidget {
  const _KindMark({required this.kind});

  final PrayerKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case PrayerKind.farz:
        return const _RoundIcon(icon: Icons.check_rounded, color: Color(0xFF3D8B6E));
      case PrayerKind.sunnah:
        return const _RoundIcon(icon: Icons.star_rounded, color: Color(0xFFE0A21A));
      case PrayerKind.adab:
        return const _RoundIcon(icon: Icons.info_rounded, color: Color(0xFF4C8ED9));
      case PrayerKind.done:
        return const _RoundIcon(icon: Icons.celebration_rounded, color: Color(0xFFE0A21A));
    }
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: 15, color: Colors.white),
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({required this.tip});

  final PrayerTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Image.asset(tip.image, height: 36, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            tip.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: MinikColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarzTile extends StatelessWidget {
  const _FarzTile({required this.step, required this.label});

  final PrayerVisualStep step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Image.asset(step.image, height: 36, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: MinikColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerStepDetailPage extends StatefulWidget {
  const PrayerStepDetailPage({super.key, required this.step});

  final PrayerVisualStep step;

  @override
  State<PrayerStepDetailPage> createState() => _PrayerStepDetailPageState();
}

class _PrayerStepDetailPageState extends State<PrayerStepDetailPage> {
  final _audio = AudioPlayerService();
  PrayerDua? _dua;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDua());
  }

  Future<void> _loadDua() async {
    final id = widget.step.duaId;
    if (id == null) return;
    final duas = await context.read<ContentRepositories>().duas.getPrayerDuas();
    if (!mounted) return;
    setState(() {
      for (final dua in duas) {
        if (dua.id == id) {
          _dua = dua;
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final audioPath = step.duaId == null ? null : ContentAssets.audioFor(step.duaId!);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(title: Text(step.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                MinikCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(step.image, height: 168, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Text(step.prompt, style: Theme.of(context).textTheme.bodyLarge),
                if (_dua != null) ...[
                  const SizedBox(height: 14),
                  DuaContentBlocks(
                    dua: DuaEntry.fromPrayerDua(_dua!),
                    arabicFontSize: 22,
                  ),
                ] else if (step.caption.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    step.caption,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ],
            ),
          ),
          if (audioPath != null && AssetCatalog.contains(audioPath))
            Material(
              color: MinikColors.surface,
              elevation: 6,
              shadowColor: const Color(0x14000000),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ListenButton(audio: _audio, path: audioPath),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
