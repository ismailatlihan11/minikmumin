import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/shared/widgets/parental_gate.dart';

Future<bool?> _open(WidgetTester tester) async {
  bool? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await confirmParent(context, random: Random(1));
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

(int, int) _question(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((t) => t.contains('×'));
  final match = RegExp(r'(\d+) × (\d+)').firstMatch(text)!;
  return (int.parse(match.group(1)!), int.parse(match.group(2)!));
}

Future<void> _type(WidgetTester tester, int value) async {
  for (final digit in '$value'.split('')) {
    await tester.tap(find.widgetWithText(InkWell, digit));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('correct answer closes the gate', (tester) async {
    await _open(tester);
    final (a, b) = _question(tester);
    await _type(tester, a * b);
    expect(find.text('Ebeveyn kontrolü'), findsNothing);
  });

  testWidgets('wrong answer keeps the gate and asks again', (tester) async {
    await _open(tester);
    final (a, b) = _question(tester);
    await _type(tester, a * b == 99 ? 98 : 99);
    expect(find.text('Ebeveyn kontrolü'), findsOneWidget);
    expect(find.text('Yanlış cevap, yeni soru geldi.'), findsOneWidget);
  });
}
