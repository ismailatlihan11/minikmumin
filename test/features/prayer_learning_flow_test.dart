import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/data/repositories/content_repositories.dart';
import 'package:minik_kalpler/features/prayer/learning/prayer_learning_models.dart';
import 'package:minik_kalpler/features/prayer/learning/prayer_learning_pages.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final data = PrayerLearningData.fromJson(
    jsonDecode(File('assets/data/prayer_learning.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  Future<void> settle(WidgetTester tester, {int rounds = 10}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Widget host(Widget child) => MultiProvider(
        providers: [
          Provider(create: (_) => ContentRepositories()),
          ChangeNotifierProvider(create: (_) => LocalProgressStore()),
        ],
        child: MaterialApp(home: child),
      );

  testWidgets('vitir flow walks every rakah to completion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final vitir = data.byId('vitir')!;
    await tester.pumpWidget(
      host(PrayerPlanFlowPage(data: data, prayer: vitir)),
    );
    await settle(tester);

    expect(find.text('1. REKÂT'), findsOneWidget);
    expect(find.text('Vitir VACİP bir namazdır.'), findsOneWidget);
    expect(find.textContaining(vitir.niyet), findsOneWidget);

    final total = data.flow(vitir).length;
    var sawKunut = false;
    var sawThird = false;
    for (var i = 0; i < total; i++) {
      if (find.text('Kunut Tekbiri').evaluate().isNotEmpty) sawKunut = true;
      if (find.text('3. rekâta kalktın.').evaluate().isNotEmpty) {
        sawThird = true;
      }
      await tester.tap(find.text(i == total - 1 ? 'Bitir' : 'İleri'));
      await tester.pump();
    }
    expect(sawThird, isTrue);
    expect(sawKunut, isTrue);
    await settle(tester);
    expect(find.text('Namaz tamamlandı.'), findsOneWidget);
  });

  testWidgets('prayer list groups every daily prayer', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 6000);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(host(const PrayerPlanListPage()));
    await settle(tester);
    for (final title in ['SABAH', 'ÖĞLE', 'İKİNDİ', 'AKŞAM', 'YATSI']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('İkindi Sünneti — 4 Rekât'), findsOneWidget);
    expect(find.text('Vitir — 3 Rekât'), findsOneWidget);
  });
}
