import 'package:flutter/services.dart';

import '../../core/audio/audio_player_service.dart';
import '../../data/models/dhikr.dart';

class DhikrFeedbackService {
  DhikrFeedbackService({AudioPlayerService? audio, this.silent = false})
      : _audio = silent ? null : (audio ?? AudioPlayerService());

  final AudioPlayerService? _audio;
  final bool silent;

  Future<void> vibrate(DhikrSettings settings) async {
    if (silent || !settings.vibrationEnabled) return;
    try {
      switch (settings.vibrationIntensity) {
        case DhikrVibrationIntensity.light:
          await HapticFeedback.lightImpact();
        case DhikrVibrationIntensity.normal:
          await HapticFeedback.mediumImpact();
        case DhikrVibrationIntensity.strong:
          await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  Future<void> playClick(String path) async {
    if (silent) return;
    await _audio?.playAsset(path, waitUntilDone: false);
  }

  Future<void> dispose() async {
    await _audio?.dispose();
  }
}
