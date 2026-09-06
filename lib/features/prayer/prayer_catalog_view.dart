import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/dua.dart';
import '../../data/repositories/content_repositories.dart';
import '../../features/duas/duas_page.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/lesson_motion_image.dart';
import '../../shared/widgets/minik_coloring_page.dart';
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
  final void Function(PrayerVisualStep step, {required bool girl, required int totalSteps})
      onOpenStep;

  @override
  State<PrayerCatalogView> createState() => _PrayerCatalogViewState();
}

class _PrayerCatalogViewState extends State<PrayerCatalogView> {
  final _scroll = ScrollController();
  List<PrayerVisualStep> _steps = PrayerVisualCatalog.steps;
  List<PrayerVisualStep> get _visibleSteps => [
        for (final step in _steps)
          if (!_girlLearner || !step.hideForGirl) step,
      ];
  List<PrayerTip> _tips = PrayerVisualCatalog.tips;
  List<PrayerRakat> _rakats = PrayerVisualCatalog.rakats;
  List<String> _farzLabels = PrayerVisualCatalog.farzLabels;
  List<({String id, String title})> _duaList = PrayerVisualCatalog.duaList;
  String _teachingNote = PrayerVisualCatalog.teachingNote;
  Set<String> _doneIds = {};
  Set<String> _favIds = {};
  bool _girlLearner = false;
  LocalProgressStore? _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindJson());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(store, _store)) {
      _store?.removeListener(_loadMarks);
      _store = store;
      _store!.addListener(_loadMarks);
      _loadMarks();
    }
  }

  Future<void> _loadMarks() async {
    final store = _store;
    if (store == null) return;
    final items = await store.getCompletedItems();
    final favs = await store.getFavorites();
    final girl = await store.getPrayerGirlLearner();
    if (!mounted) return;
    setState(() {
      _girlLearner = girl;
      _doneIds = {
        for (final item in items)
          if (item.startsWith('prayer|')) item.substring(7),
      };
      _favIds = {
        for (final item in favs)
          if (item.kind == 'prayer') item.id,
      };
    });
  }

  Future<void> _setGirlLearner(bool girl) async {
    setState(() => _girlLearner = girl);
    await _store?.setPrayerGirlLearner(girl);
  }

  Future<void> _bindJson() async {
    final lesson = await context.read<ContentRepositories>().prayer.getLesson();
    if (!mounted) return;
    setState(() {
      _steps = PrayerVisualCatalog.resolveSteps(lesson.visualSteps);
      _tips = PrayerVisualCatalog.resolveTips(lesson.tips);
      _rakats = PrayerVisualCatalog.resolveRakats(lesson.rakats);
      if (lesson.farzLabels.isNotEmpty) _farzLabels = lesson.farzLabels;
      _duaList = PrayerVisualCatalog.resolveDuaList(lesson.duaList);
      if (lesson.teachingNote.isNotEmpty) _teachingNote = lesson.teachingNote;
    });
  }

  List<Widget> _stepSections() {
    final blocks = <(String, List<PrayerVisualStep>)>[
      (
        '1. Rekat',
        [for (final step in _visibleSteps) if (step.rakat == 1) step],
      ),
      (
        '2. Rekat',
        [for (final step in _visibleSteps) if (step.rakat == 2) step],
      ),
    ];
    final rest = [
      for (final step in _visibleSteps)
        if (step.rakat != 1 && step.rakat != 2) step,
    ];
    if (rest.isNotEmpty) {
      blocks.add(('Namaz Bitti', rest));
    }
    return [
      for (final block in blocks)
        if (block.$2.isNotEmpty) ...[
          Text(
            block.$1,
            style: const TextStyle(
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
            childAspectRatio: 0.72,
            children: [
              for (final step in block.$2)
                _PrayerStepCard(
                  step: step,
                  girl: _girlLearner,
                  learned: _doneIds.contains(step.id),
                  favorite: _favIds.contains(step.id),
                  onTap: () => widget.onOpenStep(
                    step,
                    girl: _girlLearner,
                    totalSteps: _visibleSteps.length,
                  ),
                  onToggleFavorite: () {
                    _store?.toggleFavorite(
                      FavoriteEntry(
                        kind: 'prayer',
                        id: step.id,
                        title: step.title,
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
    ];
  }

  @override
  void dispose() {
    _store?.removeListener(_loadMarks);
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
          const SizedBox(height: 12),
          Center(
            child: _LearnerToggle(
              girl: _girlLearner,
              onChanged: _setGirlLearner,
            ),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Namaz Öğreniyorum',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: MinikColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _teachingNote,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: MinikColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          _PrayerProgressBar(
            done: _doneIds.where((id) => _visibleSteps.any((step) => step.id == id)).length,
            total: _visibleSteps.length,
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
                LessonMotionImage(
                  image: _girlLearner
                      ? 'assets/images/prayer/prayer_intro_girl.png'
                      : 'assets/images/prayer/prayer_intro_boy.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Namazın Temel Bölümleri',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: MinikColors.darkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _teachingNote,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: MinikColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                for (final label in _farzLabels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: MinikColors.green),
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
          ..._stepSections(),
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
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.learnPrayerDuas),
            child: Column(
              children: [
                for (final item in _duaList)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: MinikColors.green, size: 20),
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
            'Namaza Hazırlanalım',
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
                  'Öğrendiklerini Dene!',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bakalım kaç soruyu doğru yapabileceksin?',
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
            'Beş Vakit Namaz',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MinikColors.darkGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sabah, öğle, ikindi, akşam ve yatsı',
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
                  if (i > 0) const Divider(height: 1, color: Color(0xFFE8EEEA)),
                  _RakatRow(item: _rakats[i]),
                ],
              ],
            ),
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

class _PrayerProgressBar extends StatelessWidget {
  const _PrayerProgressBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$done / $total  ·  %${(value * 100).round()} tamamlandı',
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: MinikColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value.clamp(0, 1),
            backgroundColor: const Color(0xFFE0EAE4),
            color: MinikColors.green,
          ),
        ),
      ],
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

class _LearnerToggle extends StatelessWidget {
  const _LearnerToggle({
    required this.girl,
    required this.onChanged,
  });

  final bool girl;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LearnerChip(
            label: 'Erkek',
            selected: !girl,
            onTap: () => onChanged(false),
          ),
          _LearnerChip(
            label: 'Kız',
            selected: girl,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _LearnerChip extends StatelessWidget {
  const _LearnerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? MinikColors.green : Colors.transparent,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : MinikColors.darkGreen,
            ),
          ),
        ),
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
  const _PrayerStepCard({
    required this.step,
    required this.girl,
    required this.onTap,
    required this.learned,
    required this.favorite,
    required this.onToggleFavorite,
  });

  final PrayerVisualStep step;
  final bool girl;
  final VoidCallback onTap;
  final bool learned;
  final bool favorite;
  final VoidCallback onToggleFavorite;

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
                child:
                    Image.asset(step.imageFor(girl: girl), fit: BoxFit.contain),
              ),
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
              Row(
                children: [
                  if (learned)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF3D8B6E),
                    )
                  else
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Color(0xFFC5D4CC),
                    ),
                  if (step.duaIds.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: MinikColors.green,
                    ),
                  ],
                  const Spacer(),
                  InkWell(
                    onTap: onToggleFavorite,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: favorite
                            ? const Color(0xFFC45B7A)
                            : MinikColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class PrayerStepDetailPage extends StatefulWidget {
  const PrayerStepDetailPage({
    super.key,
    required this.step,
    required this.girl,
    this.totalSteps = 0,
  });

  final PrayerVisualStep step;
  final bool girl;
  final int totalSteps;

  @override
  State<PrayerStepDetailPage> createState() => _PrayerStepDetailPageState();
}

class _PrayerStepDetailPageState extends State<PrayerStepDetailPage> {
  final _audio = AudioPlayerService();
  List<PrayerDua> _duas = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDua();
      final store = context.read<LocalProgressStore>();
      final step = widget.step;
      final total = widget.totalSteps > 0
          ? widget.totalSteps
          : PrayerVisualCatalog.steps.length;
      store.markCompleted('prayer', step.id, xp: 1);
      store.setContinue(
        title: 'Namaz Öğren',
        subtitle: '${step.number}/$total',
        route: AppRoutes.learnPrayer,
        progress: (step.number / total).clamp(0.05, 1),
      );
    });
  }

  Future<void> _loadDua() async {
    final ids = widget.step.duaIds;
    if (ids.isEmpty) return;
    final duas = await context.read<ContentRepositories>().duas.getPrayerDuas();
    if (!mounted) return;
    final byId = {for (final dua in duas) dua.id: dua};
    setState(() {
      _duas = [
        for (final id in ids)
          if (byId[id] != null) byId[id]!,
      ];
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _openColoring() {
    final step = widget.step;
    final image = step.imageFor(girl: widget.girl);
    final audioPath = step.duaIds.isEmpty
        ? null
        : ContentAssets.audioFor(step.duaIds.first);
    openImageColoring(
      context,
      image: image,
      title: '${step.title} boya',
      prompt: 'Parmağınla bu namaz adımını boya.',
      audio: audioPath,
      progressKind: 'prayer_color',
      progressId: '${step.id}${widget.girl ? '_girl' : ''}',
      celebrationSubtitle: '${step.title} resmini boyadın.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final audioItems = [
      for (final id in step.duaIds)
        (
          id: id,
          title: _titleFor(id),
          path: ContentAssets.audioFor(id),
        ),
    ].where((item) => AssetCatalog.contains(item.path)).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        title: Text(step.title),
        actions: [
          CopyIconButton(
            text: joinCopyParts([
              step.title,
              step.prompt,
              if (widget.girl) step.girlNote,
              step.caption,
              for (final dua in _duas) ...[
                dua.title,
                dua.displayArabic,
                dua.transliteration,
                dua.displayMeaning,
              ],
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SelectionArea(
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                MinikCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  onTap: _openColoring,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LessonMotionImage(
                        image: step.imageFor(girl: widget.girl),
                        frames: step.motionFramesFor(girl: widget.girl),
                        height: 168,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MinikColors.peach,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.palette_rounded,
                                size: 16,
                                color: MinikColors.darkGreen,
                              ),
                              SizedBox(width: 4),
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(step.prompt, style: Theme.of(context).textTheme.bodyLarge),
                if (widget.girl && step.girlNote.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: MinikColors.blush,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 18,
                          color: Color(0xFFC45B7A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.girlNote,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MinikColors.darkGreen,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _openColoring,
                  icon: const Icon(Icons.palette_rounded),
                  label: const Text('Boya'),
                ),
                if (_duas.isNotEmpty) ...[
                  for (final dua in _duas) ...[
                    const SizedBox(height: 14),
                    DuaContentBlocks(
                      dua: DuaEntry.fromPrayerDua(dua),
                      arabicFontSize: 22,
                    ),
                  ],
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
          ),
          if (audioItems.isNotEmpty)
            Material(
              color: MinikColors.surface,
              elevation: 6,
              shadowColor: const Color(0x14000000),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < audioItems.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        if (audioItems.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                audioItems[i].title,
                                style: const TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: MinikColors.darkGreen,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ListenButton(
                            audio: _audio,
                            path: audioItems[i].path,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _titleFor(String id) {
    for (final dua in _duas) {
      if (dua.id == id) return dua.title;
    }
    switch (id) {
      case 'allahumme_salli':
        return 'Salli';
      case 'allahumme_barik':
        return 'Barik';
      case 'rabbena_atina':
        return 'Rabbenâ Âtinâ';
      case 'rabbena_gfirli':
        return 'Rabbenâğfir Lî';
      case 'rabbena_lekel_hamd':
        return 'Rabbenâ Lekel-Hamd';
      default:
        return widget.step.title;
    }
  }
}
