import '../../core/utils/json_map.dart';

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.version,
    required this.minimumAge,
    required this.theme,
    required this.features,
    required this.featureFlags,
    required this.contentFiles,
    required this.assetRoot,
    this.firstLaunchTitle = '',
    this.firstLaunchButton = '',
    this.firstLaunchLines = const [],
  });

  final String appName;
  final String version;
  final int minimumAge;
  final String theme;
  final List<String> features;
  final Map<String, bool> featureFlags;
  final Map<String, String> contentFiles;
  final String assetRoot;
  final String firstLaunchTitle;
  final String firstLaunchButton;
  final List<String> firstLaunchLines;

  bool isEnabled(String feature) => featureFlags[feature] ?? true;

  String contentPath(String key, String fallback) =>
      contentFiles[key] ?? fallback;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final flagsRaw = JsonMap.object(json['featureFlags']);
    final filesRaw = JsonMap.object(json['contentFiles']);
    final featuresRaw = json['features'];
    final firstLaunch = JsonMap.object(json['firstLaunch']);
    return AppConfig(
      appName: JsonMap.str(json['appName'], 'Minik Kalpler'),
      version: JsonMap.str(json['version'], '1.0.0'),
      minimumAge: JsonMap.integer(json['minimumAge'], 4),
      theme: JsonMap.str(json['theme'], 'light'),
      features: featuresRaw is List
          ? featuresRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
      featureFlags: flagsRaw.map(
        (key, value) => MapEntry(key, JsonMap.flag(value, true)),
      ),
      contentFiles: filesRaw.map(
        (key, value) => MapEntry(key, JsonMap.str(value)),
      ),
      assetRoot: JsonMap.str(json['assetRoot'], 'assets/'),
      firstLaunchTitle: JsonMap.str(firstLaunch['title'], 'Haydi başlayalım'),
      firstLaunchButton: JsonMap.str(firstLaunch['button'], 'Anladım'),
      firstLaunchLines: JsonMap.strings(firstLaunch['lines']),
    );
  }

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'version': version,
        'minimumAge': minimumAge,
        'theme': theme,
        'features': features,
        'featureFlags': featureFlags,
        'contentFiles': contentFiles,
        'assetRoot': assetRoot,
        'firstLaunch': {
          'title': firstLaunchTitle,
          'button': firstLaunchButton,
          'lines': firstLaunchLines,
        },
      };
}
