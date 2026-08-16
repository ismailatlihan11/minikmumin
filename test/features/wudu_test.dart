import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/interactive_lesson.dart';
import 'package:minik_kalpler/features/wudu/wudu_presentation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';

void main() {
  LessonStep step(String id, String title, int order) => LessonStep(
        id: id,
        order: order,
        title: title,
        description: 'Abdestin bu aşamasını öğren.',
      );

  test('practice choices include the current step exactly once', () {
    final steps = [
      step('hands', 'Eller', 1),
      step('mouth', 'Ağız', 2),
      step('nose', 'Burun', 3),
    ];
    final choices = WuduPresentation.practiceChoices(
      steps: steps,
      currentIndex: 0,
      random: Random(4),
    );
    expect(choices, hasLength(3));
    expect(choices.where((item) => item.id == 'hands'), hasLength(1));
  });

  test('generic JSON description is replaced with a child prompt', () {
    final prompt = WuduPresentation.promptFor(step('hands', 'Eller', 1));
    expect(prompt, contains('Eller'));
    expect(prompt, isNot(contains('Abdestin bu aşamasını öğren')));
  });

  test('wudu progress is stored locally', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalProgressStore(prefs: await SharedPreferences.getInstance());
    await store.saveWuduStep(2);
    var progress = await store.getWuduProgress();
    expect(progress.inProgress, isTrue);
    expect(progress.stepIndex, 2);

    await store.markWuduCompleted();
    progress = await store.getWuduProgress();
    expect(progress.completed, isTrue);
    expect(await store.getCompletedLessons(), contains('wudu'));
    expect(await store.getBadges(), contains('first_lesson'));
  });
}
