import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Kur'an Öğren screens use light pastel cards. Pin light theme so system
/// dark mode does not apply cream text on those surfaces.
Widget quranLearnThemed(Widget child) => MinikTheme.lightSurfaces(child);

MaterialPageRoute<T> quranLearnRoute<T extends Object?>(Widget page) {
  return MinikTheme.lightRoute(page);
}
