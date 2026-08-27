import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/quran_learning.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: const Text("Kur'an Öğren")),
      body: AsyncBody<QuranLearningPack>(
        future: _future!,
        errorMessage: "Kur'an Öğren içeriği yüklenemedi.",
        onRetry: () => setState(() => _future = _load()),
        builder: (pack) {
          return FutureBuilder<QuranLearnSnapshot>(
            future: QuranLearnProgress.load(store, pack),
            builder: (context, snapshot) {
              final snap = snapshot.data;
              if (snap == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final percent = (snap.overallRatio * 100).round();
              final daily = snap.dailyLesson();
              return ListView(
                padding: AppSpacing.page,
                children: [
                  MinikCard(
                    color: const Color(0xFFEAF6FF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kur'an Öğreniyorum",
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Harfe dokunup dinle. Harekelerde karelerden alıştırma yap.',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/home/card_quran_learn.png',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seviyem: ${snap.currentLevelId}',
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w800,
                            color: MinikColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        QlSoftProgress(
                          value: snap.overallRatio,
                          label:
                              '%$percent tamamlandı · ${snap.completedLessons} ders',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  MinikCard(
                    color: MinikColors.butter,
                    onTap: () => openQuranLearnDaily(
                      context,
                      pack: pack,
                      lesson: daily,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: MinikColors.gold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bugünün Dersi',
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.w800,
                                  color: MinikColors.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(daily.title),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final level in pack.levels)
                    _LevelCard(
                      level: level,
                      snap: snap,
                      onOpen: snap.isLevelUnlocked(level)
                          ? () => openQuranLearnLevel(
                                context,
                                pack: pack,
                                levelId: level.id,
                              )
                          : null,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.snap,
    required this.onOpen,
  });

  final QuranLearningLevel level;
  final QuranLearnSnapshot snap;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final unlocked = onOpen != null;
    final done = snap.completedCount(level.id);
    final total = snap.totalCount(level.id);
    final complete = snap.isLevelComplete(level.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MinikCard(
        color: complete
            ? MinikColors.mint
            : unlocked
                ? MinikColors.surface
                : const Color(0xFFE8EDE8),
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: MinikColors.pastelAt(level.id),
                  child: Icon(
                    qlLevelIcon(level.id, level.screen),
                    color: MinikColors.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SEVİYE ${level.id}',
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.textMuted,
                        ),
                      ),
                      Text(
                        level.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  complete
                      ? '✓'
                      : unlocked
                          ? '🔓'
                          : '🔒',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(level.description),
            const SizedBox(height: 8),
            QlSoftProgress(
              value: snap.levelRatio(level.id),
              label: '$done / $total',
            ),
            if (unlocked) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  complete ? 'Tekrar Et' : 'Devam Et',
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w800,
                    color: MinikColors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
