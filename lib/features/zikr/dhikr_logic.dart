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

/// Visual tesbih: full rounds of 100; the last round uses only the remainder.
abstract final class DhikrTasbih {
  static const int maxBeads = 100;

  static int lastRoundSize(int target) {
    if (target <= 0) return 1;
    if (target <= maxBeads) return target;
    final rem = target % maxBeads;
    return rem == 0 ? maxBeads : rem;
  }

  /// Max beads in a full round (not the remainder round).
  static int beadCount(int target) {
    if (target <= 0) return 1;
    return target > maxBeads ? maxBeads : target;
  }

  static int totalRounds(int target) {
    if (target <= 0) return 0;
    if (target <= maxBeads) return 1;
    return (target + maxBeads - 1) ~/ maxBeads;
  }

  static bool showsRounds(int target) => target > maxBeads;

  static int currentRoundIndex(int current, int target) {
    if (target <= maxBeads) return 0;
    final capped = current.clamp(0, target);
    if (capped <= 0) return 0;
    if (capped >= target) return totalRounds(target) - 1;
    if (capped % maxBeads == 0) return (capped ~/ maxBeads) - 1;
    return capped ~/ maxBeads;
  }

  /// Beads drawn for the round currently on screen — never more than remaining.
  static int visibleBeadCount(int current, int target) {
    if (target <= 0) return 1;
    if (target <= maxBeads) return target;
    final lastIndex = totalRounds(target) - 1;
    if (currentRoundIndex(current, target) >= lastIndex) {
      return lastRoundSize(target);
    }
    return maxBeads;
  }

  static int remainingRounds(int current, int target) {
    if (target <= 0 || current >= target) return 0;
    return totalRounds(target) - (current ~/ maxBeads);
  }

  static int pulledThisRound(int current, int target) {
    final beads = visibleBeadCount(current, target);
    final capped = current.clamp(0, target < 0 ? 0 : target);
    if (capped <= 0) return 0;
    if (capped >= target) return beads;
    if (target <= maxBeads) return capped.clamp(0, beads);
    final rem = capped % maxBeads;
    return rem == 0 ? beads : rem.clamp(0, beads);
  }

  /// First bead label in the visible round (1-based zikir count).
  static int roundStartNumber(int current, int target) {
    return currentRoundIndex(current, target) * maxBeads + 1;
  }

  static int? beadLabel(int index, int current, int target) {
    final number = roundStartNumber(current, target) + index;
    if (number < 1 || number > target) return null;
    return number;
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
    final weekStart =
        startOfDay(date).subtract(Duration(days: date.weekday - 1));
    final monthPrefix = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return DhikrOverview(
      todayCount: sumCounts(stats, where: (stat) => stat.date == today),
      weekCount: sumCounts(stats, where: (stat) {
        final parsed = DateTime.tryParse(stat.date);
        return parsed != null && !parsed.isBefore(weekStart);
      }),
      monthCount:
          sumCounts(stats, where: (stat) => stat.date.startsWith(monthPrefix)),
      totalCount: items.fold(0, (sum, item) => sum + item.totalCount),
      todayCompleted: sumSessions(stats, where: (stat) => stat.date == today),
      activeCount: items.where((item) => item.currentCount > 0).length,
      pausedCount: items.where((item) => item.isPaused).length,
      favoriteCount: items.where((item) => item.isFavorite).length,
      weekBars: weekBars(stats, date),
    );
  }
}
