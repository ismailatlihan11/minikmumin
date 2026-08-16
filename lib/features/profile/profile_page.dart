import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikProfilePage extends StatelessWidget {
  const MinikProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_ProfileSnapshot>(
          future: _load(store),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final xp = data?.xp ?? 0;
            final lessons = data?.lessons ?? const [];
            final badges = data?.badges ?? const [];
            return ListView(
              padding: AppSpacing.page,
              children: [
                const PageHeader(
                  title: 'Profil',
                  subtitle: 'İlerlemen bu cihazda saklanır.',
                  image: 'assets/images/home/profile.png',
                ),
                MinikCard(
                  color: MinikColors.butter,
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MinikColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'XP',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: MinikColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$xp', style: Theme.of(context).textTheme.displayMedium),
                            const Text('Toplam puan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('Dersler'),
                MinikCard(
                  child: Text(
                    lessons.isEmpty
                        ? 'Henüz tamamlanan ders yok. Öğren sekmesinden başlayabilirsin.'
                        : lessons.map(_lessonLabel).join(', '),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionLabel('Rozetler'),
                CatalogGrid(
                  children: [
                    for (final badge in _allBadges)
                      Opacity(
                        opacity: badges.contains(badge.id) ? 1 : 0.35,
                        child: Image.asset(
                          badge.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => SoftBadge(label: badge.title),
                        ),
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

  Future<_ProfileSnapshot> _load(LocalProgressStore store) async {
    return _ProfileSnapshot(
      xp: await store.getXp(),
      lessons: await store.getCompletedLessons(),
      badges: await store.getBadges(),
    );
  }

  String _lessonLabel(String id) {
    switch (id) {
      case 'wudu':
        return 'Abdest';
      default:
        return id;
    }
  }
}

const _allBadges = [
  (id: 'first_lesson', title: 'İlk Ders', image: 'assets/images/achievements/first_lesson.png'),
  (id: 'first_dua', title: 'İlk Dua', image: 'assets/images/achievements/first_dua.png'),
  (id: 'prayer_duas', title: 'Namaz Duaları', image: 'assets/images/achievements/prayer_duas.png'),
  (id: 'quran_reader', title: "Kur'an Okuyorum", image: 'assets/images/achievements/quran_reader.png'),
  (id: 'asma_10', title: '10 Esma', image: 'assets/images/achievements/asma_10.png'),
  (id: 'good_manners', title: 'Güzel Ahlak', image: 'assets/images/achievements/good_manners.png'),
];

class _ProfileSnapshot {
  const _ProfileSnapshot({
    required this.xp,
    required this.lessons,
    required this.badges,
  });

  final int xp;
  final List<String> lessons;
  final List<String> badges;
}
