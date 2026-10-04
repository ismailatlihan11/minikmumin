import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_games.dart';

void main() {
  testWidgets('combine slots fill right to left like Arabic', (tester) async {
    var correct = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QlCombineBoard(
          parts: const ['أَ', 'بْ'],
          target: const ['أَ', 'بْ'],
          onCorrect: () => correct++,
          onWrong: () {},
        ),
      ),
    ));

    await tester.tap(find.text('أَ'));
    await tester.pump();
    await tester.tap(find.text('بْ'));
    await tester.pump();

    expect(correct, 1);
    expect(tester.getCenter(find.text('أَ')).dx,
        greaterThan(tester.getCenter(find.text('بْ')).dx));
  });
}
