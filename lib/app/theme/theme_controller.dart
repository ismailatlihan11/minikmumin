import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

/// Holds the light/dark choice from Settings and persists it.
class ThemeController extends ChangeNotifier {
  ThemeController._(this._prefs);

  static const _key = 'minik_dark_mode';

  final SharedPreferences _prefs;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    MinikColors.applyDark(prefs.getBool(_key) ?? false);
    applySystemBars();
    return ThemeController._(prefs);
  }

  bool get isDark => MinikColors.isDark;

  Future<void> setDark(bool value) async {
    if (value == isDark) return;
    MinikColors.applyDark(value);
    applySystemBars();
    notifyListeners();
    await _prefs.setBool(_key, value);
  }

  static void applySystemBars() {
    final dark = MinikColors.isDark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: MinikColors.surface,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}

/// Palette colors are read at build time, so a theme switch has to rebuild
/// and repaint every element, including routes below the current page.
class ThemeRefreshScope extends StatefulWidget {
  const ThemeRefreshScope({
    super.key,
    required this.controller,
    required this.child,
  });

  final ThemeController controller;
  final Widget child;

  @override
  State<ThemeRefreshScope> createState() => _ThemeRefreshScopeState();
}

class _ThemeRefreshScopeState extends State<ThemeRefreshScope> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant ThemeRefreshScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    void visit(Element element) {
      element.markNeedsBuild();
      if (element is RenderObjectElement) {
        element.renderObject.markNeedsPaint();
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
