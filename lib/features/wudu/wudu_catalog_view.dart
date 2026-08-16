import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/minik_ui.dart';
import 'wudu_visual_catalog.dart';

class WuduCatalogView extends StatefulWidget {
  const WuduCatalogView({
    super.key,
    required this.onBack,
    required this.onHome,
    required this.onOpenStep,
  });

  final VoidCallback onBack;
  final VoidCallback onHome;
  final ValueChanged<WuduVisualStep> onOpenStep;

  @override
  State<WuduCatalogView> createState() => _WuduCatalogViewState();
}

class _WuduCatalogViewState extends State<WuduCatalogView> {
  final _scroll = ScrollController();
  List<WuduVisualStep> _steps = WuduVisualCatalog.steps;
  List<WuduTip> _tips = WuduVisualCatalog.tips;
  List<String> _farzIds = WuduVisualCatalog.farzIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindJson());
  }

  Future<void> _bindJson() async {
    final lesson = await context.read<ContentRepositories>().wudu.getLesson();
    if (!mounted) return;
    setState(() {
      _steps = WuduVisualCatalog.resolveSteps(lesson.visualSteps);
      _tips = WuduVisualCatalog.resolveTips(lesson.tips);
      if (lesson.farzIds.isNotEmpty) _farzIds = lesson.farzIds;
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
                  'ABDESTİ ÖĞREN',
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
            'Adım adım abdest almayı öğrenelim',
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
            children: [
              for (final step in _steps)
                _WuduStepCard(
                  step: step,
                  onTap: () => widget.onOpenStep(step),
                ),
            ],
          ),
          const SizedBox(height: 14),
          MinikCard(
            color: Colors.white,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/wudu/wudu_dua_boy.png',
                  width: 86,
                  height: 86,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abdest Tamamlandı Duası',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dua metni ve ses dosyası sonra eklenecek.',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 12,
                          color: MinikColors.textMuted,
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
                Expanded(
                  child: _TipTile(tip: _tips[i]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Abdestin 4 Farzı',
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
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _FarzTile(
                    step: _steps.firstWhere(
                      (item) => item.id == _farzIds[i],
                      orElse: () => _steps.first,
                    ),
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
                  'assets/images/wudu/wudu_trophy.png',
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
                  'Harikasın! Abdesti çok güzel öğrendin.',
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

class _WuduStepCard extends StatelessWidget {
  const _WuduStepCard({required this.step, required this.onTap});

  final WuduVisualStep step;
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
              Expanded(
                child: Image.asset(step.image, fit: BoxFit.contain),
              ),
              Text(
                step.prompt,
                maxLines: 4,
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

  final WuduKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case WuduKind.farz:
        return const _RoundIcon(icon: Icons.check_rounded, color: Color(0xFF3D8B6E));
      case WuduKind.sunnah:
        return const _RoundIcon(icon: Icons.star_rounded, color: Color(0xFFE0A21A));
      case WuduKind.adab:
        return const _RoundIcon(icon: Icons.info_rounded, color: Color(0xFF4C8ED9));
      case WuduKind.done:
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

  final WuduTip tip;

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
  const _FarzTile({required this.step});

  final WuduVisualStep step;

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
          Image.asset(step.image, height: 40, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            step.title.replaceAll(' Yıkayalım', '').replaceAll(' Mesh Edelim', ''),
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

class WuduStepDetailPage extends StatelessWidget {
  const WuduStepDetailPage({super.key, required this.step});

  final WuduVisualStep step;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(title: Text(step.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MinikCard(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Image.asset(step.image, height: 240, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          Text(
            step.prompt,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
