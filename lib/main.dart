import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/constants/app_constants.dart';
import 'app/navigation/minik_shell.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'core/audio/asset_catalog.dart';
import 'core/storage/local_progress_store.dart';
import 'data/repositories/content_repositories.dart';
import 'features/zikr/dhikr_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  LicenseRegistry.addLicense(_contentLicenses);
  final themeController = await ThemeController.load();
  await AssetCatalog.load();
  runApp(MinikKalplerApp(themeController: themeController));
}

Stream<LicenseEntry> _contentLicenses() async* {
  yield const LicenseEntryWithLineBreaks(
    ['Esmaül Hüsna sesleri (esmaulhusna_muslimbg)'],
    '''MIT License

Copyright (c) 2024 Cemal Karabulaklı

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
  );
}

class MinikKalplerApp extends StatelessWidget {
  const MinikKalplerApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ContentRepositories()),
        ChangeNotifierProvider(create: (_) => LocalProgressStore()),
        ChangeNotifierProvider(create: (_) => DhikrStore()..restore()),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: ThemeRefreshScope(
        controller: themeController,
        child: Consumer<ThemeController>(
          builder: (context, controller, _) => MaterialApp(
            title: AppConstants.defaultAppName,
            debugShowCheckedModeBanner: false,
            theme: MinikTheme.current(),
            darkTheme: MinikTheme.current(),
            // The palette, not the system setting, decides light or dark.
            themeMode: controller.isDark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => MinikTheme.themed(
              child ?? const SizedBox.shrink(),
            ),
            home: const MinikShell(),
            routes: minikRoutes(),
          ),
        ),
      ),
    );
  }
}
