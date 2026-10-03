import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/navigation/minik_shell.dart';
import 'package:minik_kalpler/app/routes.dart';
import 'package:minik_kalpler/app/theme/app_theme.dart';
import 'package:minik_kalpler/app/theme/theme_controller.dart';
import 'package:minik_kalpler/core/audio/asset_catalog.dart';
import 'package:minik_kalpler/core/storage/local_progress_store.dart';
import 'package:minik_kalpler/data/repositories/content_repositories.dart';
import 'package:minik_kalpler/features/zikr/dhikr_store.dart';
import 'package:minik_kalpler/shared/widgets/minik_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every main screen in light and dark mode into `build/screens/`.
///
/// `flutter test --dart-define=SCREENSHOTS=true test/visual/theme_screens_test.dart`
///
/// Add `--dart-define=TEXT_SCALE=1.3` to look for overflow with large text.
const _enabled = bool.fromEnvironment('SCREENSHOTS');
const _textScale = String.fromEnvironment('TEXT_SCALE', defaultValue: '1');
const _only = String.fromEnvironment('ONLY');
const _modes = String.fromEnvironment('MODES', defaultValue: 'light,dark');
const _skip = String.fromEnvironment('SKIP');

const _screens = <String, String>{
  'home': '/',
  'learn': AppRoutes.learn,
  'basics': AppRoutes.learnBasics,
  'ilmihal': AppRoutes.learnIlmihal,
  'wudu': AppRoutes.learnWudu,
  'prayer': AppRoutes.learnPrayer,
  'prayer_duas': AppRoutes.learnPrayerDuas,
  'duas': AppRoutes.learnDuas,
  'asma': AppRoutes.learnAsma,
  'prophets': AppRoutes.learnProphets,
  'prophets_stories': AppRoutes.learnProphetsStories,
  'stories': AppRoutes.learnStories,
  'morality': AppRoutes.learnMorality,
  'quran_learn': AppRoutes.learnQuran,
  'elifba': AppRoutes.learnElifbaAdventure,
  'quran': AppRoutes.quran,
  'hadith': AppRoutes.hadith,
  'games': AppRoutes.games,
  'zikr': AppRoutes.zikr,
  'daily_task': AppRoutes.dailyTask,
  'favorites': AppRoutes.favorites,
  'profile': AppRoutes.profile,
  'settings': AppRoutes.settings,
  'quiz': AppRoutes.quiz,
  'search': AppRoutes.search,
};

/// Inner pages: start route, then texts to tap in order.
const _flows = <String, (String, List<String>)>{
  'basics_item': (AppRoutes.learnBasics, ['İlk Adım', 'İslam Nedir?']),
  'basics_section': (AppRoutes.learnBasics, ['İnanç']),
  'basics_sunnah': (AppRoutes.learnBasics, ['İnanç', 'Sünnet Nedir?']),
  'basics_shahada': (AppRoutes.learnBasics, ['İlk Adım', 'Şehadet Nedir?']),
  'morality_detail': (AppRoutes.learnMorality, ['Temel Değerler', '#0']),
  'morality_learned': (
    AppRoutes.learnMorality,
    ['Temel Değerler', '#3', 'Öğrendim'],
  ),
  'story_detail': (AppRoutes.learnStories, ['Tüm kıssalar', '#0']),
  'dua_detail': (AppRoutes.learnDuas, ['Aksırınca']),
  'zikr_counter': (AppRoutes.zikr, ['Allahümme Ente']),
  'order_game': (AppRoutes.games, ['Abdest Sırası']),
  'prayer_order_game': (AppRoutes.games, ['Namaz Sırası']),
  'match_game': (AppRoutes.games, ['Harf Eşleştir']),
  'quiz_play': (AppRoutes.quiz, ['Karışık sorular']),
  'prophet_detail': (AppRoutes.learnProphets, ['Hz. Âdem']),
  'hadith_detail': (AppRoutes.hadith, ['#0']),
  'asma_detail': (AppRoutes.learnAsma, ['Er-Rahmân']),
  'elifba_map': (AppRoutes.learnElifbaAdventure, ['Ders Haritası']),
  'surah_list': (AppRoutes.quran, ['Ayet ve meal']),
  'ilmihal_topic': (AppRoutes.learnIlmihal, ['Temizlik']),
  'prayer_start': (AppRoutes.learnPrayer, ['Başlayalım']),
  'prayer_step': (AppRoutes.learnPrayer, ['Niyet']),
  'prayer_step_next': (
    AppRoutes.learnPrayer,
    ['Niyet', 'Sonraki adıma geç'],
  ),
  'prayer_step_prev': (
    AppRoutes.learnPrayer,
    ['Niyet', 'Sonraki adıma geç', 'Önceki adım'],
  ),
  'prayer_ruku': (AppRoutes.learnPrayer, ['Rükûya Allahu ekber']),
  'wudu_step': (AppRoutes.learnWudu, ['Besmele ile Başlayalım']),
  'wudu_step_next': (
    AppRoutes.learnWudu,
    ['Besmele ile Başlayalım', 'Sonraki adım'],
  ),
  'parent_gate': (AppRoutes.settings, ['Öğrenme kilitlerini aç']),
  'search_results': (AppRoutes.search, ['=yemek']),
  'search_open': (AppRoutes.search, ['=aksirinca', 'Aksırınca']),
};

