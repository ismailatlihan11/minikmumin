import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../data/models/interactive_lesson.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/lesson_motion_image.dart';
import '../../shared/widgets/listen_button.dart';
import '../../shared/widgets/minik_coloring_page.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import '../../shared/widgets/topic_footer.dart';
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
  final void Function(
    WuduVisualStep step,
    List<WuduVisualStep> previous,
    List<WuduVisualStep> upcoming,
  ) onOpenStep;

  @override
  State<WuduCatalogView> createState() => _WuduCatalogViewState();
}

class _WuduCatalogViewState extends State<WuduCatalogView> {
  final _scroll = ScrollController();
  List<WuduVisualStep> _steps = WuduVisualCatalog.steps;
  List<WuduVisualStep> get _playableSteps =>
      [for (final step in _steps) if (step.kind != WuduKind.done) step];

  void _openStep(WuduVisualStep step) {
    final steps = _playableSteps;
    final index = steps.indexOf(step);
    widget.onOpenStep(
      step,
      steps.sublist(0, index),
      steps.sublist(index + 1),
    );
  }
  List<WuduTip> _tips = WuduVisualCatalog.tips;
  List<String> _farzIds = WuduVisualCatalog.farzIds;
  WuduCompletionDua? _dua;

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
      _dua = lesson.completionDua;
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
      color: MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A)),
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Geri',
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  'ABDESTİ ÖĞREN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.of(
                        const Color(0xFF163A4A), const Color(0xFFBFD6E0)),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          Text(
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
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _LegendChip(
                icon: Icons.check_rounded,
                color: MinikColors.greenSoft,
                label: 'Farz',
              ),
              const _LegendChip(
                icon: Icons.star_rounded,
                color: Color(0xFFE0A21A),
                label: 'Sünnet',
              ),
              const _LegendChip(
                icon: Icons.info_rounded,
                color: Color(0xFF4C8ED9),
                label: 'Öğüt / Adab',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
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
                    onTap: () => _openStep(
                      _steps.firstWhere(
                        (item) => item.id == _farzIds[i],
                        orElse: () => _steps.first,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Adım Adım Abdest Alalım',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
            children: [
              for (final step in _playableSteps)
                _WuduStepCard(
                  step: step,
                  onTap: () => _openStep(step),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _WuduDuaCard(dua: _dua),
          const SizedBox(height: 16),
          Text(
            'Abdestin Adabı',
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
          const SizedBox(height: 18),
          MinikCard(
            color: MinikColors.of(
                const Color(0xFFFFF6DC), const Color(0xFF3D3317)),
            child: Column(
              children: [
                MinikImage.asset(
                  'assets/images/wudu/wudu_trophy.jpg',
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tebrikler!',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Harikasın! Abdesti çok güzel öğrendin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MinikColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: MinikColors.of(
                        const Color(0xFFFFF1C2), const Color(0xFF463C1B)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🏆 Abdest Ustası',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '⭐ Yeni rozet kazandın!',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC48A12),
                        ),
                      ),
                    ],
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
        color: MinikColors.card,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
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
      color: MinikColors.card,
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
                    decoration: BoxDecoration(
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
                      style: TextStyle(
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
                child: MinikImage.asset(step.image, fit: BoxFit.contain),
              ),
              Text(
                step.prompt,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
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
        return _RoundIcon(
            icon: Icons.check_rounded, color: MinikColors.greenSoft);
      case WuduKind.sunnah:
        return const _RoundIcon(
            icon: Icons.star_rounded, color: Color(0xFFE0A21A));
      case WuduKind.adab:
        return const _RoundIcon(
            icon: Icons.info_rounded, color: Color(0xFF4C8ED9));
      case WuduKind.done:
        return const _RoundIcon(
            icon: Icons.celebration_rounded, color: Color(0xFFE0A21A));
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
        color: MinikColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          MinikImage.asset(tip.image, height: 36, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            tip.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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

class _WuduDuaCard extends StatelessWidget {
  const _WuduDuaCard({this.dua});

  final WuduCompletionDua? dua;

  @override
  Widget build(BuildContext context) {
    final ready = dua != null && dua!.arabic.trim().isNotEmpty;
    return MinikCard(
      color: MinikColors.card,
      onTap: ready
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WuduDuaPage(dua: dua!)),
              )
          : null,
      child: Row(
        children: [
          const LessonMotionImage(
            image: 'assets/images/wudu/wudu_dua_boy.jpg',
            width: 86,
            height: 86,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua?.title ?? 'Abdest Tamamlandı Duası',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ready
                      ? 'Abdest bitince bu duayı okuruz. Dinlemek için dokun.'
                      : 'Dua metni ve ses dosyası sonra eklenecek.',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    color: MinikColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (ready)
            Icon(Icons.chevron_right_rounded, color: MinikColors.green),
        ],
      ),
    );
  }
}

class WuduDuaPage extends StatefulWidget {
  const WuduDuaPage({super.key, required this.dua});

  final WuduCompletionDua dua;

  @override
  State<WuduDuaPage> createState() => _WuduDuaPageState();
}

class _WuduDuaPageState extends State<WuduDuaPage> {
  final _audio = AudioPlayerService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final audioPath = dua.audio.trim();
    return Scaffold(
      backgroundColor:
          MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A)),
      appBar: AppBar(title: Text(dua.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: LessonMotionImage(
              image: 'assets/images/wudu/wudu_dua_boy.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Abdestimizi bitirdikten sonra bu duayı okuruz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w600,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          MinikCard(
            color: MinikColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Arapça',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MinikColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ArabicText(dua.arabic, fontSize: 24),
              ],
            ),
          ),
          if (dua.transliteration.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            MinikCard(
              color: MinikColors.mint,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Okunuşu',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MinikColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dua.transliteration),
                ],
              ),
            ),
          ],
          if (dua.meaning.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            MinikCard(
              color: MinikColors.butter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anlamı',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: MinikColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dua.meaning),
                ],
              ),
            ),
          ],
          if (dua.source.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              dua.source,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                color: MinikColors.textMuted,
              ),
            ),
          ],
          if (audioPath.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListenButton(audio: _audio, path: audioPath),
          ],
        ],
      ),
    );
  }
}

