import '../../core/storage/local_progress_store.dart';
import '../../core/utils/daily_seed.dart';
import '../../data/models/quran_learning.dart';

const quranLearnUnlockFlag = 'ql_unlock_all';
const quranLearnAudioPlays = 'ql_audio_plays';
const quranLearnCombinations = 'ql_combinations_correct';
const quranLearnCorrectAnswers = 'ql_correct_answers';

class QuranLearnSnapshot {
  const QuranLearnSnapshot({
    required this.pack,
    required this.completedKeys,
    required this.unlockAll,
    required this.audioPlays,
    required this.combinationsCorrect,
    required this.correctAnswers,
    required this.streak,
    required this.badges,
  });

  final QuranLearningPack pack;
  final Set<String> completedKeys;
  final bool unlockAll;
  final int audioPlays;
  final int combinationsCorrect;
  final int correctAnswers;
  final int streak;
  final List<String> badges;

  bool isDone(String kind, String id) => completedKeys.contains('$kind|$id');

  int completedCount(int levelId) {
    final items = pack.itemsForLevel(levelId);
    return items.where((item) => completedKeys.contains(item.key)).length;
  }

  int totalCount(int levelId) => pack.realLessonCount(levelId);

  double levelRatio(int levelId) {
    final total = totalCount(levelId);
    if (total <= 0) return 0;
    return (completedCount(levelId) / total).clamp(0, 1);
  }

  bool isLevelComplete(int levelId) {
    final total = totalCount(levelId);
    return total > 0 && completedCount(levelId) >= total;
  }

  bool isLevelUnlocked(QuranLearningLevel level) {
    if (unlockAll) return true;
    if (level.unlockRule == 'start' || level.prerequisiteLevel == null) {
      return true;
    }
    return isLevelComplete(level.prerequisiteLevel!);
  }

  int get currentLevelId {
    for (final level in pack.levels) {
      if (isLevelUnlocked(level) && !isLevelComplete(level.id)) {
        return level.id;
      }
    }
    return pack.levels.isEmpty ? 1 : pack.levels.last.id;
  }

  int get completedLevels =>
      pack.levels.where((level) => isLevelComplete(level.id)).length;

  int get completedLessons {
    var count = 0;
    for (final level in pack.levels) {
      count += completedCount(level.id);
    }
    return count;
  }

  int get totalLessons {
    var count = 0;
    for (final level in pack.levels) {
      count += totalCount(level.id);
    }
    return count;
  }

  double get overallRatio {
    final total = totalLessons;
    if (total <= 0) return 0;
    return (completedLessons / total).clamp(0, 1);
  }

  QuranLearnDailyLesson dailyLesson() {
    for (final level in pack.levels) {
      if (!isLevelUnlocked(level)) continue;
      final remaining = pack
          .itemsForLevel(level.id)
          .where((item) => !completedKeys.contains(item.key))
          .toList();
      if (remaining.isEmpty) continue;
      final pick = remaining[dailySeed() % remaining.length];
      return QuranLearnDailyLesson(
        level: level,
        item: pick,
        title: _dailyTitle(level, pick, pack),
      );
    }
    return QuranLearnDailyLesson.review(pack.levels.isEmpty ? null : pack.levels.first);
  }
}

class QuranLearnDailyLesson {
  const QuranLearnDailyLesson({
    required this.level,
    this.item,
    required this.title,
  });

  factory QuranLearnDailyLesson.review(QuranLearningLevel? level) {
    return QuranLearnDailyLesson(
      level: level,
      title: 'Bugün öğrendiklerini tekrar et.',
    );
  }

  final QuranLearningLevel? level;
  final QuranLearnProgressItem? item;
  final String title;
}

