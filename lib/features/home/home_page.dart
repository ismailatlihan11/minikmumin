import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/learn_categories.dart';
import '../../app/constants/surah_names.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/app_config.dart';
import '../../data/models/asmaul_husna.dart';
import '../../data/models/dua.dart';
import '../../data/models/hadith.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../asma/asma_page.dart';
import '../duas/duas_page.dart';
import '../hadith/hadith_page.dart';

class MinikHomePage extends StatefulWidget {
  const MinikHomePage({super.key});

  @override
  State<MinikHomePage> createState() => _MinikHomePageState();
}

class _MinikHomePageState extends State<MinikHomePage> {
  Future<_HomeSnapshot>? _future;
  LocalProgressStore? _store;

  Future<_HomeSnapshot> _load(
    ContentRepositories repos,
    LocalProgressStore store,
  ) async {
    late final AppConfig config;
    late final WuduProgress progress;
    QuranVerse? ayah;
    Hadith? hadith;
    Dua? dua;
    AsmaulHusna? asma;
    await Future.wait([
      repos.config.load().then((value) => config = value),
      store.getWuduProgress().then((value) => progress = value),
      repos.quran.getDailyAyah().then((value) => ayah = value),
      repos.hadith.getDaily().then((value) => hadith = value),
      repos.duas.getDaily().then((value) => dua = value),
      repos.asma.getDaily().then((value) => asma = value),
    ]);
    return _HomeSnapshot(
      config: config,
      wudu: progress,
      ayah: ayah,
      hadith: hadith,
      dua: dua,
      asma: asma,
    );
  }

  void _onProgress() {
    if (!mounted) return;
    final repos = context.read<ContentRepositories>();
    final store = _store;
    if (store == null) return;
    setState(() => _future = _load(repos, store));
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
  }

  @override
  void dispose() {
    _store?.removeListener(_onProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    final store = context.read<LocalProgressStore>();
    _future ??= _load(repos, store);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_HomeSnapshot>(
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
            return ListView(
              padding: AppSpacing.page,
              children: [
                Image.asset(
                  'assets/images/logo/app_logo.png',
                  height: 88,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Selam! 👋',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.config.appName} ile bugün birlikte güzel bir şey öğrenelim.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Image.asset(
                  'assets/images/onboarding/onboarding_01.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                if (data.wudu.inProgress) ...[
                  const SizedBox(height: AppSpacing.md),
                  MinikCard(
                    color: MinikColors.sky,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SoftBadge(label: 'Devam Et', color: MinikColors.surface),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Abdest • ${data.wudu.stepIndex + 1}. adım'),
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          label: 'Devam Et',
                          onPressed: () => _openWudu(context, repos, store),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel("Günün hediyeleri"),
                CatalogGrid(
                  children: [
                    CatalogTile(
                      image: 'assets/images/duas/ayet_el_kursi.png',
                      semanticLabel: 'Günün Ayeti',
                      onTap: data.ayah == null
                          ? () {}
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScaffold(
                                    title: '${surahName(data.ayah!.surahId)} ${data.ayah!.ayahNo}',
                                    children: [
                                      ArabicPanel(data.ayah!.arabic),
                                      const SizedBox(height: AppSpacing.md),
                                      Text(data.ayah!.meal),
                                    ],
                                  ),
                                ),
                              ),
                    ),
                    CatalogTile(
                      image: 'assets/images/home/gunun_hadisi.png',
                      semanticLabel: 'Günün Hadisi',
                      onTap: data.hadith == null
                          ? () {}
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HadithDetailPage(hadith: data.hadith!),
                                ),
                              ),
                    ),
                    CatalogTile(
                      image: 'assets/images/home/gunun_duasi.png',
                      semanticLabel: 'Günün Duası',
                      onTap: data.dua == null
                          ? () {}
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DuaDetailPage(
                                    dua: DuaEntry.fromDua(data.dua!),
                                  ),
                                ),
                              ),
                    ),
                    CatalogTile(
                      image: 'assets/images/home/gunun_esmasi.png',
                      semanticLabel: 'Günün Esması',
                      onTap: data.asma == null
                          ? () {}
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AsmaDetailPage(item: data.asma!),
                                ),
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('Haydi öğrenelim'),
                CatalogGrid(
                  children: [
                    for (final category in LearnCategories.all)
                      CatalogTile(
                        image: category.image,
                        semanticLabel: category.title,
                        onTap: () => Navigator.pushNamed(context, category.route),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openWudu(
    BuildContext context,
    ContentRepositories repos,
    LocalProgressStore store,
  ) async {
    await Navigator.pushNamed(context, AppRoutes.learnWudu);
    if (!mounted) return;
    setState(() => _future = _load(repos, store));
  }
}

class _HomeSnapshot {
  const _HomeSnapshot({
    required this.config,
    required this.wudu,
    this.ayah,
    this.hadith,
    this.dua,
    this.asma,
  });

  final AppConfig config;
  final WuduProgress wudu;
  final QuranVerse? ayah;
  final Hadith? hadith;
  final Dua? dua;
  final AsmaulHusna? asma;
}
