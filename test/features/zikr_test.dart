import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/dhikr.dart';
import 'package:minik_kalpler/features/zikr/dhikr_feedback.dart';
import 'package:minik_kalpler/features/zikr/dhikr_logic.dart';
import 'package:minik_kalpler/features/zikr/dhikr_persistence.dart';
import 'package:minik_kalpler/features/zikr/dhikr_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('counter increments and never goes below zero', () {
    expect(DhikrCounterService.increment(0, 1), 1);
    expect(DhikrCounterService.increment(32, 1), 33);
    expect(DhikrCounterService.decrement(1, 1), 0);
    expect(DhikrCounterService.decrement(0, 1), 0);
    expect(DhikrCounterService.increment(0, 5), 5);
  });

  test('progress is capped at 100 percent while count can pass the target', () {
    expect(DhikrCounterService.progress(33, 33), 1);
    expect(DhikrCounterService.progress(42, 33), 1);
    expect(DhikrCounterService.justCompleted(previous: 32, current: 33, target: 33), isTrue);
    expect(DhikrCounterService.justCompleted(previous: 33, current: 34, target: 33), isFalse);
  });

  test('vibrationEvery pulses only on exact multiples', () {
    expect(DhikrCounterService.shouldPulse(32, 33), isFalse);
    expect(DhikrCounterService.shouldPulse(33, 33), isTrue);
    expect(DhikrCounterService.shouldPulse(34, 33), isFalse);
    expect(DhikrCounterService.shouldPulse(65, 33), isFalse);
    expect(DhikrCounterService.shouldPulse(66, 33), isTrue);
    expect(DhikrCounterService.shouldPulse(0, 33), isFalse);
  });

  test('soundEvery uses the same interval rule', () {
    expect(DhikrCounterService.shouldPulse(10, 10), isTrue);
    expect(DhikrCounterService.shouldPulse(11, 10), isFalse);
    expect(DhikrCounterService.shouldPulse(20, 10), isTrue);
  });

  test('store persists count, pause, favorite, session and daily stats', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = DhikrStore(
      persistence: DhikrPersistenceService(prefs: prefs),
      feedback: DhikrFeedbackService(silent: true),
    );
    store.debugSetItems(const [
      Dhikr(id: 'subhanallah', title: 'Sübhânallah', targetCount: 33),
    ]);

    var result = await store.addCount('subhanallah', step: 1);
    expect(result.dhikr.currentCount, 1);
    expect(result.completed, isFalse);
    expect(store.lastUsed?.id, 'subhanallah');

    await store.pause('subhanallah');
    expect(store.paused?.currentCount, 1);
    expect(store.byId('subhanallah')?.isPaused, isTrue);

    await store.toggleFavorite('subhanallah');
    expect(store.byId('subhanallah')?.isFavorite, isTrue);

    for (var i = 0; i < 32; i++) {
      result = await store.addCount('subhanallah');
    }
    expect(result.completed, isTrue);
    expect(result.session?.target, 33);
    expect(store.byId('subhanallah')?.isCompleted, isTrue);
    expect(store.byId('subhanallah')?.totalCount, 33);
    expect(store.todayCompletedCount('subhanallah'), 1);

    await store.resetCurrent('subhanallah');
    expect(store.byId('subhanallah')?.currentCount, 0);
    expect(store.byId('subhanallah')?.totalCount, 33);

    final overview = store.overview();
    expect(overview.todayCount, 33);
    expect(overview.totalCount, 33);
    expect(overview.favoriteCount, 1);
  });
}