String _dailyTitle(
  QuranLearningLevel level,
  QuranLearnProgressItem item,
  QuranLearningPack pack,
) {
  switch (item.kind) {
    case 'ql_letter':
      final letter = pack.letterById(item.id);
      return letter == null
          ? 'Bugün 3 harfi tekrar et.'
          : 'Bugün ${letter.name} harfini öğren.';
    case 'ql_haraka':
      final haraka = pack.harakaById(item.id);
      return haraka == null
          ? 'Bugün bir hareke öğren.'
          : 'Bugün ${haraka.name} öğren.';
    case 'ql_comb':
      return 'Bugün harfleri birleştirelim.';
    case 'ql_word':
      return 'Bugün 5 kelime oku.';
    case 'ql_surah':
      final surah = pack.surahById(item.id);
      if (surah == null) return 'Bugün kısa bir sure dinle.';
      return surah.ayahFrom == null
          ? 'Bugün ${surah.nameTr} suresine bak.'
          : 'Bugün ${surah.nameTr} okumasına bak.';
    case 'ql_tajweed':
      final lesson = pack.tajweedById(item.id);
      return lesson == null
          ? 'Bugün bir tecvid kuralı öğren.'
          : 'Bugün ${lesson.title} kuralına bak.';
    case 'ql_practice':
    case 'ql_tajweed_read':
      return 'Bugün bir ayeti takip ederek oku.';
    default:
      return 'Bugün biraz pratik yapalım.';
  }
}

abstract final class QuranLearnProgress {
  static Future<QuranLearnSnapshot> load(
    LocalProgressStore store,
    QuranLearningPack pack,
  ) async {
    final items = await store.getCompletedItems();
    return QuranLearnSnapshot(
      pack: pack,
      completedKeys: items.toSet(),
      unlockAll: await store.getFlag(quranLearnUnlockFlag),
      audioPlays: await store.getCounter(quranLearnAudioPlays),
      combinationsCorrect: await store.getCounter(quranLearnCombinations),
      correctAnswers: await store.getCounter(quranLearnCorrectAnswers),
      streak: await store.getQuranLearnStreak(),
      badges: await store.getBadges(),
    );
  }

  static Future<void> complete(
    LocalProgressStore store, {
    required QuranLearningPack pack,
    required String kind,
    required String id,
    int xp = 4,
  }) async {
    await store.markCompleted(kind, id, xp: xp);
    await store.setContinue(
      title: "Kur'an Öğreniyorum",
      subtitle: 'Kaldığın yerden devam et',
      route: '/minik/learn/quran-learn',
      progress: (await load(store, pack)).overallRatio,
    );
    await syncLevelsAndBadges(store, pack);
  }

  static Future<void> syncLevelsAndBadges(
    LocalProgressStore store,
    QuranLearningPack pack,
  ) async {
    final snap = await load(store, pack);
    for (final level in pack.levels) {
      if (snap.isLevelComplete(level.id)) {
        await store.markCompleted('ql_level', '${level.id}', xp: 0);
      }
    }
    final letters = _count(snap, 'ql_letter');
    final harakat = _count(snap, 'ql_haraka');
    final words = _count(snap, 'ql_word');
    final surahs = _count(snap, 'ql_surah');
    final tajweed = _count(snap, 'ql_tajweed');
    final practice = _count(snap, 'ql_practice') + _count(snap, 'ql_tajweed_read');
    final activities = snap.completedKeys
        .where((key) => key.startsWith('ql_'))
        .length;
    for (final badge in pack.badges) {
      final value = switch (badge.ruleType) {
        'letters_completed' => letters,
        'audio_plays' => snap.audioPlays,
        'harakat_lessons_completed' => harakat,
        'combinations_correct' => snap.combinationsCorrect,
        'words_completed' => words,
        'surah_completed' => surahs,
        'tajweed_completed' => tajweed,
        'reading_practice_completed' => practice,
        'daily_streak' => snap.streak,
        'learning_activities_completed' => activities,
        _ => 0,
      };
      if (value >= badge.ruleValue) {
        await store.awardBadge(badge.id);
      }
    }
  }

  static int _count(QuranLearnSnapshot snap, String kind) {
    return snap.completedKeys.where((key) => key.startsWith('$kind|')).length;
  }
}
