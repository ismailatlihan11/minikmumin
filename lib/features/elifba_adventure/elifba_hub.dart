import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/repositories/content_repositories.dart';
import '../../features/quran_learn/quran_learn_hub.dart';
import '../../features/quran_learn/quran_learn_theme.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import 'elifba_flag.dart';
import 'elifba_lesson.dart';
import 'elifba_models.dart';
import 'elifba_progress.dart';
import 'elifba_widgets.dart';
import 'elifba_worlds.dart';

Future<void> openElifbaLesson(
  BuildContext context, {
  required ElifbaPack pack,
  required ElifbaLesson lesson,
  bool replay = false,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ElifbaIntroPage(
        pack: pack,
        lesson: lesson,
        replay: replay,
      ),
    ),
  );
}

class ElifbaChooserPage extends StatelessWidget {
  const ElifbaChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ContentRepositories>().config.load(),
      builder: (context, snapshot) {
        final enabled = ElifbaFlags.isEnabled(snapshot.data);
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!enabled) return const QuranLearnHubPage();
        return quranLearnThemed(
          Scaffold(
          appBar: AppBar(title: const Text("Kur'an Öğren")),
          body: ListView(
            padding: AppSpacing.page,
            children: [
              ElifbaSoftCard(
                color: MinikColors.sky,
                onTap: () => Navigator.push(
                  context,
                  quranLearnRoute(const QuranLearnHubPage()),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 Kur’an Öğrenme Serisi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mevcut Elifba yolu. Harf, hareke, kısa sure.',
                      style: TextStyle(color: MinikColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElifbaSoftCard(
                color: MinikColors.mint,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.learnElifbaAdventure,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌟 Elifbâ + Tecvid Macerası',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: MinikColors.darkGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'YENİ / DENEME  ·  Eğlenerek, oynayarak öğren.',
                      style: TextStyle(color: MinikColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class ElifbaHubPage extends StatefulWidget {
  const ElifbaHubPage({super.key});

  @override
  State<ElifbaHubPage> createState() => _ElifbaHubPageState();
}

class _ElifbaHubPageState extends State<ElifbaHubPage> {
  Future<ElifbaPack>? _future;

  Future<ElifbaPack> _load() {
    return context.read<ContentRepositories>().elifba.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    final store = context.watch<LocalProgressStore>();
    return FutureBuilder(
      future: context.read<ContentRepositories>().config.load(),
      builder: (context, flagSnap) {
        if (ElifbaFlags.isEnabled(flagSnap.data) == false &&
            flagSnap.connectionState == ConnectionState.done) {
          return const QuranLearnHubPage();
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F2),
          appBar: AppBar(
            title: const Text('Elifbâ + Tecvid Macerası'),
            actions: [
              if (kDebugMode)
                IconButton(
                  tooltip: 'Debug',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ElifbaDebugPage(),
                    ),
                  ),
                  icon: const Icon(Icons.bug_report_outlined),
                ),
            ],
          ),
          body: AsyncBody<ElifbaPack>(
            future: _future!,
            errorMessage: 'Elifbâ macerası yüklenemedi.',
            onRetry: () => setState(() => _future = _load()),
            builder: (pack) {
              return FutureBuilder<ElifbaSnapshot>(
                future: ElifbaProgress(store).load(),
                builder: (context, snap) {
                  final progress = snap.data;
                  if (progress == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _HubBody(pack: pack, progress: progress);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({required this.pack, required this.progress});

  final ElifbaPack pack;
  final ElifbaSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final resume = pack.resumeFrom(progress.currentLesson);
    final unlocked =
        progress.isUnlockedIn(pack, resume.id) || progress.isCompleted(resume.id);
    return ListView(
      padding: AppSpacing.page,
      children: [
        ElifbaSoftCard(
          color: MinikColors.sky,
          child: Column(
            children: [
              Image.asset(
                elifbaMascotAsset,
                height: 96,
                errorBuilder: (_, __, ___) =>
                    const Text('🐰', style: TextStyle(fontSize: 56)),
              ),
              const SizedBox(height: 8),
              Text(
                pack.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Text('Kur’an okumayı adım adım ve eğlenerek öğren.'),
              const SizedBox(height: 10),
              ElifbaMascot(
                line: progress.doneCount == 0
                    ? ElifbaVoice.greetings.first
                    : ElifbaVoice.greetings[1],
              ),
              const SizedBox(height: 12),
              Text(
                '${progress.doneCount} / ${pack.lessons.length} Ders',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '%${(progress.ratio(pack.lessons.length) * 100).round()} Tamamlandı',
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: progress.ratio(pack.lessons.length),
                  color: MinikColors.gold,
                  backgroundColor: MinikColors.creamDark,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  Text('⭐ ${progress.stars}'),
                  Text('🏅 ${progress.badges.length}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElifbaSoftCard(
          color: MinikColors.peach,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎯 Bugünkü Hedef'),
              Text(
                progress.dailyDone
                    ? 'Bugünkü hedefini tamamladın!'
                    : 'Bugün 1 ders tamamla.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElifbaSoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('👣 Kaldığın Yer'),
              Text('Ders ${pack.orderOf(resume.id)} – ${resume.title}'),
              Text('${resume.level} · ${ElifbaWorlds.forLesson(pack, resume.id).title}'),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Kaldığın Yerden Devam Et',
                onPressed: unlocked
                    ? () => openElifbaLesson(
                          context,
                          pack: pack,
                          lesson: resume,
                          replay: progress.isCompleted(resume.id),
                        )
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Ders Haritası',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ElifbaMapPage(pack: pack, progress: progress),
            ),
          ),
        ),
        if (progress.badges.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Rozetler', style: Theme.of(context).textTheme.headlineMedium),
          Wrap(
            spacing: 8,
            children: [
              for (final badge in progress.badges)
                Chip(
                  label: Text('🏅 $badge'),
                  backgroundColor: MinikColors.butter,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class ElifbaMapPage extends StatelessWidget {
  const ElifbaMapPage({
    super.key,
    required this.pack,
    required this.progress,
  });

  final ElifbaPack pack;
  final ElifbaSnapshot progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Macera Haritası')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          for (final world in ElifbaWorlds.of(pack))
            _WorldBlock(
              world: world,
              pack: pack,
              progress: progress,
            ),
        ],
      ),
    );
  }
}

class _WorldBlock extends StatelessWidget {
  const _WorldBlock({
    required this.world,
    required this.pack,
    required this.progress,
  });

  final ElifbaWorld world;
  final ElifbaPack pack;
  final ElifbaSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final lessons = world.lessons;
    if (lessons.isEmpty) return const SizedBox.shrink();
    final complete = world.isComplete(progress.completedLessons);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElifbaSoftCard(
        color: world.color,
        child: Column(
          children: [
            Text(
              '${world.emoji} ${world.title}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (complete) Text('🏅 ${world.badge} kazandın!'),
            const SizedBox(height: 8),
            for (var i = 0; i < lessons.length; i++) ...[
              _LessonNode(
                lesson: lessons[i],
                pack: pack,
                progress: progress,
              ),
              if (i < lessons.length - 1)
                Icon(Icons.arrow_downward_rounded, color: MinikColors.gold),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.lesson,
    required this.pack,
    required this.progress,
  });

  final ElifbaLesson lesson;
  final ElifbaPack pack;
  final ElifbaSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final done = progress.isCompleted(lesson.id);
    final inProgress = progress.isInProgress(lesson.id);
    final open = progress.isUnlockedIn(pack, lesson.id) || done;
    final status = done
        ? '✅ Tamamlandı'
        : inProgress
            ? '▶ Devam ediyor'
            : open
                ? '▶ Başla'
                : '🔒 Kilitli';
    final quizScore = progress.quizResults['${lesson.id}'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElifbaSoftCard(
        onTap: open
            ? () => openElifbaLesson(
                  context,
                  pack: pack,
                  lesson: lesson,
                  replay: done,
                )
            : null,
        child: Opacity(
          opacity: open ? 1 : 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ders ${pack.orderOf(lesson.id)} · ${lesson.title}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Text(status),
                ],
              ),
              Text(lesson.level),
              if (lesson.goal.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(lesson.goal),
                ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: done ? 1 : (inProgress ? 0.5 : 0),
                  color: MinikColors.green,
                  backgroundColor: MinikColors.creamDark,
                ),
              ),
              if (done && quizScore != null && lesson.quiz.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '🎯 $quizScore / ${lesson.quiz.length} doğru · 🔁 Tekrar Et',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElifbaDebugPage extends StatelessWidget {
  const ElifbaDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(body: Center(child: Text('Yok')));
    }
    final progress = ElifbaProgress(context.read<LocalProgressStore>());
    final audio = AudioPlayerService();
    return Scaffold(
      appBar: AppBar(title: const Text('Elifbâ Debug')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ListTile(
            title: const Text('Tüm dersleri aç'),
            onTap: () async {
              await progress.setUnlockAll(true);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Progress sıfırla'),
            onTap: () async {
              await progress.reset();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Yıldız ekle'),
            onTap: () => progress.addStars(3),
          ),
          ListTile(
            title: const Text('Rozet ver'),
            onTap: () => progress.grantBadge('Elifbâ Kahramanı'),
          ),
          ListTile(
            title: const Text('Finali aç'),
            onTap: () async {
              await progress.setUnlockAll(true);
              await progress.setCurrent(30);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Sesleri test et'),
            onTap: () => audio.playAsset(
              'assets/audio/quran_learn/alphabet/ba.mp3',
              waitUntilDone: false,
            ),
          ),
        ],
      ),
    );
  }
}
