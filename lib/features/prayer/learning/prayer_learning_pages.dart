import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/constants/content_assets.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/audio/asset_catalog.dart';
import '../../../core/audio/audio_player_service.dart';
import '../../../core/storage/local_progress_store.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/dua.dart';
import '../../../data/repositories/content_repositories.dart';
import '../../../shared/widgets/lesson_motion_image.dart';
import '../../../shared/widgets/minik_image.dart';
import '../../../shared/widgets/minik_ui.dart';
import '../../duas/duas_page.dart';
import '../prayer_visual_catalog.dart';
import 'prayer_learning_models.dart';

const _progressKind = 'prayer_plan';

String _trUpper(String text) =>
    text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

Color get _pageBackground =>
    MinikColors.of(const Color(0xFFF3F6F8), const Color(0xFF21272A));

Color _typeColor(String type) {
  switch (type) {
    case 'farz':
      return MinikColors.green;
    case 'vacip':
      return const Color(0xFF7B5EA7);
    default:
      return const Color(0xFFE0A21A);
  }
}

TextStyle _text(double size,
        {FontWeight weight = FontWeight.w700, Color? color}) =>
    TextStyle(
      fontFamily: 'NotoSans',
      fontSize: size,
      fontWeight: weight,
      height: 1.35,
      color: color ?? MinikColors.darkGreen,
    );

/// Namaz seçimi: vakitlere göre gruplanmış namaz listesi.
class PrayerPlanListPage extends StatefulWidget {
  const PrayerPlanListPage({super.key});

  @override
  State<PrayerPlanListPage> createState() => _PrayerPlanListPageState();
}

class _PrayerPlanListPageState extends State<PrayerPlanListPage> {
  late Future<PrayerLearningData> _data;
  Set<String> _done = {};
  LocalProgressStore? _store;

  @override
  void initState() {
    super.initState();
    _data = PrayerLearningData.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(store, _store)) {
      _store?.removeListener(_loadDone);
      _store = store..addListener(_loadDone);
      _loadDone();
    }
  }

  @override
  void dispose() {
    _store?.removeListener(_loadDone);
    super.dispose();
  }

  Future<void> _loadDone() async {
    final items = await _store?.getCompletedItems() ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _done = {
        for (final item in items)
          if (item.startsWith('$_progressKind|'))
            item.substring(_progressKind.length + 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(title: const Text('Namaz Öğren')),
      body: FutureBuilder<PrayerLearningData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const ErrorView();
          final data = snapshot.data;
          if (data == null) return const LoadingView();
          final done =
              data.prayers.where((prayer) => _done.contains(prayer.id)).length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(
                'Hangi namazı öğrenmek istersin?',
                textAlign: TextAlign.center,
                style: _text(18, weight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Bir namaz seç, rekât rekât birlikte kılalım.',
                textAlign: TextAlign.center,
                style: _text(13,
                    weight: FontWeight.w600, color: MinikColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProgressLine(done: done, total: data.prayers.length),
              for (final group in data.groups) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _trUpper(group.title),
                  style: _text(15, weight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final prayer in data.inGroup(group.id))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _PrayerTile(
                      emoji: group.emoji,
                      prayer: prayer,
                      learned: _done.contains(prayer.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrayerPlanIntroPage(
                            data: data,
                            prayer: prayer,
                            emoji: group.emoji,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$done / $total namaz öğrenildi',
          style: _text(12, color: MinikColors.textMuted),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value,
            backgroundColor: MinikColors.border,
            color: MinikColors.green,
          ),
        ),
      ],
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.emoji,
    required this.prayer,
    required this.learned,
    required this.onTap,
  });

  final String emoji;
  final PrayerPlan prayer;
  final bool learned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(prayer.type);
    return Material(
      color: MinikColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${prayer.shortName} — ${prayer.rakats} Rekât',
                      style: _text(15, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    _Chip(label: prayer.typeLabel, color: color),
                  ],
                ),
              ),
              Icon(
                learned
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: learned ? MinikColors.greenSoft : MinikColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
      ),
      child:
          Text(label, style: _text(11, weight: FontWeight.w800, color: color)),
    );
  }
}

