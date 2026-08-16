import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/constants/app_constants.dart';
import 'app/navigation/minik_shell.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'core/storage/local_progress_store.dart';
import 'data/repositories/content_repositories.dart';
import 'features/zikr/dhikr_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: MinikColors.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MinikKalplerApp());
}

class MinikKalplerApp extends StatelessWidget {
  const MinikKalplerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ContentRepositories()),
        ChangeNotifierProvider(create: (_) => LocalProgressStore()),
        ChangeNotifierProvider(create: (_) => DhikrStore()..restore()),
      ],
      child: MaterialApp(
        title: AppConstants.defaultAppName,
        debugShowCheckedModeBanner: false,
        theme: MinikTheme.light(),
        darkTheme: MinikTheme.dark(),
        themeMode: ThemeMode.system,
        home: const MinikShell(),
        routes: minikRoutes(),
      ),
    );
  }
}
