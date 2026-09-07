import '../../data/models/app_config.dart';

/// Compile-time switch for the trial Elifbâ + Tecvid series.
/// JSON `featureFlags.elifbaTecvid` can still turn it off without a rebuild.
abstract final class ElifbaFlags {
  static const bool enableElifbaTecvid = true;
  static const String configKey = 'elifbaTecvid';

  static bool isEnabled(AppConfig? config) {
    if (!enableElifbaTecvid) return false;
    return config?.isEnabled(configKey) ?? true;
  }
}
