import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/dhikr.dart';
import '../../shared/widgets/minik_ui.dart';
import 'dhikr_store.dart';

class ZikrStatsPage extends StatelessWidget {
  const ZikrStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DhikrStore>();
    final overview = store.overview();
    final maxBar = overview.weekBars.fold<int>(1, (max, value) => value > max ? value : max);
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Scaffold(
      appBar: AppBar(title: const Text('Zikir istatistikleri')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const PageHeader(
            title: 'Bugün',
            subtitle: 'Hepsi bu cihazda saklanır.',
            image: 'assets/images/home/circle_zikr.png',
          ),
          _StatCard('Toplam tekrar', '${overview.todayCount}'),
          _StatCard('Tamamlanan hedef', '${overview.todayCompleted}'),
          _StatCard('Aktif zikir', '${overview.activeCount}'),
          _StatCard('Yarım kalan', '${overview.pausedCount}'),
          _StatCard('Favori', '${overview.favoriteCount}'),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Bu hafta', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Container(
                                height: 8 + (72 * (overview.weekBars[i] / maxBar)),
                                decoration: BoxDecoration(
                                  color: MinikColors.greenSoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(days[i], style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MinikCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Özet', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text('Hafta: ${overview.weekCount} tekrar'),
                Text('Ay: ${overview.monthCount} tekrar'),
                Text('Toplam: ${overview.totalCount} tekrar'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MinikCard(
            color: MinikColors.butter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hatırlatma', style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Zikir hatırlatması'),
                  subtitle: Text(
                    'Sabah ${store.settings.reminderMorningHour}:00 · Akşam ${store.settings.reminderEveningHour}:00',
                  ),
                  value: store.settings.reminderEnabled,
                  onChanged: (value) => store.updateSettings(
                    store.settings.copyWith(reminderEnabled: value),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ses'),
                  value: store.settings.soundEnabled,
                  onChanged: (value) => store.updateSettings(
                    store.settings.copyWith(soundEnabled: value),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Titreşim'),
                  value: store.settings.vibrationEnabled,
                  onChanged: (value) => store.updateSettings(
                    store.settings.copyWith(vibrationEnabled: value),
                  ),
                ),
                const Text('Titreşim gücü'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final intensity in DhikrVibrationIntensity.values)
                      ChoiceChip(
                        label: Text(switch (intensity) {
                          DhikrVibrationIntensity.light => 'Hafif',
                          DhikrVibrationIntensity.normal => 'Normal',
                          DhikrVibrationIntensity.strong => 'Güçlü',
                        }),
                        selected: store.settings.vibrationIntensity == intensity,
                        onSelected: (_) => store.updateSettings(
                          store.settings.copyWith(vibrationIntensity: intensity),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MinikCard(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
