import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/data/models/quran_learning.dart';
import 'package:minik_kalpler/features/quran_learn/quran_learn_audio.dart';

void main() {
  test('builds passage ids without colliding Bakara entries', () {
    const bakara15 = QuranLearningSurah(
      surahNumber: 2,
      nameAr: 'البقرة',
      nameTr: 'Bakara 1–5',
      ayahCount: 5,
      priority: 2,
      ayahFrom: 1,
      ayahTo: 5,
    );
    const kursi = QuranLearningSurah(
      surahNumber: 2,
      nameAr: 'البقرة',
      nameTr: "Âyetü'l-Kürsî",
      ayahCount: 1,
      priority: 14,
      ayahFrom: 255,
      ayahTo: 255,
    );
    const fatiha = QuranLearningSurah(
      surahNumber: 1,
      nameAr: 'الفاتحة',
      nameTr: 'Fâtiha',
      ayahCount: 7,
      priority: 1,
    );
    expect(bakara15.id, '2-1-5');
    expect(kursi.id, '2-255');
    expect(fatiha.id, '1');
    expect(bakara15.listSubtitle, contains('2:1–5'));
  });

  test('pack follows Diyanet Elif-Ba readings, letter count and order', () {
    final json = jsonDecode(
      File('assets/data/kur_an_ogrenme_veri_paketi.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final pack = QuranLearningPack.fromJson(json);

    final fatha = pack.harakaById('fatha')!;
    expect(fatha.readingRule, contains("İnce harfleri 'e'"));
    String reading(QuranHaraka haraka, String arabic) =>
        haraka.examples.firstWhere((e) => e.arabic == arabic).reading;
    expect(reading(fatha, 'بَ'), 'be');
    expect(reading(fatha, 'طَ'), 'ta (kalın)');
    expect(reading(pack.harakaById('kasra')!, 'قِ'), 'kı (kalın)');

    expect(pack.alphabetLetters.length, 28);
    expect(pack.letters.last.isLigature, isTrue);
    expect(pack.itemsForLevel(1).length, 28);

    expect(pack.tajweed.first.id, 'tajweed_12');
    expect(
      pack.tajweed.map((lesson) => lesson.id).take(4),
      ['tajweed_12', 'tajweed_10', 'tajweed_13', 'tajweed_14'],
    );
  });

  test('tajweed example audio uses a unique clip per example', () {
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_08',
        index: 0,
        jsonAudio: 'assets/audio/quran_learn/tajweed/ihfa.mp3',
      ),
      'assets/audio/quran_learn/tajweed/tajweed_08_1.mp3',
    );
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_15',
        index: 0,
        jsonAudio: 'assets/audio/quran_learn/tajweed/idgham.mp3',
      ),
      'assets/audio/quran_learn/tajweed/tajweed_15_1.mp3',
    );
    expect(
      QuranLearnAudio.tajweedExamplePath(
        'tajweed_07',
        index: 1,
        jsonAudio: null,
      ),
      'assets/audio/quran_learn/tajweed/tajweed_07_2.mp3',
    );
  });
}
