import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/parental_gate.dart';

abstract final class AppShare {
  static const androidUrl =
      'https://play.google.com/store/apps/details?id=com.minikmumin.app';

  /// Empty until the app is published there; empty stores are left out.
  static const appleUrl = 'https://apps.apple.com/app/id6820580909';
  static const huaweiUrl = '';

  static const _stores = [
    ('Android (Google Play)', androidUrl),
    ('Apple (App Store)', appleUrl),
    ('Huawei (AppGallery)', huaweiUrl),
  ];

  static String get message {
    final links = [
      for (final (label, url) in _stores)
        if (url.isNotEmpty) '$label:\n$url',
    ].join('\n\n');
    return 'Minik Mümin: çocuklar için Elifbâ, Kur’an, namaz, abdest, dua ve '
        'zikirleri oyunlarla öğreten uygulama. İnternetsiz çalışır, reklam yok.'
        '\n\n$links';
  }

  static Future<void> shareApp(BuildContext context) async {
    if (!await confirmParent(context) || !context.mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Minik Mümin',
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