/// Seçilen namazın kısa bilgi kartı ve [Başla] butonu.
class PrayerPlanIntroPage extends StatelessWidget {
  const PrayerPlanIntroPage({
    super.key,
    required this.data,
    required this.prayer,
    this.emoji = '',
  });

  final PrayerLearningData data;
  final PrayerPlan prayer;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(prayer.type);
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(title: Text(prayer.shortName)),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          MinikCard(
            color: MinikColors.butter,
            child: Column(
              children: [
                if (emoji.isNotEmpty)
                  Text(emoji, style: const TextStyle(fontSize: 44)),
                Text(prayer.name,
                    textAlign: TextAlign.center,
                    style: _text(24, weight: FontWeight.w800)),
                Text(prayer.part,
                    textAlign: TextAlign.center,
                    style: _text(17, weight: FontWeight.w800, color: color)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '“${prayer.intro}”',
                  textAlign: TextAlign.center,
                  style: _text(15, weight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                _Chip(label: prayer.notice, color: color),
              ],
            ),
          ),
          for (final info in prayer.info) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoBox(text: info),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('Rekâtlar', style: _text(15, weight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          for (final rakah in prayer.rakahs)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: MinikCard(
                color: MinikColors.card,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${rakah.number}. Rekât',
                        style: _text(14, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        for (final id in rakah.steps)
                          if (data.steps[id] != null)
                            '${data.steps[id]!.emoji} ${data.steps[id]!.title}',
                      ].join('  ·  '),
                      style: _text(12,
                          weight: FontWeight.w600,
                          color: MinikColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerPlanFlowPage(data: data, prayer: prayer),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: MinikColors.green,
              minimumSize: const Size.fromHeight(54),
              textStyle: _text(17, weight: FontWeight.w800),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Başla'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text, this.icon = '💡'});

  final String text;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: MinikColors.sky,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: _text(13))),
        ],
      ),
    );
  }
}

/// Rekât rekât, adım adım namaz eğitimi.
class PrayerPlanFlowPage extends StatefulWidget {
  const PrayerPlanFlowPage({
    super.key,
    required this.data,
    required this.prayer,
  });

  final PrayerLearningData data;
  final PrayerPlan prayer;

  @override
  State<PrayerPlanFlowPage> createState() => _PrayerPlanFlowPageState();
}

