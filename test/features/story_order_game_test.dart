import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/story.dart';
import 'package:minik_kalpler/features/games/order_game_page.dart';

StoryItem _story(String id, int sceneCount) {
  return StoryItem(
    id: id,
    title: id,
    summary: '',
    category: 'peygamber_kissalari',
    scenes: [
      for (var i = 1; i <= sceneCount; i++)
        StoryScene(order: i, title: 'Sahne $i', text: 'Metin'),
    ],
  );
}

void main() {
  test('kıssa sahneleri uses every story that has at least three scenes', () {
    final playable = playableStoryOrderItems([
      _story('short', 2),
      _story('adem', 4),
      _story('nuh', 4),
      _story('kabe', 3),
    ]);
    expect(playable.map((item) => item.id), ['adem', 'nuh', 'kabe']);
  });
}
