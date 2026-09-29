import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/app/constants/content_assets.dart';
import 'package:minik_kalpler/data/models/prophet.dart';

void main() {
  test('every prophet resolves to its own bundled image', () {
    final raw = jsonDecode(File('assets/data/prophets.json').readAsStringSync());
    final rows = (raw is List ? raw : (raw['prophets'] ?? raw['items'])) as List;
    expect(rows, isNotEmpty);
    for (final row in rows) {
      final prophet = Prophet.fromJson(row as Map<String, dynamic>);
      final path = ContentAssets.prophetImage(
        prophet.name,
        id: prophet.id,
        jsonPath: prophet.image,
      );
      expect(path, isNot(endsWith('/prophets.png')), reason: prophet.id);
      expect(File(path).existsSync(), isTrue, reason: '${prophet.id}: $path');
    }
  });

  test('prophet image map points at existing files', () {
    for (final entry in ContentAssets.prophetImages.entries) {
      expect(File(entry.value).existsSync(), isTrue, reason: entry.key);
    }
  });
}
