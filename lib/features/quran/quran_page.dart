import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/surah_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/progress.dart';
import '../../data/models/quran_verse.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikQuranPage extends StatefulWidget {
  const MinikQuranPage({super.key});

  @override
  State<MinikQuranPage> createState() => _MinikQuranPageState();
}

class _MinikQuranPageState extends State<MinikQuranPage> {
  Future<_QuranHome>? _future;

  Future<_QuranHome> _load() async {
    final repos = context.read<ContentRepositories>();
    return _QuranHome(
      kursi: await repos.quran.getAyetulKursi(),
      lastTen: await repos.quran.getLastTenAyahs(),
      surahs: await repos.quran.getSurahIndex(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<_QuranHome>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (data) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: "Kur'an",
                subtitle: 'Ayetleri oku, sureleri keşfet.',
                image: 'assets/images/quran/quran.png',
              ),
              SizedBox(
                height: 220,
                child: CatalogTile(
                  image: 'assets/images/duas/ayet_el_kursi.png',
                  semanticLabel: data.kursi.title,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _SimpleAyahPage(
                        title: data.kursi.title,
                        arabic: data.kursi.arabic,
                        meaning: data.kursi.meaning,
                        source: '${data.kursi.sourceName} • ${data.kursi.sourceReference}',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionLabel('Felak ve Nâs'),
              ...data.lastTen.map(
                (ayah) => ContentTile(
                  title: '${ayah.surahName} ${ayah.ayah}',
                  subtitle: ayah.meaning,
                  leading: NumberBadge('${ayah.ayah}', color: MinikColors.butter),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _SimpleAyahPage(
                        title: '${ayah.surahName} ${ayah.ayah}',
                        arabic: ayah.arabic,
                        meaning: ayah.meaning,
                        source: "Kur'an-ı Kerim",
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const SectionLabel('Sureler'),
              ...data.surahs.map(
                (surah) => ContentTile(
                  title: surah.name,
                  subtitle: '${surah.ayahCount} ayet',
                  leading: NumberBadge('${surah.id}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranSurahPage(surahId: surah.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranHome {
  const _QuranHome({
    required this.kursi,
    required this.lastTen,
    required this.surahs,
  });

  final AyetulKursi kursi;
  final List<ShortAyah> lastTen;
  final List<SurahIndexItem> surahs;
}

class QuranSurahPage extends StatefulWidget {
  const QuranSurahPage({super.key, required this.surahId});

  final int surahId;

  @override
  State<QuranSurahPage> createState() => _QuranSurahPageState();
}

class _QuranSurahPageState extends State<QuranSurahPage> {
  Future<List<QuranVerse>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.quran.getSurah(widget.surahId);
    return Scaffold(
      appBar: AppBar(title: Text(surahName(widget.surahId))),
      body: AsyncBody<List<QuranVerse>>(
        future: _future!,
        onRetry: () => setState(() => _future = repos.quran.getSurah(widget.surahId)),
        builder: (verses) => ListView.separated(
          padding: AppSpacing.page,
          itemCount: verses.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final verse = verses[index];
            return MinikCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SoftBadge(label: '${verse.ayahNo}'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ArabicText(verse.arabic),
                  const SizedBox(height: 10),
                  Text(verse.meal),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SimpleAyahPage extends StatelessWidget {
  const _SimpleAyahPage({
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.source,
  });

  final String title;
  final String arabic;
  final String meaning;
  final String source;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: title,
      children: [
        ArabicPanel(arabic, fontSize: 24),
        const SizedBox(height: AppSpacing.md),
        Text(meaning, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        Text(source, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
