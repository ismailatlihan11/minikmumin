import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/theme/app_theme.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: MinikTheme.current(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('detay')),
                  ),
                ),
                child: const Text('aç'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    expect(find.text('detay'), findsOneWidget);
  }

  Future<void> swipeFromLeftEdge(WidgetTester tester, Size size) async {
    final gesture = await tester.startGesture(Offset(4, size.height / 2));
    await gesture.moveBy(Offset(size.width * 0.3, 0));
    await gesture.moveBy(Offset(size.width * 0.3, 0));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  for (final size in const [Size(820, 1180), Size(1180, 820), Size(390, 844)]) {
    testWidgets('iOS kenardan kaydırınca geri döner ($size)', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pumpApp(tester, size);
      await swipeFromLeftEdge(tester, size);
      expect(find.text('detay'), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
