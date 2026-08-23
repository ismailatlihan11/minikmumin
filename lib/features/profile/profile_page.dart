import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/learn_categories.dart';
import '../../app/constants/peygamberler_kitabi.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../shared/widgets/minik_ui.dart';

class MinikProfilePage extends StatefulWidget {
  const MinikProfilePage({super.key});

  @override
  State<MinikProfilePage> createState() => _MinikProfilePageState();
}

class _MinikProfilePageState extends State<MinikProfilePage> {
  Future<_ProfileSnapshot>? _future;
  LocalProgressStore? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<LocalProgressStore>();
    if (!identical(_store, store)) {
      _store?.removeListener(_refresh);
      _store = store;
      store.addListener(_refresh);
      _future ??= _load(store);
    }
  }

  void _refresh() {
    final store = _store;
    if (!mounted || store == null) return;
    setState(() => _future = _load(store));
  }

  @override
  void dispose() {
    _store?.removeListener(_refresh);
    super.dispose();
  }

  Future<_ProfileSnapshot> _load(LocalProgressStore store) async {
    final rawName = (await store.getNickname())?.trim();
    final items = await store.getCompletedItems();
    final wudu = await store.getWuduProgress();
    final bookmarked = await store.getBookBookmark(PeygamberlerKitabi.id);
    return _ProfileSnapshot(
      xp: await store.getXp(),
      badges: await store.getBadges(),
      nickname: (rawName == null || rawName.isEmpty) ? null : rawName,
      lessons: [
        for (final category in LearnCategories.all)
          _LessonStat(
            category: category,
            done: _doneCount(category.id, items, wudu),
            started: _started(category.id, items, wudu, bookmarked != null),
          ),
      ],
    );
  }

  int _doneCount(String id, List<String> items, WuduProgress wudu) {
    switch (id) {
      case 'basics':
        return _prefixCount(items, 'basics|');
      case 'wudu':
        return wudu.completed ? 1 : 0;
      case 'prayer':
        return _prefixCount(items, 'prayer|');
      case 'prayer_duas':
        return _prefixCount(items, 'prayer_dua|');
      case 'quran_learn':
        return items.where((item) => item.startsWith('ql_')).length;
      case 'duas':
        return _prefixCount(items, 'dua|');
      case 'hadith':
        return _prefixCount(items, 'hadith|');
      case 'prophets_stories':
        return _prefixCount(items, 'story|') + _prefixCount(items, 'prophet|');
      case 'prophets_book':
        return _prefixCount(items, 'book|');
      case 'morality':
        return _prefixCount(items, 'morality|');
      case 'asma':
        return _prefixCount(items, 'asma|');
      case 'quiz':
        return _prefixCount(items, 'quiz|');
      default:
        return _prefixCount(items, '$id|');
    }
  }

  bool _started(
    String id,
    List<String> items,
    WuduProgress wudu,
    bool hasBookBookmark,
  ) {
    if (id == 'wudu') return wudu.started || wudu.completed;
    if (id == 'prophets_book') return hasBookBookmark;
    return _doneCount(id, items, wudu) > 0;
  }

  int _prefixCount(List<String> items, String prefix) {
    return items.where((item) => item.startsWith(prefix)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: SafeArea(
        child: FutureBuilder<_ProfileSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return ListView(
              padding: AppSpacing.page,
              children: [
                _ProfileHero(name: data.nickname, xp: data.xp),
                const SizedBox(height: 16),
                const _SectionTitle('Dersler'),
                const SizedBox(height: 8),
                for (final lesson in data.lessons)
                  ContentTile(
                    title: lesson.category.title,
                    subtitle: lesson.subtitle,
                    color: lesson.done > 0 ? MinikColors.mint : MinikColors.surface,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        lesson.category.image,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: MinikColors.green,
                        ),
                      ),
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, lesson.category.route),
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
                              earned: data.badges.contains(badge.id),
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
  final List<_LessonStat> lessons;
  final List<String> badges;
  final String? nickname;
}

class _LessonStat {
  const _LessonStat({
    required this.category,
    required this.done,
    required this.started,
  });

  final LearnCategory category;
  final int done;
  final bool started;

  String get subtitle {
    if (done > 0) return '$done tamamlandı';
    if (started) return 'Devam ediyor';
    return 'Henüz başlanmadı';
  }
}
