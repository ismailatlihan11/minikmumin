import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/home_catalog.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
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
  final _welcomeAudio = AudioPlayerService();
  bool _welcomeVisible = false;
  bool _welcomeNameLoaded = false;
  String? _welcomeNickname;
  bool _firstLaunchVisible = false;
  bool _firstLaunchChecked = false;
  String _firstLaunchTitle = 'Haydi başlayalım';
  String _firstLaunchButton = 'Anladım';
  List<String> _firstLaunchLines = const [
    'Ana Sayfa’dan derslere geçersin.',
    'Öğren’de abdest, namaz ve dualar var.',
    'Kur’an sekmesinde sureleri okuyup dinlersin.',
  ];

  Future<_HomeSnapshot> _load(
    ContentRepositories repos,
    LocalProgressStore store,
  ) async {
    final wudu = await store.getWuduProgress();
    final lesson = await repos.wudu.getLesson();
    return _HomeSnapshot(
      wudu: wudu,
      wuduStepCount: lesson.steps.length,
      continuePoint: await store.getContinue(),
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
    _welcomeAudio.stop();
    if (!mounted || !_welcomeVisible) return;
    setState(() => _welcomeVisible = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isCurrentTab) return;
      setState(() => _welcomeVisible = true);
      _welcomeAudio.playAsset('assets/audio/effects/hosgeldin.mp3');
      _welcomeTimer = Timer(const Duration(seconds: 10), _hideWelcome);
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
    if (!_firstLaunchChecked) {
      _firstLaunchChecked = true;
      _loadFirstLaunch(store);
    }
  }

  Future<void> _loadFirstLaunch(LocalProgressStore store) async {
    final done = await store.getOnboardingDone();
    if (!mounted) return;
    if (done) return;
    try {
      final config = await context.read<ContentRepositories>().config.load();
      if (!mounted) return;
      setState(() {
        _firstLaunchVisible = true;
        if (config.firstLaunchTitle.isNotEmpty) {
          _firstLaunchTitle = config.firstLaunchTitle;
        }
        if (config.firstLaunchButton.isNotEmpty) {
          _firstLaunchButton = config.firstLaunchButton;
        }
        if (config.firstLaunchLines.isNotEmpty) {
          _firstLaunchLines = config.firstLaunchLines;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _firstLaunchVisible = true);
    }
  }

  Future<void> _dismissFirstLaunch() async {
    await _store?.setOnboardingDone();
    if (!mounted) return;
    setState(() => _firstLaunchVisible = false);
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
    _welcomeAudio.dispose();
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
          var continueTitle = 'Öğrenmeye Devam Et';
          var continueSubtitle = point == null
              ? (data.wudu.inProgress
                  ? 'Abdest: ${data.wudu.stepIndex + 1}. adım'
                  : data.wudu.completed
                      ? 'Namazı Öğren'
                      : 'Abdesti Öğren')
              : (point.subtitle.isEmpty
                  ? point.title
                  : '${point.title} · ${point.subtitle}');
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
            continueTitle = 'Zikrine devam et';
            continueSubtitle =
                '${pausedDhikr.title} ${pausedDhikr.currentCount} / ${pausedDhikr.targetCount}';
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
          }
          return Column(
            children: [
              Expanded(
                child: HomeHeroHeader(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onSettings: () async {
                    await Navigator.pushNamed(context, AppRoutes.settings);
                    if (!mounted) return;
                    setState(() => _future = _load(repos, store));
                  },
                ),
              ),
              ColoredBox(
                color: const Color(0xFFF4F7F2),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 4;
                      const rows = 2;
                      const gridGap = 8.0;
                      const restGap = 8.0;
                      const miniHeight = 56.0;
                      const circlesHeight = 64.0;
                      final itemWidth =
                          (constraints.maxWidth - gridGap * (columns - 1)) /
                              columns;
                      final halfHeight = itemWidth * 0.68;
                      final gridHeight =
                          halfHeight * rows + gridGap * (rows - 1);
                      final itemHeight = halfHeight.clamp(1.0, 400.0);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: gridHeight,
                            child: GridView.count(
                              crossAxisCount: columns,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: gridGap,
                              crossAxisSpacing: gridGap,
                              childAspectRatio: itemWidth / itemHeight,
                              children: [
                                for (final module in HomeCatalog.modules)
                                  HomeModuleCard(
                                    module: module,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      module.route,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: restGap),
                          SizedBox(
                            height: miniHeight,
                            child: Row(
                              children: [
                                for (var i = 0;
                                    i < HomeCatalog.miniActions.length;
                                    i++) ...[
                                  if (i > 0) const SizedBox(width: 6),
                                  Expanded(
                                    child: HomeMiniCard(
                                      item: HomeCatalog.miniActions[i],
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        HomeCatalog.miniActions[i].route,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: restGap),
                          HomeContinueCard(
                            title: continueTitle,
                            subtitle: continueSubtitle,
                            progress: progress,
                            onContinue: onContinue,
                          ),
                          const SizedBox(height: restGap),
                          SizedBox(
                            height: circlesHeight,
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
                      );
                    },
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
          HomeFirstLaunchHint(
            visible: _firstLaunchVisible,
            title: _firstLaunchTitle,
            lines: _firstLaunchLines,
            buttonLabel: _firstLaunchButton,
            onDismiss: _dismissFirstLaunch,
          ),
        ],
      ),
    );
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
                'Minik Kalpler',
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
  });

  final WuduProgress wudu;
  final int wuduStepCount;
  final ContinuePoint? continuePoint;
}
