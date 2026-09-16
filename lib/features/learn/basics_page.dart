import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/basics_sections.dart';
import '../../app/constants/content_assets.dart';
import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';
import '../../core/storage/local_progress_store.dart';
import '../../data/models/basics.dart';
import '../../data/repositories/content_repositories.dart';
import '../../features/duas/duas_page.dart';
import '../../shared/widgets/arabic_text.dart';
import '../../shared/widgets/async_body.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/copy_text.dart';
import '../../shared/widgets/minik_ui.dart';

const _kind = 'basics';

class BasicsPage extends StatefulWidget {
  const BasicsPage({super.key});

  @override
  State<BasicsPage> createState() => _BasicsPageState();
}

class _BasicsPageState extends State<BasicsPage> {
  Future<BasicsCatalog>? _future;

  Future<BasicsCatalog> _load() {
    return context.read<ContentRepositories>().basics.load();
  }

  @override
  Widget build(BuildContext context) {
    _future ??= _load();
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: SafeArea(
        child: AsyncBody<BasicsCatalog>(
          future: _future!,
          onRetry: () => setState(() => _future = _load()),
          builder: (catalog) => FutureBuilder<List<String>>(
            future: store.getCompletedItems(),
            builder: (context, snapshot) {
              final done = _doneIds(snapshot.data);
              return ListView(
                padding: AppSpacing.page,
                children: [
                  const PageHeader(
                    title: 'Temel Dini Bilgiler',
                    subtitle: 'İslam\'ın temel bilgilerini adım adım öğrenelim.',
                    image: 'assets/images/home/card_ilmihal.png',
                  ),
                  _ProgressLine(
                    label: '${done.length} / ${catalog.items.length} konu tamamlandı',
                    value: catalog.items.isEmpty
                        ? 0
                        : done.length / catalog.items.length,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final section in BasicsSections.all) ...[
                    _SectionCard(
                      section: section,
                      items: catalog.itemsForIds(section.itemIds),
                      doneIds: done,
                      onOpen: () => Navigator.push(
                        context,
                        MinikTheme.lightRoute(
                          BasicsSectionPage(
                            section: section,
                            catalog: catalog,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ContentTile(
                    title: 'Tüm ilmihal konuları',
                    subtitle: 'İman, temizlik, namaz, oruç ve daha fazlası',
                    leading: const Icon(
                      Icons.library_books_rounded,
                      color: MinikColors.green,
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.learnIlmihal),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BasicsSectionPage extends StatelessWidget {
  const BasicsSectionPage({
    super.key,
    required this.section,
    required this.catalog,
  });

  final BasicsSectionDef section;
  final BasicsCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final items = catalog.itemsForIds(section.itemIds);
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(title: Text(section.title)),
      body: FutureBuilder<List<String>>(
        future: store.getCompletedItems(),
        builder: (context, snapshot) {
          final done = _doneIds(snapshot.data);
          final completedHere =
              items.where((item) => done.contains(item.id)).length;
          return ListView(
            padding: AppSpacing.page,
            children: [
              MinikCard(
                color: section.color,
                child: Row(
                  children: [
                    Image.asset(section.image, width: 72, height: 72, fit: BoxFit.contain),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: MinikColors.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            section.subtitle,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: MinikColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ProgressLine(
                label: '$completedHere / ${items.length} tamamlandı',
                value: items.isEmpty ? 0 : completedHere / items.length,
              ),
              const SizedBox(height: 12),
              for (final item in items)
                ContentTile(
                  title: item.title,
                  subtitle: item.shortDescription,
                  leading: Icon(
                    basicsIconFor(item.icon),
                    color: section.accent,
                  ),
                  trailing: done.contains(item.id)
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: MinikColors.green,
                        )
                      : null,
                  onTap: () => Navigator.push(
                    context,
                    MinikTheme.lightRoute(
                      BasicsItemPage(
                        item: item,
                        sectionTitle: section.title,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class BasicsItemPage extends StatefulWidget {
  const BasicsItemPage({
    super.key,
    required this.item,
    required this.sectionTitle,
  });

  final BasicsItem item;
  final String sectionTitle;

  @override
  State<BasicsItemPage> createState() => _BasicsItemPageState();
}

class _BasicsItemPageState extends State<BasicsItemPage> {
  final _audio = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<LocalProgressStore>();
      store.setContinue(
        title: 'Temel Dini Bilgiler',
        subtitle: '${widget.sectionTitle} · ${widget.item.title}',
        route: AppRoutes.learnBasics,
        progress: 0.2,
      );
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  String? get _audioPath {
    final fromJson = widget.item.audio.trim();
    if (fromJson.isNotEmpty) return fromJson;
    switch (widget.item.icon) {
      case 'shahada':
        return ContentAssets.audioFor('kelime_i_sehadet');
      case 'bismillah':
        return ContentAssets.audioFor('besmele');
      case 'tawhid':
        return ContentAssets.audioFor('kelime_i_tevhid');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final store = context.watch<LocalProgressStore>();
    final path = _audioPath;
    final hasAudio = path != null && AssetCatalog.contains(path);
    return FutureBuilder<bool>(
      future: store.isCompleted(_kind, '${item.id}'),
      builder: (context, snapshot) {
        final learned = snapshot.data ?? false;
        return MinikTheme.lightSurfaces(
          Scaffold(
          backgroundColor: const Color(0xFFF4F7F2),
          appBar: AppBar(
            title: Text(item.title),
            actions: [
              CopyIconButton(text: _basicsCopyText(item)),
            ],
          ),
          body: SelectionArea(
            child: DefaultTextStyle.merge(
            style: const TextStyle(color: MinikColors.text),
            child: ListView(
            padding: AppSpacing.page,
            children: [
              if (item.shortDescription.trim().isNotEmpty)
                Text(
                  item.shortDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: MinikColors.text,
                      ),
                ),
              if (item.hasArabic) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('📖 Arapça'),
                MinikCard(
                  color: MinikColors.mint,
                  child: ArabicText(item.arabic, fontSize: 24),
                ),
              ],
              if (hasAudio && path != null) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionLabel('🔊 Dinle'),
                ListenButton(audio: _audio, path: path),
              ],
              if (item.transliteration.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionLabel('📝 Okunuş'),
                MinikCard(
                  color: const Color(0xFFFFF6DC),
                  child: Text(
                    item.transliteration,
                    style: const TextStyle(
                      fontFamily: 'NotoSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MinikColors.darkGreen,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              if (item.meaning.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionLabel('💬 Anlamı'),
                MinikCard(child: Text(item.meaning)),
              ],
              if (item.content.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(item.content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: MinikColors.text,
                    )),
              ],
              if (item.example != null && item.example!.hasContent) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('Örnek'),
                MinikCard(
                  color: MinikColors.mint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item.example!.arabic.trim().isNotEmpty)
                        ArabicText(item.example!.arabic, fontSize: 24),
                      if (item.example!.text.trim().isNotEmpty) ...[
                        if (item.example!.arabic.trim().isNotEmpty)
                          const SizedBox(height: 10),
                        Text(
                          item.example!.text,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MinikColors.darkGreen,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (item.example!.meaning.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.example!.meaning,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: MinikColors.text,
                              ),
                        ),
                      ],
                      if (item.example!.reference.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.example!.reference,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MinikColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (item.items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                for (final sub in item.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MinikCard(
                      color: MinikColors.surface,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: MinikColors.green,
                            child: Text(
                              '${sub.order}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.title,
                                  style: const TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontWeight: FontWeight.w800,
                                    color: MinikColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub.description,
                                  style: const TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 13,
                                    color: MinikColors.textMuted,
                                    height: 1.3,
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
              if (item.keyPoints.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                for (final point in item.keyPoints)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: MinikColors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: MinikColors.text,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (learned)
                const MinikCard(
                  color: Color(0xFFE7F4EC),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: MinikColors.green),
                      SizedBox(width: 8),
                      Text(
                        '✓ Öğrenildi',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                )
              else
                PrimaryButton(
                  label: 'Öğrenildi olarak işaretle',
                  onPressed: () async {
                    await store.markCompleted(
                      _kind,
                      '${item.id}',
                      xp: 3,
                    );
                  },
                ),
            ],
          ),
            ),
          ),
        ),
        );
      },
    );
  }
}

String _basicsCopyText(BasicsItem item) {
  return joinCopyParts([
    item.title,
    item.shortDescription,
    item.arabic,
    item.transliteration,
    item.meaning,
    item.content,
    for (final sub in item.items) '${sub.title}\n${sub.description}',
    ...item.keyPoints,
    if (item.example != null) item.example!.arabic,
    if (item.example != null) item.example!.text,
    if (item.example != null) item.example!.meaning,
    if (item.example != null) item.example!.reference,
  ]);
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.items,
    required this.doneIds,
    required this.onOpen,
  });

  final BasicsSectionDef section;
  final List<BasicsItem> items;
  final Set<int> doneIds;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final done = items.where((item) => doneIds.contains(item.id)).length;
    return Material(
      color: section.color,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 88,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        section.image,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final icon in section.symbols)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                icon,
                                size: 18,
                                color: section.accent.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.title,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.subtitle,
                style: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MinikColors.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${items.length} Konu',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: section.accent,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: items.isEmpty ? 0 : done / items.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  color: section.accent,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  section.actionLabel,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: section.accent,
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

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: MinikColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: value.clamp(0, 1),
            backgroundColor: const Color(0xFFE0EAE4),
            color: MinikColors.green,
          ),
        ),
      ],
    );
  }
}

Set<int> _doneIds(List<String>? items) {
  if (items == null) return {};
  return {
    for (final item in items)
      if (item.startsWith('basics|'))
        int.tryParse(item.substring(7)) ?? -1,
  }..remove(-1);
}

IconData basicsIconFor(String icon) {
  switch (icon) {
    case 'islam':
      return Icons.mosque_rounded;
    case 'shahada':
      return Icons.verified_rounded;
    case 'bismillah':
      return Icons.auto_awesome_rounded;
    case 'tawhid':
      return Icons.brightness_1_rounded;
    case 'five-pillars':
      return Icons.account_balance_rounded;
    case 'six-articles-of-faith':
      return Icons.star_rounded;
    case 'prophets':
    case 'quran':
      return Icons.menu_book_rounded;
    case 'ayah':
      return Icons.format_quote_rounded;
    case 'hadith':
      return Icons.record_voice_over_rounded;
    case 'sunnah':
      return Icons.route_rounded;
    case 'muhammad':
      return Icons.volunteer_activism_rounded;
    case 'qibla':
      return Icons.explore_rounded;
    case 'prayer':
      return Icons.mosque_rounded;
    case 'wudu':
      return Icons.water_drop_rounded;
    case 'fasting':
      return Icons.nightlight_round;
    case 'zakat':
      return Icons.volunteer_activism_rounded;
    case 'hajj':
      return Icons.mosque_outlined;
    case 'halal-haram':
      return Icons.check_circle_rounded;
    case 'dua':
      return Icons.favorite_rounded;
    case 'gratitude':
      return Icons.emoji_emotions_rounded;
    case 'good-manners':
      return Icons.favorite_outline_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}
