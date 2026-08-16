import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/interactive_lesson.dart';
import 'package:minik_kalpler/features/wudu/wudu_presentation.dart';
import 'package:minik_kalpler/features/wudu/wudu_visual_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/data/models/hadith.dart';

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

  test('visual catalog has thirteen illustrated steps', () {
    expect(WuduVisualCatalog.steps, hasLength(13));
    expect(WuduVisualCatalog.steps.first.id, 'niyet');
    expect(WuduVisualCatalog.steps.last.id, 'tamam');
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

  test('continue, favorites and completions persist', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalProgressStore(prefs: await SharedPreferences.getInstance());
    await store.setContinue(
      title: 'Dualar',
      subtitle: 'Rabbana',
      route: '/minik/learn/duas',
      progress: 0.4,
    );
    final point = await store.getContinue();
    expect(point?.route, '/minik/learn/duas');
    expect(point?.progress, 0.4);

    const favorite = FavoriteEntry(kind: 'dua', id: 'rabbana', title: 'Rabbana');
    await store.toggleFavorite(favorite);
    expect(await store.isFavorite('dua', 'rabbana'), isTrue);
    await store.toggleFavorite(favorite);
    expect(await store.isFavorite('dua', 'rabbana'), isFalse);

    await store.markCompleted('dua', 'rabbana', xp: 5);
    expect(await store.isCompleted('dua', 'rabbana'), isTrue);
    expect(await store.getXp(), 5);
    expect(await store.getBadges(), contains('first_dua'));
    await store.markCompleted('dua', 'rabbana', xp: 5);
    expect(await store.getXp(), 5);
  });

  test('short hadiths stay under the child length limit', () {
    const short = Hadith(id: '1', arabic: 'ا', turkish: 'Kısa hadis metni.');
    const longTurkish =
        'Bu oldukça uzun bir hadis mealidir. Çocuk süzgecinde kalmaması için metin dört yüz yirmi karakteri geçmeli. '
        'Kısa hadisler varsayılan olarak gösterilir, uzun olanlar ise anahtarla açılır. '
        'Bu cümleleri tekrar ederek uzunluğu artırıyoruz: sabır, merhamet, doğru söz ve güzel ahlak üzerine kurulmuş bir hayat. '
        'Bir çocuk uygulamasında uzun metinler yorucu olabilir, bu yüzden süzgeç metin uzunluğuna bakar, hadis uydurmaz. '
        'Son ek olarak eşiği net geçmek için birkaç kelime daha ekliyoruz.';
    const long = Hadith(id: '2', arabic: 'ا', turkish: longTurkish);
    expect(short.plainTurkish.length, lessThanOrEqualTo(420));
    expect(long.plainTurkish.length, greaterThan(420));
  });
}
