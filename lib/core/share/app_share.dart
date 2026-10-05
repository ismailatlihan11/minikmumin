import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/widgets/parental_gate.dart';

abstract final class AppShare {
  static const storeUrl =
      'https://play.google.com/store/apps/details?id=com.minikkalpler.minik_kalpler';

  static const message =
      'Minik Mümin: çocuklar için Elifbâ, Kur’an, namaz, abdest, dua ve '
      'zikirleri oyunlarla öğreten uygulama. İnternetsiz çalışır, reklam yok.\n'
      '$storeUrl';

  /// Opening other apps from a kids app has to sit behind the parental gate.
  static Future<void> shareApp(BuildContext context) async {
    if (!await confirmParent(context)) return;
    if (!context.mounted) return;
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
