import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
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
  var _editing = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DhikrStore>();
    final items = _filtered(store);
    final last = store.lastUsed;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Sırayı değiştir' : 'Zikirmatik'),
        actions: [
          if (!_editing)
            IconButton(
              tooltip: 'İstatistik',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZikrStatsPage()),
              ),
              icon: const Icon(Icons.insights_rounded),
            ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _editing = !_editing;
                if (_editing) _filter = _ZikrFilter.all;
              });
            },
            icon: Icon(
              _editing ? Icons.check_rounded : Icons.swap_vert_rounded,
            ),
            label: Text(_editing ? 'Bitti' : 'Sırala'),
          ),
        ],
      ),
      floatingActionButton: _editing
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ZikrFormPage()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Yeni zikir'),
            ),
      body: _editing
          ? _ReorderBody(
              items: items,
              store: store,
              onEdit: _edit,
              onDelete: (dhikr) => _confirmDelete(store, dhikr),
            )
          : ListView(
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
                _FilterRow(
                  filter: _filter,
                  onFilter: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _editing = true;
                        _filter = _ZikrFilter.all;
                      });
                    },
                    icon: const Icon(Icons.swap_vert_rounded, size: 20),
                    label: const Text('Zikir sırasını değiştir veya düzenle'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (items.isEmpty)
                  const MinikCard(child: Text('Bu listede henüz zikir yok.'))
                else
                  for (final dhikr in items)
                    _DhikrTile(
                      dhikr: dhikr,
                      todayDone: store.todayCompletedCount(dhikr.id),
                      onOpen: () => _open(dhikr.id),
                      onFavorite: () => store.toggleFavorite(dhikr.id),
                      onLongPress: () => _showActions(store, dhikr),
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

  void _open(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZikrCounterPage(dhikrId: id)),
    );
  }

  void _edit(Dhikr dhikr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZikrFormPage(existing: dhikr)),
    );
  }

  Future<void> _confirmDelete(DhikrStore store, Dhikr dhikr) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zikri sil'),
        content: Text('“${dhikr.title}” listeden kaldırılsın mı?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok == true) await store.deleteDhikr(dhikr.id);
  }

  Future<void> _showActions(DhikrStore store, Dhikr dhikr) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Düzenle'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Sil'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            ListTile(
              leading: Icon(
                dhikr.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: const Color(0xFFC45B7A),
              ),
              title: Text(dhikr.isFavorite ? 'Favoriden çıkar' : 'Favorile'),
              onTap: () => Navigator.pop(context, 'favorite'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        _edit(dhikr);
      case 'delete':
        await _confirmDelete(store, dhikr);
      case 'favorite':
        await store.toggleFavorite(dhikr.id);
    }
  }
}

class _ReorderBody extends StatelessWidget {
  const _ReorderBody({
    required this.items,
    required this.store,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Dhikr> items;
  final DhikrStore store;
  final void Function(Dhikr dhikr) onEdit;
  final void Function(Dhikr dhikr) onDelete;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: AppSpacing.page,
      buildDefaultDragHandles: false,
      proxyDecorator: _proxyDecorator,
      onReorderStart: (_) => HapticFeedback.mediumImpact(),
      onReorderEnd: (_) => HapticFeedback.selectionClick(),
      onReorderItem: store.reorderDhikr,
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: 'Zikrim',
            subtitle: 'Satırı tutup sürükleyerek sırayı değiştir.',
            image: 'assets/images/home/circle_zikr.png',
          ),
          MinikCard(
            color: Color(0xFFFFF6DC),
            child: Row(
              children: [
                Icon(Icons.swap_vert_rounded, color: MinikColors.gold),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sağdaki ☰ tutamacı basılı tutup yukarı/aşağı sürükle. '
                    'Kalem ile düzenle, çöp ile sil.',
                    style: TextStyle(
                      fontFamily: 'NotoSans',
                      fontWeight: FontWeight.w700,
                      color: MinikColors.darkGreen,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final dhikr = items[index];
        return Padding(
          key: ValueKey(dhikr.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _EditTile(
            dhikr: dhikr,
            index: index,
            onEdit: () => onEdit(dhikr),
            onDelete: () => onDelete(dhikr),
          ),
        );
      },
    );
  }
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOutCubic.transform(animation.value);
      return Transform.translate(
        offset: Offset(0, -4 * t),
        child: Transform.scale(
          scale: 1.0 + 0.035 * t,
          child: Material(
            elevation: 2 + 14 * t,
            color: Colors.transparent,
            shadowColor: const Color(0x66000000),
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Color.lerp(
                    Colors.transparent,
                    MinikColors.gold,
                    t,
                  )!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(47, 107, 74, 0.18 * t),
                    blurRadius: 18 * t,
                    offset: Offset(0, 8 * t),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      );
    },
    child: child,
  );
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.onFilter,
  });

  final _ZikrFilter filter;
  final ValueChanged<_ZikrFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final value in _ZikrFilter.values) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_filterLabel(value)),
                selected: filter == value,
                onSelected: (_) => onFilter(value),
              ),
            ),
          ],
        ],
      ),
    );
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
    required this.todayDone,
    required this.onOpen,
    required this.onFavorite,
    this.onLongPress,
  });

  final Dhikr dhikr;
  final int todayDone;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final paused = dhikr.isPaused &&
        dhikr.currentCount > 0 &&
        dhikr.currentCount < dhikr.targetCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: MinikColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onOpen,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _TargetCounterBadge(value: dhikr.targetCount),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dhikr.title,
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                      if (paused || dhikr.isCompleted) ...[
                        const SizedBox(height: 3),
                        Text(
                          paused
                              ? '${dhikr.currentCount} / ${dhikr.targetCount}  ·  Kaldığın yerden devam et'
                              : 'Bugün $todayDone kez  ·  Toplam ${dhikr.totalCount}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MinikColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    dhikr.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: dhikr.isFavorite
                        ? const Color(0xFFC45B7A)
                        : MinikColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  const _EditTile({
    required this.dhikr,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final Dhikr dhikr;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
        child: Row(
          children: [
            Expanded(
              child: ReorderableDelayedDragStartListener(
                index: index,
                child: Row(
                  children: [
                    _TargetCounterBadge(value: dhikr.targetCount, size: 42),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dhikr.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w800,
                          color: MinikColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Düzenle',
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_rounded, color: MinikColors.green),
            ),
            IconButton(
              tooltip: 'Sil',
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFB85C5C),
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Container(
                margin: const EdgeInsets.only(left: 2, right: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1CC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MinikColors.goldSoft),
                ),
                child: const Icon(
                  Icons.drag_indicator_rounded,
                  color: MinikColors.gold,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cute zikirmatik badge with target number on the LCD area.
class _TargetCounterBadge extends StatelessWidget {
  const _TargetCounterBadge({required this.value, this.size = 56});

  final int value;
  final double size;

  static const _asset = 'assets/images/home/zikr_counter_badge.jpg';

  @override
  Widget build(BuildContext context) {
    final digits = value.toString();
    final fontSize = switch (digits.length) {
      1 => size * 0.17,
      2 => size * 0.145,
      3 => size * 0.115,
      _ => size * 0.095,
    };

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              _asset,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          // Hide baked-in 33; show this zikr's target on the LCD.
          Positioned(
            left: size * 0.315,
            width: size * 0.34,
            top: size * 0.455,
            height: size * 0.145,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0CF),
                borderRadius: BorderRadius.circular(size * 0.035),
              ),
              child: Center(
                child: Text(
                  digits,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: digits.length > 2 ? -0.4 : 0.15,
                    color: const Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