Future<void> _tapText(WidgetTester tester, String text) async {
  if (text.startsWith('=')) {
    await tester.enterText(find.byType(TextField).first, text.substring(1));
    await tester.pump(const Duration(milliseconds: 400));
    await _settle(tester);
    return;
  }
  final Finder finder;
  if (text.startsWith('#')) {
    finder = find.byType(ContentTile).at(int.parse(text.substring(1)));
  } else if (text.startsWith('@')) {
    finder = find.byTooltip(text.substring(1)).first;
  } else {
    final matches = find.textContaining(text);
    finder = matches.first;
    final scrollables = find.byType(Scrollable).evaluate().length;
    for (var i = 0; i < scrollables && matches.evaluate().isEmpty; i++) {
      try {
        await tester.scrollUntilVisible(
          matches,
          300,
          scrollable: find.byType(Scrollable).at(i),
          maxScrolls: 20,
        );
      } on StateError {
        // This scrollable never reveals the text; try the next one.
      }
    }
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder, warnIfMissed: false);
  await _settle(tester);
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    loader.addFont(
        Future.value(File(path).readAsBytesSync().buffer.asByteData()));
  }
  await loader.load();
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 60; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
    if (i >= 4 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
  }
  final images = tester.widgetList<Image>(find.byType(Image)).toList();
  final context = tester.element(find.byType(Navigator).first);
  await tester.runAsync(() async {
    for (final image in images) {
      try {
        await precacheImage(image.image, context);
      } catch (_) {}
    }
  });
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _capture(WidgetTester tester, Key key, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_enabled) return;
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.path;
    await _loadFont('NotoSans', [
      'assets/fonts/NotoSans-Regular.ttf',
      'assets/fonts/NotoSans-Bold.ttf',
    ]);
    await _loadFont(
        'NotoNaskhArabic', ['assets/fonts/NotoNaskhArabic-Regular.ttf']);
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
    await AssetCatalog.load();
    // Large strings are decoded with compute(), which never finishes inside
    // the fake-async test zone; warm rootBundle's cache in real time instead.
    for (final file in Directory('assets/data').listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.json')) {
        await rootBundle.loadString(file.path);
      }
    }
  });

  final all = <String, (String, List<String>)>{
    for (final e in _screens.entries) e.key: (e.value, const <String>[]),
    ..._flows,
  };
  for (final dark in [false, true]) {
    for (final entry in all.entries) {
      final mode = dark ? 'dark' : 'light';
      if (!_modes.split(',').contains(mode)) continue;
      if (_only.isNotEmpty) {
        if (!_only.split(',').contains(entry.key)) continue;
      } else if (_skip.split(',').contains(entry.key)) {
        continue;
      }
      final (route, taps) = entry.value;
      testWidgets('$mode ${entry.key}', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({
          'minik_dark_mode': dark,
        });
        final controller = (await tester.runAsync(ThemeController.load))!;
        final problems = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('MissingPluginException')) return;
          var line = text.split('\n').first;
          if (line.contains('overflowed')) {
            final where = RegExp(r'(lib/[\w/]+\.dart:\d+)')
                .firstMatch(details.toString());
            if (where != null) line = '$line @ ${where.group(1)}';
          }
          problems.add(line);
        };
        try {
          const key = ValueKey('shot');
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: MultiProvider(
                providers: [
                  Provider(create: (_) => ContentRepositories()),
                  ChangeNotifierProvider(create: (_) => LocalProgressStore()),
                  ChangeNotifierProvider(
                      create: (_) => DhikrStore()..restore()),
                  ChangeNotifierProvider.value(value: controller),
                ],
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: MinikTheme.current(),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(double.parse(_textScale)),
                    ),
                    child: MinikTheme.themed(child!),
                  ),
                  initialRoute: route,
                  routes: {
                    '/': (_) => const MinikShell(),
                    ...minikRoutes(),
                  },
                ),
              ),
            ),
          );
          await _settle(tester);
          for (final tap in taps) {
            await _tapText(tester, tap);
          }
          const suffix = _textScale == '1' ? '' : '_x$_textScale';
          await _capture(
              tester, key, 'build/screens/$mode$suffix/${entry.key}.png');
        } catch (e) {
          problems.add('FLOW FAILED: $e'.split('\n').first);
        } finally {
          FlutterError.onError = previous;
        }
        if (problems.isNotEmpty) {
          // ignore: avoid_print
          print('PROBLEMS $mode ${entry.key}: ${problems.toSet().join(' | ')}');
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      }, skip: !_enabled);
    }
  }
}
