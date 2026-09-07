import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Şedde + hareke gösterimini görselleştirir; esrenin harfin altında
/// çıktığını doğrulamak için:
/// `flutter test --update-goldens test/arabic_shadda_render_test.dart`
void main() {
  setUpAll(() async {
    final bytes = File('assets/fonts/NotoNaskhArabic-Regular.ttf')
        .readAsBytesSync()
        .buffer
        .asByteData();
    await (FontLoader('NotoNaskhArabic')
          ..addFont(Future.value(bytes)))
        .load();
  });

  testWidgets('şedde + hareke gösterimi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(
              'بَّ  بِّ  بُّ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 96,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/shadda_harake.png'),
    );
  });
}
