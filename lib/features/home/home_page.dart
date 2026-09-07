import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/home_catalog.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/utils/turkish_number.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/repositories/content_repositories.dart';
import '../zikr/dhikr_store.dart';
import '../zikr/zikr_counter_page.dart';
import 'home_widgets.dart';

class MinikHomePage extends StatefulWidget {
  const MinikHomePage({super.key, this.isCurrentTab = true});

  final bool isCurrentTab;

  @override
  State<MinikHomePage> createState() => _MinikHomePageState();
}

class _MinikHomePageState extends State<MinikHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<_HomeSnapshot>? _future;
  LocalProgressStore? _store;
  Timer? _welcomeTimer;
  bool _welcomeVisible = false;
  bool _welcomeNameLoaded = false;
  String? _welcomeNickname;

  Future<_HomeSnapshot> _load(
    ContentRepositories repos,
    LocalProgressStore store,
  ) async {
    final wudu = await store.getWuduProgress();
    final lesson = await repos.wudu.getLesson();
    final prayerLesson = await repos.prayer.getLesson();
    final completed = await store.getCompletedItems();
    final prayerDone = completed.where((item) => item.startsWith('prayer|')).length;
    final basicsDone = completed.where((item) => item.startsWith('basics|')).length;
    final basics = await repos.basics.load();
    return _HomeSnapshot(
      wudu: wudu,
      wuduStepCount: lesson.steps.length,
      continuePoint: await store.getContinue(),
      mushafBookmark: await store.getMushafBookmarkInfo(),
      prayerCompleted: prayerDone,
      prayerTotal: prayerLesson.visualSteps.length,
      basicsCompleted: basicsDone,
      basicsTotal: basics.items.length,
    );
  }

  void _onProgress() {
    if (!mounted) return;
    final repos = context.read<ContentRepositories>();
    final store = _store;
    if (store == null) return;
    setState(() => _future = _load(repos, store));
  }

  void _hideWelcome() {
    _welcomeTimer?.cancel();
    _welcomeTimer = null;
    if (!mounted || !_welcomeVisible) return;
    setState(() => _welcomeVisible = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isCurrentTab) return;
      setState(() => _welcomeVisible = true);
      _welcomeTimer = Timer(const Duration(seconds: 3), _hideWelcome);
    });
  }

  @override
  void didUpdateWidget(covariant MinikHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrentTab && !widget.isCurrentTab) {
      _hideWelcome();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(store, _store)) {
      _store?.removeListener(_onProgress);
      _store = store;
      _store!.addListener(_onProgress);
    }
    if (!_welcomeNameLoaded) {
      _welcomeNameLoaded = true;
      _loadWelcomeName(store);
    }
  }

  Future<void> _loadWelcomeName(LocalProgressStore store) async {
    final rawName = (await store.getNickname())?.trim();
    if (!mounted) return;
    setState(() {
      _welcomeNickname =
          (rawName == null || rawName.isEmpty) ? null : rawName;
    });
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    _store?.removeListener(_onProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    final store = context.read<LocalProgressStore>();
    _future ??= _load(repos, store);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7F2),
      drawer: _HomeDrawer(onSelect: (route) {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      }),
      body: Stack(
        children: [
          FutureBuilder<_HomeSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ErrorView(
              onRetry: () => setState(() => _future = _load(repos, store)),
            );
          }
          final data = snapshot.data!;
          final fallbackProgress = data.wuduStepCount == 0
              ? 0.0
              : data.wudu.inProgress
                  ? (data.wudu.stepIndex + 1) / data.wuduStepCount
                  : data.wudu.completed
                      ? 1.0
                      : 0.0;
          final point = data.continuePoint;
          final dhikrStore = context.watch<DhikrStore>();
          final pausedDhikr = dhikrStore.paused;
          const continueTitle = 'Öğrenmeye Devam Et';
          var continueSubtitle = point == null
              ? (data.wudu.inProgress
                  ? 'Abdest Öğren – ${data.wudu.stepIndex + 1}/${data.wuduStepCount}'
                  : data.wudu.completed
                      ? 'Namaz Öğren – ${data.prayerCompleted}/${data.prayerTotal}'
                      : 'Abdest Öğren')
              : _continueSubtitle(point, data);
          var continueRoute = point?.route ??
              (data.wudu.completed && !data.wudu.inProgress
                  ? AppRoutes.learnPrayer
                  : AppRoutes.learnWudu);
          var progress = point?.progress ?? fallbackProgress;
          VoidCallback onContinue = () async {
            await Navigator.pushNamed(context, continueRoute);
            if (!mounted) return;
            setState(() => _future = _load(repos, store));
          };
          if (pausedDhikr != null) {
            continueSubtitle =
                '${pausedDhikr.title} ${pausedDhikr.currentCount}/${pausedDhikr.targetCount}';
            progress = pausedDhikr.uiProgress;
            onContinue = () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZikrCounterPage(dhikrId: pausedDhikr.id),
                ),
              );
              if (!mounted) return;
              setState(() => _future = _load(repos, store));
            };
          } else if (data.mushafBookmark != null &&
              (point == null ||
                  point.route == AppRoutes.quranReader ||
                  point.route == AppRoutes.quran)) {
            final mark = data.mushafBookmark!;
            continueSubtitle =
                "Kur'an – ${mark.surahLabel} / ${TurkishNumber.pageLabel(mark.displayNumber)}";
            continueRoute = AppRoutes.quranReader;
            progress = (mark.displayNumber / 604).clamp(0.05, 1);
            onContinue = () async {
              await Navigator.pushNamed(context, AppRoutes.quranReader);
              if (!mounted) return;
              setState(() => _future = _load(repos, store));
            };
          }
          final gridModules =
              HomeCatalog.modules.where((module) => !module.featured).toList();
          final topInset = MediaQuery.paddingOf(context).top;
          return Column(
            children: [
              SizedBox(
                height: topInset + 132,
                child: HomeHeroHeader(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onSettings: () async {
                    await Navigator.pushNamed(context, AppRoutes.settings);
                    if (!mounted) return;
                    setState(() => _future = _load(repos, store));
                  },
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: const Color(0xFFF4F7F2),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HomeBasicsFeaturedCard(
                          completed: data.basicsCompleted,
                          total: data.basicsTotal,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.learnBasics,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gridModules.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final module = gridModules[index];
                          return HomeModuleCard(
                            module: module,
                            onTap: () =>
                                Navigator.pushNamed(context, module.route),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      HomeContinueCard(
                        title: continueTitle,
                        subtitle: continueSubtitle,
                        progress: progress,
                        onContinue: onContinue,
                      ),
                      const SizedBox(height: 10),
                      HomeAdventureCard(
                        onContinue: () => Navigator.pushNamed(
                          context,
                          AppRoutes.dailyTask,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 108,
                        child: Row(
                          children: [
                            for (final item in HomeCatalog.quickItems)
                              Expanded(
                                child: HomeQuickCircle(
                                  item: item,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    item.route,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
          ),
          HomeWelcomeBanner(
            visible: _welcomeVisible,
            nickname: _welcomeNickname,
          ),
        ],
      ),
    );
  }

  String _continueSubtitle(ContinuePoint point, _HomeSnapshot data) {
    if (point.route == AppRoutes.learnPrayer) {
      return 'Namaz Öğren – ${data.prayerCompleted}/${data.prayerTotal}';
    }
    if (point.route == AppRoutes.learnWudu) {
      return 'Abdest Öğren – ${data.wudu.stepIndex + 1}/${data.wuduStepCount}';
    }
    if (point.route == AppRoutes.quranReader || point.route == AppRoutes.quran) {
      final mark = data.mushafBookmark;
      if (mark != null) {
        return "Kur'an – ${mark.surahLabel} / ${TurkishNumber.pageLabel(mark.displayNumber)}";
      }
    }
    if (point.route == AppRoutes.learnQuran) {
      return point.subtitle.isEmpty
          ? "Kur'an Öğreniyorum"
          : "Kur'an Öğren – ${point.subtitle}";
    }
    if (point.route == AppRoutes.learnElifbaAdventure) {
      return point.subtitle.isEmpty
          ? 'Elifbâ + Tecvid Macerası'
          : 'Elifbâ – ${point.subtitle}';
    }
    if (point.subtitle.isEmpty) return point.title;
    return '${point.title} – ${point.subtitle}';
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MinikColors.surface,
      child: SafeArea(
        child: ListView(
          children: [
            const ListTile(
              title: Text(
                AppConstants.defaultAppName,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('İslami Eğitim Uygulaması'),
            ),
            for (final module in HomeCatalog.modules)
              ListTile(
                title: Text(module.title),
                onTap: () => onSelect(module.route),
              ),
            ListTile(
              title: const Text('Favoriler'),
              onTap: () => onSelect(AppRoutes.favorites),
            ),
            ListTile(
              title: const Text('Peygamberler Kitabı'),
              onTap: () => onSelect(AppRoutes.learnProphetsBook),
            ),
            ListTile(
              title: const Text('Ayarlar'),
              onTap: () => onSelect(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSnapshot {
  const _HomeSnapshot({
    required this.wudu,
    required this.wuduStepCount,
    this.continuePoint,
    this.mushafBookmark,
    this.prayerCompleted = 0,
    this.prayerTotal = 25,
    this.basicsCompleted = 0,
    this.basicsTotal = 22,
  });

  final WuduProgress wudu;
  final int wuduStepCount;
  final ContinuePoint? continuePoint;
  final ({int jsonPage, int displayNumber, String surahLabel})? mushafBookmark;
  final int prayerCompleted;
  final int prayerTotal;
  final int basicsCompleted;
  final int basicsTotal;
}
