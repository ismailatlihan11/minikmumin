import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import 'quran_learn_nav.dart';
import 'quran_learn_progress.dart';
import 'quran_learn_widgets.dart';

class QuranLearnHubPage extends StatefulWidget {
  const QuranLearnHubPage({super.key});

  @override
  State<QuranLearnHubPage> createState() => _QuranLearnHubPageState();
}

class _QuranLearnHubPageState extends State<QuranLearnHubPage> {
  Future<QuranLearningPack>? _future;

  Future<QuranLearningPack> _load() {
    return context.read<ContentRepositories>().quranLearning.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    final store = context.watch<LocalProgressStore>();
    return quranLearnThemed(
      Scaffold(
        backgroundColor: MinikColors.background,
        appBar: AppBar(title: const Text("Kur'an Öğren")),
        body: AsyncBody<QuranLearningPack>(
          future: _future!,
          errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
          onRetry: () => setState(() {
            _future = _load();
          }),
          builder: (pack) {
            return FutureBuilder<QuranLearnSnapshot>(
              future: QuranLearnProgress.load(store, pack),
              builder: (context, snapshot) {
                final snap = snapshot.data;
                if (snap == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final path = [
                  for (final id in elifbaPathIds)
                    if (pack.levelById(id) != null) pack.levelById(id)!,
                ];
                final drills = [
                  for (final id in elifbaDrillIds)
                    if (pack.levelById(id) != null) pack.levelById(id)!,
                ];
                final tajweed = [
                  for (final id in elifbaTajweedIds)
                    if (pack.levelById(id) != null) pack.levelById(id)!,
                ];
                final reading = [
                  for (final id in elifbaReadIds)
                    if (pack.levelById(id) != null) pack.levelById(id)!,
                ];
                final pathDone = path
                    .where((level) => snap.isLevelComplete(level.id))
                    .length;
                return ListView(
                  padding: AppSpacing.page,
                  children: [
                    MinikCard(
                      color: MinikColors.of(
                          const Color(0xFFEAF6FF), const Color(0xFF152938)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kur'an Öğreniyorum",
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Harf, şekil, hareke. Sonra kısa sure.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 10),
                                QlSoftProgress(
                                  value:
                                      path.isEmpty ? 0 : pathDone / path.length,
                                  label: '$pathDone / ${path.length} adım',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: MinikImage.asset(
                              'assets/images/home/card_quran_learn.jpg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < path.length; i++)
                      _PathCard(
                        step: i + 1,
                        level: path[i],
                        snap: snap,
                        onOpen: () => openQuranLearnLevel(
                          context,
                          pack: pack,
                          levelId: path[i].id,
                        ),
                      ),
                    if (drills.isNotEmpty)
                      _HubFold(
                        title: 'Alıştırma',
                        subtitle: 'Birleştir, oku, ayırt, oyna',
                        children: [
                          for (final level in drills)
                            _LaterCard(
                              level: level,
                              snap: snap,
                              onOpen: () => openQuranLearnLevel(
                                context,
                                pack: pack,
                                levelId: level.id,
                              ),
                            ),
                        ],
                      ),
                    if (tajweed.isNotEmpty)
                      _HubFold(
                        title: 'Tecvid',
                        subtitle: 'Kuralları ayette gör',
                        children: [
                          for (final level in tajweed)
                            _LaterCard(
                              level: level,
                              snap: snap,
                              onOpen: () => openQuranLearnLevel(
                                context,
                                pack: pack,
                                levelId: level.id,
                              ),
                            ),
                        ],
                      ),
                    if (reading.isNotEmpty)
                      _HubFold(
                        title: 'Okuma pratiği',
                        subtitle: 'Ayet ve sure oku',
                        children: [
                          for (final level in reading)
                            _LaterCard(
                              level: level,
                              snap: snap,
                              onOpen: () => openQuranLearnLevel(
                                context,
                                pack: pack,
                                levelId: level.id,
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HubFold extends StatelessWidget {
  const _HubFold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w800,
              color: MinikColors.textMuted,
            ),
          ),
          subtitle: Text(subtitle),
          children: children,
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.step,
    required this.level,
    required this.snap,
    required this.onOpen,
  });

  final int step;
  final QuranLearningLevel level;
  final QuranLearnSnapshot snap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final done = snap.completedCount(level.id);
    final total = snap.totalCount(level.id);
    final complete = snap.isLevelComplete(level.id);
    final first = step == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MinikCard(
        color: complete
            ? MinikColors.mint
            : first
                ? MinikColors.surface
                : MinikColors.of(
                    const Color(0xFFF7F4EE), const Color(0xFF2E2A21)),
        onTap: onOpen,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: MinikColors.pastelAt(step),
              child: Text(
                '$step',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elifbaStepTitle(level),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    elifbaStepCue(level),
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 13,
                      color: MinikColors.textMuted,
                    ),
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 6),
                    QlSoftProgress(
                      value: snap.levelRatio(level.id),
                      label: '$done / $total',
                    ),
                  ],
                ],
              ),
            ),
            Text(
              complete
                  ? '✓'
                  : first
                      ? 'Başla'
                      : 'Aç',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w800,
                color: MinikColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaterCard extends StatelessWidget {
  const _LaterCard({
    required this.level,
    required this.snap,
    required this.onOpen,
  });

  final QuranLearningLevel level;
  final QuranLearnSnapshot snap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MinikCard(
        color: MinikColors.of(const Color(0xFFE8EDE8), const Color(0xFF292E29)),
        onTap: onOpen,
        child: Row(
          children: [
            Icon(qlLevelIcon(level.id, level.screen),
                color: MinikColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elifbaStepTitle(level),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    elifbaStepCue(level),
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 13,
                      color: MinikColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              snap.isLevelComplete(level.id) ? '✓' : 'Aç',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w800,
                color: MinikColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
