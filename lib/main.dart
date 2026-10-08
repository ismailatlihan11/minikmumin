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
import 'shared/widgets/wide_screen_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final themeController = await ThemeController.load();
  await AssetCatalog.load();
  runApp(MinikKalplerApp(themeController: themeController));
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
            builder: (context, child) => WideScreenFrame(
              child: MinikTheme.themed(child ?? const SizedBox.shrink()),
            ),
            home: const MinikShell(),
            routes: minikRoutes(),
          ),
        ),
      ),
    );
  }
}
