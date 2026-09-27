import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/theme/app_colors.dart';
import 'package:minik_kalpler/app/theme/theme_controller.dart';
import 'package:minik_kalpler/main.dart';
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
}
