import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';

class MinikProfilePage extends StatelessWidget {
  const MinikProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LocalProgressStore>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: SafeArea(
        child: FutureBuilder<_ProfileSnapshot>(
          future: _load(store),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final xp = data?.xp ?? 0;
            final lessons = data?.lessons ?? const [];
            final badges = data?.badges ?? const [];
            final name = data?.nickname;
            return ListView(
              padding: AppSpacing.page,
              children: [
                _ProfileHero(name: name, xp: xp),
                const SizedBox(height: 16),
                const _SectionTitle('Dersler'),
                const SizedBox(height: 8),
                if (lessons.isEmpty)
                  const _EmptyHint(
                    'Henüz tamamlanan ders yok. Öğren’den başlayabilirsin.',
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final id in lessons)
                        _LessonChip(label: _lessonLabel(id)),
                    ],
                  ),
                const SizedBox(height: 18),
                const _SectionTitle('Rozetler'),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const columns = 3;
                    const spacing = 8.0;
                    final tileWidth =
                        ((constraints.maxWidth - spacing * (columns - 1)) /
                                columns) *
                            0.92;
                    return Wrap(
                      alignment: WrapAlignment.start,
                      spacing: spacing,
                      runSpacing: 10,
                      children: [
                        for (final badge in _allBadges)
                          SizedBox(
                            width: tileWidth,
                            child: _BadgeTile(
                              badge: badge,
                              earned: badges.contains(badge.id),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_ProfileSnapshot> _load(LocalProgressStore store) async {
    final rawName = (await store.getNickname())?.trim();
    return _ProfileSnapshot(
      xp: await store.getXp(),
      lessons: await store.getCompletedLessons(),
      badges: await store.getBadges(),
      nickname: (rawName == null || rawName.isEmpty) ? null : rawName,
    );
  }

  String _lessonLabel(String id) {
    switch (id) {
      case 'wudu':
        return 'Abdest';
      case 'dua':
        return 'Dualar';
      case 'prayer_dua':
        return 'Namaz duaları';
      case 'story':
        return 'Kıssalar';
      case 'quran':
        return "Kur'an";
      case 'morality':
        return 'Güzel ahlak';
      case 'quiz':
        return 'Mini test';
      case 'ql_letter':
      case 'ql_haraka':
      case 'ql_comb':
      case 'ql_word':
      case 'ql_tajweed':
      case 'ql_surah':
      case 'ql_practice':
      case 'ql_tajweed_read':
      case 'ql_game':
      case 'ql_level':
        return "Kur'an Öğren";
      default:
        return id;
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.name, required this.xp});

  final String? name;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final greeting = name == null ? 'Profilin' : name!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F4EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: MinikColors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'İlerlemen bu cihazda saklanır',
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MinikColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/home/mini_trophy.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.emoji_events_rounded,
                    size: 18,
                    color: MinikColors.gold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$xp',
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: MinikColors.darkGreen,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: MinikColors.textMuted,
        height: 1.3,
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  const _LessonChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4EC),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'NotoSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MinikColors.darkGreen,
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});

  final _BadgeInfo badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1 : 0.42,
      child: AspectRatio(
        aspectRatio: 0.86,
        child: Material(
          color: badge.color,
          elevation: earned ? 1.2 : 0,
          shadowColor: const Color(0x22000000),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      badge.icon,
                      size: 22,
                      color: badge.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                    height: 1.15,
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

class _BadgeInfo {
  const _BadgeInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.accent,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color accent;
}

const _allBadges = [
  _BadgeInfo(
    id: 'first_lesson',
    title: 'İlk Ders',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFD8EEF8),
    accent: Color(0xFF3AA0C8),
  ),
  _BadgeInfo(
    id: 'first_dua',
    title: 'İlk Dua',
    icon: Icons.favorite_rounded,
    color: Color(0xFFFADDE3),
    accent: Color(0xFFD36B84),
  ),
  _BadgeInfo(
    id: 'prayer_duas',
    title: 'Namaz Duaları',
    icon: Icons.mosque_rounded,
    color: Color(0xFFE8DFF8),
    accent: Color(0xFF8B6CC9),
  ),
  _BadgeInfo(
    id: 'quran_reader',
    title: "Kur'an Okuyorum",
    icon: Icons.auto_stories_rounded,
    color: Color(0xFFD4F0E2),
    accent: Color(0xFF3D8B6E),
  ),
  _BadgeInfo(
    id: 'asma_10',
    title: '10 Esma',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFFF1C2),
    accent: Color(0xFFE0A21A),
  ),
  _BadgeInfo(
    id: 'good_manners',
    title: 'Güzel Ahlak',
    icon: Icons.volunteer_activism_rounded,
    color: Color(0xFFE6D9F5),
    accent: Color(0xFF9B6BC9),
  ),
  _BadgeInfo(
    id: 'badge_letters',
    title: 'Harf Kaşifi',
    icon: Icons.abc_rounded,
    color: Color(0xFFEAF6FF),
    accent: Color(0xFF3D8B6E),
  ),
  _BadgeInfo(
    id: 'badge_listener',
    title: 'Dinleme Ustası',
    icon: Icons.volume_up_rounded,
    color: Color(0xFFD8EEF8),
    accent: Color(0xFF3AA0C8),
  ),
  _BadgeInfo(
    id: 'badge_harakat',
    title: 'Hareke Ustası',
    icon: Icons.edit_rounded,
    color: Color(0xFFFFF1C2),
    accent: Color(0xFFE0A21A),
  ),
  _BadgeInfo(
    id: 'badge_builder',
    title: 'Birleştirme Ustası',
    icon: Icons.extension_rounded,
    color: Color(0xFFE6D9F5),
    accent: Color(0xFF9B6BC9),
  ),
  _BadgeInfo(
    id: 'badge_reader',
    title: 'İlk Kelimem',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFD4F0E2),
    accent: Color(0xFF3D8B6E),
  ),
  _BadgeInfo(
    id: 'badge_surah',
    title: 'İlk Surem',
    icon: Icons.nights_stay_rounded,
    color: Color(0xFFE8DFF8),
    accent: Color(0xFF8B6CC9),
  ),
  _BadgeInfo(
    id: 'badge_tajweed',
    title: 'Tecvid Öğrencisi',
    icon: Icons.music_note_rounded,
    color: Color(0xFFFADDE3),
    accent: Color(0xFFD36B84),
  ),
  _BadgeInfo(
    id: 'badge_practice',
    title: 'Okuma Pratiği',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFFC8EBE8),
    accent: Color(0xFF2A9A94),
  ),
  _BadgeInfo(
    id: 'badge_streak',
    title: 'Düzenli Öğrenci',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFFE8D2),
    accent: Color(0xFFD08A3A),
  ),
  _BadgeInfo(
    id: 'badge_journey',
    title: "Kur'an Yolcusu",
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFF1C2),
    accent: Color(0xFFC29739),
  ),
];

class _ProfileSnapshot {
  const _ProfileSnapshot({
    required this.xp,
    required this.lessons,
    required this.badges,
    this.nickname,
  });

  final int xp;
  final List<String> lessons;
  final List<String> badges;
  final String? nickname;
}
