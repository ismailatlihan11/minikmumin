import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/content_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/dua.dart';
import '../../data/models/prophet.dart';
import '../../data/repositories/content_repositories.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_image.dart';
import '../../shared/widgets/minik_ui.dart';
import '../../shared/widgets/topic_footer.dart';
import '../duas/duas_page.dart';

class ProphetsPage extends StatefulWidget {
  const ProphetsPage({super.key});

  @override
  State<ProphetsPage> createState() => _ProphetsPageState();
}

class _ProphetsPageState extends State<ProphetsPage> {
  Future<List<Prophet>>? _future;

  @override
  Widget build(BuildContext context) {
    final repos = context.read<ContentRepositories>();
    _future ??= repos.prophets.getAll();
    return Scaffold(
      body: SafeArea(
        child: AsyncBody<List<Prophet>>(
          future: _future!,
          onRetry: () => setState(() {
            _future = repos.prophets.getAll();
          }),
          builder: (items) => ListView(
            padding: AppSpacing.page,
            children: [
              const PageHeader(
                title: 'Peygamberler',
                subtitle: 'Kur\'an\'da adı geçen peygamberleri tanıyalım.',
              ),
              MinikCard(
                color: MinikColors.butter,
                onTap: () =>
                    Navigator.pushNamed(context, '/minik/learn/prophets-book'),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MinikImage.asset(
                        'assets/images/books/peygamberler/page_05.jpg',
                        width: 56,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En Güzel Örnek Peygamberler',
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Diyanet’ten resimli kitap. Sayfa sayfa oku.',
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.menu_book_rounded, color: MinikColors.green),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final (index, item) in items.indexed)
                ContentTile(
                  title: item.listTitle,
                  subtitle: item.roleTitle,
                  leading: MinikImage.asset(
                    ContentAssets.prophetImage(
                      item.name,
                      id: item.id,
                      jsonPath: item.image,
                    ),
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.auto_awesome_rounded,
                      color: MinikColors.green,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProphetDetailPage(
                        item: item,
                        upcoming: items.sublist(index + 1),
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

class ProphetDetailPage extends StatefulWidget {
  const ProphetDetailPage({
    super.key,
    required this.item,
    this.upcoming = const [],
  });

  final Prophet item;
  final List<Prophet> upcoming;

  @override
  State<ProphetDetailPage> createState() => _ProphetDetailPageState();
}

class _ProphetDetailPageState extends State<ProphetDetailPage> {
  void _openNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProphetDetailPage(
          item: widget.upcoming.first,
          upcoming: widget.upcoming.sublist(1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context).textTheme;
    final imagePath = ContentAssets.prophetImage(
      item.name,
      id: item.id,
      jsonPath: item.image,
    );
    return DetailScaffold(
      title: item.honorificName,
      actions: [
        CopyIconButton(
          text: joinCopyParts([
            item.roleTitle,
            item.honorificName,
            item.arabicName,
            item.summary,
          ]),
        ),
      ],
      children: [
        MinikImage.asset(
          imagePath,
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => MinikImage.asset(
            'assets/images/prophets/prophets.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ArabicText(item.arabicName, fontSize: 28),
        const SizedBox(height: AppSpacing.sm),
        if (item.roleTitle.isNotEmpty)
          Text(item.roleTitle, style: theme.titleMedium),
        Text(
          item.honorificName,
          style: theme.headlineMedium,
        ),
        if (item.isMuhammad) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Salavat'),
          const _ProphetSalawat(),
        ],
        const SizedBox(height: AppSpacing.md),
        SelectableText(item.summary, style: theme.bodyLarge),
        if (item.lessons.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Öğrendiğimiz değerler'),
          for (final lesson in item.lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: MinikColors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(lesson, style: theme.bodyLarge)),
                ],
              ),
            ),
        ],
        if (item.quranReferences.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const SectionLabel('Kur\'an'),
          Text(item.quranReferencesText, style: theme.bodyLarge),
        ],
        if (item.sourceName.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Kaynak: ${item.sourceName}', style: theme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.lg),
        TopicFooter(
          hasNext: widget.upcoming.isNotEmpty,
          onNext: _openNext,
          nextLabel: 'Sonraki peygambere geç',
          backLabel: 'Peygamberlere dön',
        ),
      ],
    );
  }
}

class _ProphetSalawat extends StatefulWidget {
  const _ProphetSalawat();

  @override
  State<_ProphetSalawat> createState() => _ProphetSalawatState();
}

class _ProphetSalawatState extends State<_ProphetSalawat> {
  Future<List<DuaEntry>>? _future;

  @override
  Widget build(BuildContext context) {
    final duas = context.read<ContentRepositories>().duas;
    _future ??= Future.wait([
      duas.getEntryById('allahumme_salli'),
      duas.getEntryById('allahumme_barik'),
    ]).then((items) => items.whereType<DuaEntry>().toList());
    return FutureBuilder<List<DuaEntry>>(
      future: _future,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <DuaEntry>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final dua in items) ...[
              Text(dua.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              DuaContentBlocks(dua: dua, arabicFontSize: 20),
              Align(
                alignment: Alignment.centerRight,
                child: CopyIconButton(
                  text: joinCopyParts([
                    dua.title,
                    dua.arabic,
                    dua.transliteration,
                    dua.meaning,
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}
