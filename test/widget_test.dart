import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/theme/app_colors.dart';
import 'package:minik_kalpler/app/theme/theme_controller.dart';
import 'package:minik_kalpler/main.dart';
import 'package:minik_kalpler/shared/widgets/minik_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Minik Mümin starts without errors', (WidgetTester tester) async {
    final controller = await ThemeController.load();
    await tester.pumpWidget(MinikKalplerApp(themeController: controller));
    expect(find.byType(MinikKalplerApp), findsOneWidget);
  });

  testWidgets('dark mode switches the palette and persists', (tester) async {
    final controller = await ThemeController.load();
    await tester.pumpWidget(MinikKalplerApp(themeController: controller));
    expect(MinikColors.isDark, isFalse);

    await controller.setDark(true);
    await tester.pump();
    expect(MinikColors.isDark, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('minik_dark_mode'), isTrue);

    await controller.setDark(false);
    await tester.pump();
    expect(MinikColors.isDark, isFalse);
  });

  testWidgets('open screens repaint immediately when dark mode toggles',
      (tester) async {
    final controller = await ThemeController.load();
    await tester.pumpWidget(
      ThemeRefreshScope(
        controller: controller,
        child: const MaterialApp(
          home: Scaffold(body: MinikCard(child: Text('Kart'))),
        ),
      ),
    );
    Color cardColor() => tester
        .widget<Material>(
          find
              .ancestor(of: find.text('Kart'), matching: find.byType(Material))
              .first,
        )
        .color!;

    expect(cardColor(), MinikColors.surface);
    final light = cardColor();

    await controller.setDark(true);
    await tester.pump();
    expect(cardColor(), isNot(light));
    expect(cardColor(), MinikColors.surface);
    expect(MinikColors.text.computeLuminance(), greaterThan(0.5));

    await controller.setDark(false);
    await tester.pump();
    expect(cardColor(), light);
  });

  test('dark mode is restored on the next launch', () async {
    SharedPreferences.setMockInitialValues({'minik_dark_mode': true});
    final controller = await ThemeController.load();
    expect(controller.isDark, isTrue);
    expect(MinikColors.isDark, isTrue);
    await controller.setDark(false);
  });
}
