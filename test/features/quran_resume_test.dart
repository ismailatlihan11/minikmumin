import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/constants/asset_paths.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/data/repositories/content_repositories.dart';
import 'package:minik_kalpler/features/quran/quran_page.dart';
import 'package:minik_kalpler/shared/widgets/minik_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final ayah in [150, 286, 3]) {
    testWidgets('ayet ve meal opens Bakara at ayah $ayah', (tester) async {
      SharedPreferences.setMockInitialValues({});
      // Decoding runs through compute(), which never finishes in fake async.
      await tester.runAsync(() async {
        await rootBundle.loadString(AssetPaths.appConfig);
        await rootBundle.loadString(AssetPaths.quran);
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider(create: (_) => ContentRepositories()),
            ChangeNotifierProvider(create: (_) => LocalProgressStore()),
          ],
          child: MaterialApp(
            home: QuranSurahPage(surahId: 2, initialAyahNo: ayah),
          ),
        ),
      );
      for (var i = 0; i < 40; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }

      final badge = find.widgetWithText(SoftBadge, '$ayah');
      expect(badge, findsOneWidget);
      final top = tester.getTopLeft(badge).dy;
      final screen =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(top, inInclusiveRange(0, ayah == 286 ? screen : screen / 2));
    });
  }
}
