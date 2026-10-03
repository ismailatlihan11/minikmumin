import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/asset_catalog.dart';
import '../../core/audio/audio_player_service.dart';

class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    required this.audio,
    required this.path,
    this.iconStyle = false,
    this.repeat = 1,
  });

  final AudioPlayerService audio;
  final String path;
  final bool iconStyle;
  final int repeat;

  @override
  Widget build(BuildContext context) {
    if (!AssetCatalog.contains(path)) return const SizedBox.shrink();
    return StreamBuilder<bool>(
      stream: audio.playingStream,
      initialData: audio.isPlaying,
      builder: (context, snapshot) {
        final playing = (snapshot.data ?? false) && audio.currentAsset == path;
        final icon = playing ? Icons.stop_rounded : Icons.volume_up_rounded;
        final label = playing ? 'Durdur' : 'Dinle';
        if (iconStyle) {
          return FilledButton.icon(
            onPressed: () => audio.toggleAsset(path, repeat: repeat),
            icon: Icon(icon),
            label: Text(label),
          );
        }
        return SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => audio.toggleAsset(path, repeat: repeat),
            style: FilledButton.styleFrom(
              backgroundColor: MinikColors.greenSoft,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            icon: Icon(icon),
            label: Text(label),
          ),
        );
      },
    );
  }
}
