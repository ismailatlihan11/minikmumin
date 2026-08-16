import '../../data/models/dhikr.dart';

abstract final class DhikrCounterService {
  static int increment(int current, int step) {
    final next = current + step;
    return next < 0 ? 0 : next;
  }

  static int decrement(int current, int step) {
    final next = current - step;
    return next < 0 ? 0 : next;
  }

  static bool shouldPulse(int count, int every) {
    if (every <= 0 || count <= 0) return false;
    return count % every == 0;
  }

  static bool justCompleted({
    required int previous,
    required int current,
    required int target,
  }) {
    return previous < target && current >= target;
  }

  static double progress(int current, int target) {
    if (target <= 0) return 0;
    return (current / target).clamp(0, 1);
  }
}

abstract final class DhikrStatsService {
  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static int sumCounts(
    List<DhikrDailyStat> stats, {
    required bool Function(DhikrDailyStat stat) where,
  }) {
    var total = 0;
    for (final stat in stats) {
      if (where(stat)) total += stat.count;
    }
    return total;
  }

  static int sumSessions(
    List<DhikrDailyStat> stats, {
    required bool Function(DhikrDailyStat stat) where,
  }) {
    var total = 0;
    for (final stat in stats) {
      if (where(stat)) total += stat.completedSessions;
    }
    return total;
  }

  static List<int> weekBars(List<DhikrDailyStat> stats, DateTime now) {
    final today = startOfDay(now);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return [
      for (var i = 0; i < 7; i++)
        sumCounts(
          stats,
          where: (stat) => stat.date == dateKey(monday.add(Duration(days: i))),
        ),
    ];
  }

  static DhikrOverview overview({
    required List<Dhikr> items,
    required List<DhikrDailyStat> stats,
    DateTime? now,
  }) {
    final date = now ?? DateTime.now();
    final today = dateKey(date);
    final weekStart = startOfDay(date).subtract(Duration(days: date.weekday - 1));
    final monthPrefix =
        '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return DhikrOverview(
      todayCount: sumCounts(stats, where: (stat) => stat.date == today),
      weekCount: sumCounts(stats, where: (stat) {
        final parsed = DateTime.tryParse(stat.date);
        return parsed != null && !parsed.isBefore(weekStart);
      }),
      monthCount: sumCounts(stats, where: (stat) => stat.date.startsWith(monthPrefix)),
      totalCount: items.fold(0, (sum, item) => sum + item.totalCount),
      todayCompleted: sumSessions(stats, where: (stat) => stat.date == today),
      activeCount: items.where((item) => item.currentCount > 0).length,
      pausedCount: items.where((item) => item.isPaused).length,
      favoriteCount: items.where((item) => item.isFavorite).length,
      weekBars: weekBars(stats, date),
    );
  }
}
