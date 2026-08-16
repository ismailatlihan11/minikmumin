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
      mushafBookmark: await store.getMushafBookmarkInfo(),
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
                flex: 3,
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
                flex: 8,
                child: ColoredBox(
                  color: const Color(0xFFF4F7F2),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              for (var row = 0; row < 2; row++) ...[
                                if (row > 0) const SizedBox(height: 10),
                                Expanded(
                                  child: Row(
                                    children: [
                                      for (var col = 0; col < 4; col++) ...[
                                        if (col > 0) const SizedBox(width: 10),
                                        Expanded(
                                          child: HomeModuleCard(
                                            module: HomeCatalog.modules[row * 4 + col],
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              HomeCatalog.modules[row * 4 + col].route,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (data.mushafBookmark != null) ...[
                          const SizedBox(height: 8),
                          HomeQuranResumeBar(
                            subtitle:
                                '${TurkishNumber.pageLabel(data.mushafBookmark!.displayNumber)} · ${data.mushafBookmark!.surahLabel}',
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.quranReader,
                              );
                              if (!mounted) return;
                              setState(() => _future = _load(repos, store));
                            },
                          ),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 86,
                          child: Row(
                            children: [
                              for (var i = 0;
                                  i < HomeCatalog.miniActions.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 8),
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
                        const SizedBox(height: 10),
                        HomeContinueCard(
                          title: continueTitle,
                          subtitle: continueSubtitle,
                          progress: progress,
                          onContinue: onContinue,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 92,
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
        child: Column(
          children: [
            Expanded(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Text(
                "Elif ve Oğuzhan'a kocaman sevgilerimle",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: MinikColors.green,
                ),
              ),
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
  });

  final WuduProgress wudu;
  final int wuduStepCount;
  final ContinuePoint? continuePoint;
  final ({int jsonPage, int displayNumber, String surahLabel})? mushafBookmark;
}
