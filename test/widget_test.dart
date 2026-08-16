import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Minik Mümin starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MinikKalplerApp());
    expect(find.byType(MinikKalplerApp), findsOneWidget);
  });
}