class _PrayerPlanFlowPageState extends State<PrayerPlanFlowPage> {
  final _audio = AudioPlayerService();
  late final List<PrayerFlowItem> _items = widget.data.flow(widget.prayer);
  final Map<String, PrayerVisualStep> _visuals = {
    for (final step in PrayerVisualCatalog.steps) step.id: step,
  };
  Map<String, PrayerDua> _duas = const {};
  var _index = 0;
  var _selfRead = false;
  var _finished = false;
  var _girl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final store = context.read<LocalProgressStore>();
    final duas = await context.read<ContentRepositories>().duas.getPrayerDuas();
    final girl = await store.getPrayerGirlLearner();
    if (!mounted) return;
    setState(() {
      _duas = {for (final dua in duas) dua.id: dua};
      _girl = girl;
    });
    await store.setContinue(
      title: 'Namaz Öğren',
      subtitle: widget.prayer.shortName,
      route: AppRoutes.learnPrayer,
      progress: 0.05,
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _go(int delta) {
    _audio.stop();
    final next = _index + delta;
    if (next >= _items.length) {
      _finish();
      return;
    }
    if (next < 0) return;
    setState(() {
      _index = next;
      _selfRead = false;
    });
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    await context
        .read<LocalProgressStore>()
        .markCompleted(_progressKind, widget.prayer.id, xp: 5);
  }

  void _restart() {
    setState(() {
      _index = 0;
      _finished = false;
      _selfRead = false;
    });
  }

  void _showHowTo(PrayerFlowItem item) {
    final visual = _visuals[item.step.visual];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ne yapacağım?', style: _text(18, weight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.xs),
              Text(item.step.how, style: _text(15, weight: FontWeight.w600)),
              if (_girl && (visual?.girlNote.isNotEmpty ?? false)) ...[
                const SizedBox(height: AppSpacing.sm),
                _InfoBox(text: visual!.girlNote, icon: '🌸'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(title: Text(prayer.shortName)),
      body: _items.isEmpty
          ? const ErrorView(message: 'Bu namazın adımları bulunamadı.')
          : _finished
              ? _DoneView(
                  prayer: prayer,
                  girl: _girl,
                  onRestart: _restart,
                  onClose: () => Navigator.pop(context),
                )
              : _buildStep(_items[_index]),
    );
  }

  Widget _buildStep(PrayerFlowItem item) {
    final prayer = widget.prayer;
    final step = item.step;
    final visual = _visuals[step.visual];
    final rakahSteps =
        _items.where((other) => other.rakah == item.rakah).length;
    final duas = [
      for (final id in item.duaIds)
        if (_duas[id] != null) _duas[id]!,
    ];
    final audios = [
      for (final id in item.duaIds) (id: id, path: ContentAssets.audioFor(id)),
    ].where((audio) => AssetCatalog.contains(audio.path)).toList();
    final surahTitle = item.surahNumber == null
        ? null
        : _duas['surah_${item.surahNumber}']?.title;
    final isLast = _index == _items.length - 1;
    return Column(
      children: [
        _RakahHeader(
          rakah: item.rakah.number,
          total: prayer.rakats,
          stepNo: item.indexInRakah + 1,
          stepTotal: rakahSteps,
          notice: prayer.notice,
          color: _typeColor(prayer.type),
        ),
        Expanded(
          child: SelectionArea(
            child: ListView(
              key: ValueKey(_index),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                if (item.opensRakah && item.rakah.banner.isNotEmpty) ...[
                  _RakahBanner(lines: item.rakah.banner),
                  const SizedBox(height: AppSpacing.sm),
                ],
                MinikCard(
                  color: MinikColors.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(step.emoji,
                              style: const TextStyle(fontSize: 30)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              surahTitle == null
                                  ? step.title
                                  : '${step.title} · $surahTitle',
                              style: _text(20, weight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      if (visual != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        LessonMotionImage(
                          image: visual.imageFor(girl: _girl),
                          frames: visual.motionFramesFor(girl: _girl),
                          height: 170,
                          width: double.infinity,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        surahTitle == null
                            ? step.say
                            : '${step.say} Bu rekâtta ${surahTitle}ni okuyalım.',
                        style: _text(17, weight: FontWeight.w700),
                      ),
                      if (step.id == 'niyet') ...[
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MinikColors.butter,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '“${prayer.niyet}”',
                            style: _text(15, weight: FontWeight.w800),
                          ),
                        ),
                      ],
                      if (step.caption.isNotEmpty && duas.isEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(step.caption,
                            style: _text(16,
                                weight: FontWeight.w800,
                                color: MinikColors.green)),
                      ],
                    ],
                  ),
                ),
                for (final tip in item.tips) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _InfoBox(text: tip),
                ],
                for (final why in item.whys) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _WhyCard(why: why),
                ],
                const SizedBox(height: AppSpacing.sm),
                for (final audio in audios) ...[
                  if (audios.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _duas[audio.id]?.title ?? step.title,
                        style: _text(12, weight: FontWeight.w800),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ListenButton(
                      audio: _audio,
                      path: audio.path,
                      repeat: _duas[audio.id]?.repeat ?? 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Row(
                  children: [
                    if (duas.isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _selfRead = !_selfRead),
                          icon: Icon(_selfRead
                              ? Icons.visibility_rounded
                              : Icons.record_voice_over_rounded),
                          label:
                              Text(_selfRead ? 'Metni göster' : 'Ben okuyayım'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showHowTo(item),
                        icon: const Icon(Icons.help_outline_rounded),
                        label: const Text('Ne yapacağım?'),
                      ),
                    ),
                  ],
                ),
                if (_selfRead)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: MinikCard(
                      color: MinikColors.mint,
                      child: Column(
                        children: [
                          const Text('🎤', style: TextStyle(fontSize: 36)),
                          Text('Sıra sende!',
                              style: _text(18, weight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            'Ezberinden oku. Bitince “Metni göster” ile kontrol et.',
                            textAlign: TextAlign.center,
                            style: _text(14, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final dua in duas) ...[
                    const SizedBox(height: AppSpacing.sm),
                    DuaContentBlocks(
                      dua: DuaEntry.fromPrayerDua(dua),
                      arabicFontSize: 22,
                    ),
                  ],
              ],
            ),
          ),
        ),
        Material(
          color: MinikColors.surface,
          elevation: 6,
          shadowColor: const Color(0x14000000),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0 ? null : () => _go(-1),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _go(1),
                      style: FilledButton.styleFrom(
                        backgroundColor: MinikColors.green,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: Icon(isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded),
                      label: Text(isLast ? 'Bitir' : 'İleri'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RakahHeader extends StatelessWidget {
  const _RakahHeader({
    required this.rakah,
    required this.total,
    required this.stepNo,
    required this.stepTotal,
    required this.notice,
    required this.color,
  });

  final int rakah;
  final int total;
  final int stepNo;
  final int stepTotal;
  final String notice;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: MinikColors.card,
      child: Column(
        children: [
          Text('$rakah. REKÂT', style: _text(28, weight: FontWeight.w900)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= total; i++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= rakah ? MinikColors.green : Colors.transparent,
                    border: Border.all(color: MinikColors.green, width: 2),
                  ),
                ),
              const SizedBox(width: 8),
              Text('$rakah / $total Rekât',
                  style: _text(13, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Chip(label: notice, color: color),
              const Spacer(),
              Text('Adım $stepNo / $stepTotal',
                  style: _text(12, color: MinikColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: stepTotal == 0 ? 0 : stepNo / stepTotal,
              backgroundColor: MinikColors.border,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RakahBanner extends StatelessWidget {
  const _RakahBanner({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return MinikCard(
      color: MinikColors.peach,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lines.first, style: _text(19, weight: FontWeight.w900)),
          for (final line in lines.skip(1)) ...[
            const SizedBox(height: 4),
            Text(line, style: _text(15, weight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

class _WhyCard extends StatefulWidget {
  const _WhyCard({required this.why});

  final PrayerStepWhy why;

  @override
  State<_WhyCard> createState() => _WhyCardState();
}

class _WhyCardState extends State<_WhyCard> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MinikColors.lavender,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('❓', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.why.question,
                        style: _text(14, weight: FontWeight.w800)),
                  ),
                  Icon(_open
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 6),
                Text(widget.why.answer, style: _text(13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({
    required this.prayer,
    required this.girl,
    required this.onRestart,
    required this.onClose,
  });

  final PrayerPlan prayer;
  final bool girl;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.page,
      children: [
        const SizedBox(height: AppSpacing.md),
        MinikImage.asset(
          girl
              ? 'assets/images/prayer/step16_tamam_girl.jpg'
              : 'assets/images/prayer/step16_tamam.jpg',
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Namaz tamamlandı.',
            textAlign: TextAlign.center,
            style: _text(24, weight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          'Maşallah! ${prayer.name} · ${prayer.part} bitti.',
          textAlign: TextAlign.center,
          style: _text(15, weight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onClose,
          style: FilledButton.styleFrom(
            backgroundColor: MinikColors.green,
            minimumSize: const Size.fromHeight(50),
          ),
          icon: const Icon(Icons.list_rounded),
          label: const Text('Başka namaz seç'),
        ),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          onPressed: onRestart,
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Baştan tekrar et'),
        ),
      ],
    );
  }
}
