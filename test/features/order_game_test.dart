import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/features/games/order_game_page.dart';
import 'package:minik_kalpler/features/prayer/prayer_visual_catalog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _host(List<OrderGameItem> items) {
  return ChangeNotifierProvider(
    create: (_) => LocalProgressStore(),
    child: MaterialApp(
      home: OrderGamePage(title: 'Sıra', prompt: 'Dokun', items: items),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('namaz sırası resolves every id and starts niyet, tekbir, sübhâneke',
      () {
    final steps = PrayerVisualCatalog.orderGameSteps;
    expect(steps.map((s) => s.id), PrayerVisualCatalog.orderGameIds);
    expect(steps.take(3).map((s) => s.id), ['niyet', 'tekbir', 'subhaneke']);
  });

  test('namaz sırası reads Fâtiha then a sure in both rekâts', () {
    final ids = PrayerVisualCatalog.orderGameIds;
    for (final (fatiha, sure) in [('fatiha', 'sure'), ('fatiha_r2', 'sure_r2')]) {
      expect(ids.indexOf(sure), ids.indexOf(fatiha) + 1);
    }
    expect(ids.indexOf('fatiha_r2'), ids.indexOf('ikinci_rekata_kalkis') + 1);
  });

  test('namaz sırası ends with selam to the right, then to the left', () {
    final ids = PrayerVisualCatalog.orderGameIds;
    expect(ids.sublist(ids.length - 2), ['selam_sag', 'selam_sol']);
  });

  testWidgets('wrong card warns, correct card gets a numbered badge',
      (tester) async {
    await tester.pumpWidget(_host(const [
      OrderGameItem(id: 'a', title: 'Niyet'),
      OrderGameItem(id: 'b', title: 'Tekbir'),
    ]));

    await tester.tap(find.text('Tekbir'));
    await tester.pump();
    expect(find.text('Sıra böyle değil, tekrar dene.'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.text('Niyet'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('cards with the same title are interchangeable', (tester) async {
    await tester.pumpWidget(_host(const [
      OrderGameItem(id: 'ruku1', title: 'Rükû'),
      OrderGameItem(id: 'secde', title: 'Secde'),
      OrderGameItem(id: 'ruku2', title: 'Rükû'),
    ]));

    // Whichever Rükû card is on top, tapping it counts as step one.
    await tester.tap(find.text('Rükû').last);
    await tester.pump();
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.tap(find.text('Secde'));
    await tester.pump();
    final remaining = find.ancestor(
      of: find.text('Rükû'),
      matching: find.byType(Row),
    );
    // Tap the Rükû card that has no badge yet.
    for (final row in remaining.evaluate()) {
      final hasBadge = find
          .descendant(of: find.byWidget(row.widget), matching: find.text('1'))
          .evaluate()
          .isNotEmpty;
      if (!hasBadge) {
        await tester.tap(find.byWidget(row.widget));
        break;
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('Maşallah!'), findsOneWidget);
  });
}