class _FarzTile extends StatelessWidget {
  const _FarzTile({required this.step, this.onTap});

  final WuduVisualStep step;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MinikColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              MinikImage.asset(step.image, height: 40, fit: BoxFit.contain),
              const SizedBox(height: 4),
              Text(
                step.displayFarzTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
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

class WuduStepDetailPage extends StatelessWidget {
  const WuduStepDetailPage({
    super.key,
    required this.step,
    this.previous = const [],
    this.upcoming = const [],
  });

  final WuduVisualStep step;
  final List<WuduVisualStep> previous;
  final List<WuduVisualStep> upcoming;

  void _openNext(BuildContext context) {
    if (upcoming.isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WuduStepDetailPage(
          step: upcoming.first,
          previous: [...previous, step],
          upcoming: upcoming.sublist(1),
        ),
      ),
    );
  }

  void _openPrevious(BuildContext context) {
    if (previous.isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WuduStepDetailPage(
          step: previous.last,
          previous: previous.sublist(0, previous.length - 1),
          upcoming: [step, ...upcoming],
        ),
      ),
    );
  }

  void _openColoring(BuildContext context) {
    openImageColoring(
      context,
      image: step.image,
      title: '${step.title} boya',
      prompt: 'Parmağınla bu abdest adımını boya.',
      progressKind: 'wudu_color',
      progressId: step.id,
      celebrationSubtitle: '${step.title} resmini boyadın.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A)),
      appBar: AppBar(title: Text(step.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MinikCard(
            color: MinikColors.card,
            padding: const EdgeInsets.all(12),
            onTap: () => _openColoring(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                LessonMotionImage(
                  image: step.image,
                  frames: step.motionFrames,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const Positioned(
                  right: 4,
                  bottom: 4,
                  child: _ColorHint(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.prompt,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => _openColoring(context),
            icon: const Icon(Icons.palette_rounded),
            label: const Text('Boya'),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: MinikColors.surface,
        elevation: 6,
        shadowColor: const Color(0x14000000),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TopicFooter(
              hasNext: upcoming.isNotEmpty,
              onNext: () => _openNext(context),
              onPrevious:
                  previous.isEmpty ? null : () => _openPrevious(context),
              nextLabel:
                  previous.isEmpty ? 'Sonraki adıma geç' : 'Sonraki adım',
              backLabel: 'Adımlara dön',
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorHint extends StatelessWidget {
  const _ColorHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MinikColors.peach,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette_rounded, size: 16, color: MinikColors.darkGreen),
          const SizedBox(width: 4),
          Text(
            'Boya',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}
