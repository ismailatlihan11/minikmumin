import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/dhikr.dart';
import '../../shared/widgets/minik_ui.dart';
import 'dhikr_store.dart';
import 'zikr_counter_page.dart';
import 'zikr_form_page.dart';
import 'zikr_stats_page.dart';

enum _ZikrFilter { all, favorites, paused, completed, recent }

class ZikrPage extends StatefulWidget {
  const ZikrPage({super.key});

  @override
  State<ZikrPage> createState() => _ZikrPageState();
}

class _ZikrPageState extends State<ZikrPage> {
  _ZikrFilter _filter = _ZikrFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DhikrStore>();
    final items = _filtered(store);
    final last = store.lastUsed;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikirmatik'),
        actions: [
          IconButton(
            tooltip: 'İstatistik',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ZikrStatsPage()),
            ),
            icon: const Icon(Icons.insights_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZikrFormPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni zikir'),
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const PageHeader(
            title: 'Zikrim',
            subtitle: 'Haydi zikrimize başlayalım.',
            image: 'assets/images/home/circle_zikr.png',
          ),
          if (last != null && last.currentCount > 0)
            _LastCard(
              dhikr: last,
              image: store.imageFor(last),
              onContinue: () => _open(last.id),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _ZikrFilter.values) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(filter)),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const MinikCard(child: Text('Bu listede henüz zikir yok.'))
          else
            for (final dhikr in items)
              _DhikrTile(
                dhikr: dhikr,
                image: store.imageFor(dhikr),
                todayDone: store.todayCompletedCount(dhikr.id),
                onOpen: () => _open(dhikr.id),
                onFavorite: () => store.toggleFavorite(dhikr.id),
              ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }

  List<Dhikr> _filtered(DhikrStore store) {
    switch (_filter) {
      case _ZikrFilter.all:
        return store.items;
      case _ZikrFilter.favorites:
        return store.favorites;
      case _ZikrFilter.paused:
        return store.pausedItems;
      case _ZikrFilter.completed:
        return store.completedItems;
      case _ZikrFilter.recent:
        return store.recentlyUsed;
    }
  }

  String _filterLabel(_ZikrFilter filter) {
    switch (filter) {
      case _ZikrFilter.all:
        return 'Tüm Zikirler';
      case _ZikrFilter.favorites:
        return 'Favoriler';
      case _ZikrFilter.paused:
        return 'Yarım Kalanlar';
      case _ZikrFilter.completed:
        return 'Tamamlananlar';
      case _ZikrFilter.recent:
        return 'Son Kullanılanlar';
    }
  }

  void _open(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZikrCounterPage(dhikrId: id)),
    );
  }
}

class _LastCard extends StatelessWidget {
  const _LastCard({
    required this.dhikr,
    required this.image,
    required this.onContinue,
  });

  final Dhikr dhikr;
  final String image;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: MinikCard(
        color: MinikColors.mint,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Son zikrin', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(dhikr.title, style: Theme.of(context).textTheme.titleMedium),
            Text('${dhikr.currentCount} / ${dhikr.targetCount}'),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Devam Et'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DhikrTile extends StatelessWidget {
  const _DhikrTile({
    required this.dhikr,
    required this.image,
    required this.todayDone,
    required this.onOpen,
    required this.onFavorite,
  });

  final Dhikr dhikr;
  final String image;
  final int todayDone;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final paused = dhikr.isPaused &&
        dhikr.currentCount > 0 &&
        dhikr.currentCount < dhikr.targetCount;
    return ContentTile(
      title: dhikr.title,
      subtitle: paused
          ? '${dhikr.currentCount} / ${dhikr.targetCount}  ·  Kaldığın yerden devam et'
          : dhikr.isCompleted
              ? 'Hedef ${dhikr.targetCount}  ·  Bugün $todayDone kez  ·  Toplam ${dhikr.totalCount}'
              : '${dhikr.arabic.isEmpty ? dhikr.transliteration : dhikr.arabic}  ·  ${dhikr.targetCount}',
      leading: Image.asset(
        image,
        width: 44,
        height: 44,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.radio_button_checked_rounded,
          color: MinikColors.green,
        ),
      ),
      trailing: IconButton(
        onPressed: onFavorite,
        icon: Icon(
          dhikr.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: dhikr.isFavorite ? const Color(0xFFC45B7A) : MinikColors.darkGreen,
        ),
      ),
      onTap: onOpen,
    );
  }
}
