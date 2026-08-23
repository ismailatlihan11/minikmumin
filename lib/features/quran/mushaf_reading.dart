import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/storage/local_progress_store.dart';
import 'mushaf_decor.dart';

void showMushafReadingSheet({
  required BuildContext context,
  required LocalProgressStore store,
  required double fontSize,
  required bool fingerFollow,
  required void Function(double font, bool follow) onChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: MinikColors.nightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      var font = fontSize;
      var follow = fingerFollow;
      return StatefulBuilder(
        builder: (context, setLocal) {
          void update({double? f, bool? g}) {
            if (f != null) {
              font = f.clamp(
                LocalProgressStore.mushafFontMin,
                LocalProgressStore.mushafFontMax,
              );
            }
            if (g != null) follow = g;
            setLocal(() {});
            onChanged(font, follow);
            store.setMushafFontSize(font);
            store.setMushafFingerFollow(follow);
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kMushafGold.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'Okuma',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yazı boyutu',
                  style: TextStyle(
                    color: Color(0xFFD4C4A0),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Küçült',
                      onPressed: () => update(f: font - 2),
                      icon: const Icon(Icons.text_decrease, color: kMushafGold),
                    ),
                    Expanded(
                      child: Slider(
                        value: font,
                        min: LocalProgressStore.mushafFontMin,
                        max: LocalProgressStore.mushafFontMax,
                        divisions: 9,
                        label: font.round().toString(),
                        activeColor: kMushafGold,
                        inactiveColor: kMushafGold.withValues(alpha: 0.25),
                        onChanged: (v) => update(f: v),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Büyüt',
                      onPressed: () => update(f: font + 2),
                      icon: const Icon(Icons.text_increase, color: kMushafGold),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Elle takip',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Dokunarak veya parmağını kaydırarak ayeti boya',
                    style: TextStyle(
                      color: Color(0xFFD4C4A0),
                      fontSize: 12,
                    ),
                  ),
                  value: follow,
                  activeThumbColor: kMushafGold,
                  activeTrackColor: kMushafGold.withValues(alpha: 0.45),
                  onChanged: (v) => update(g: v),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
