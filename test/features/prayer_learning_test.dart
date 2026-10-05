import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minik_kalpler/features/prayer/learning/prayer_learning_models.dart';
import 'package:minik_kalpler/features/prayer/prayer_visual_catalog.dart';

void main() {
  final data = PrayerLearningData.fromJson(
    jsonDecode(File('assets/data/prayer_learning.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final prayerDuaIds = {
    for (final item in (jsonDecode(
      File('assets/data/namaz_dualari.json').readAsStringSync(),
    ) as Map<String, dynamic>)['items'] as List)
      (item as Map<String, dynamic>)['id'] as String,
  };

  PrayerPlan prayer(String id) => data.byId(id)!;
  List<String> steps(String id, int rakah) =>
      prayer(id).rakahs.firstWhere((r) => r.number == rakah).steps;

  const lastSitting = [
    'son_oturus',
    'ettehiyyatu',
    'salli',
    'barik',
    'rabbenalar',
    'selam_sag',
    'selam_sol',
  ];

  test('all daily prayers are listed in order', () {
    expect(data.prayers.map((p) => p.id), [
      'sabah_sunnet',
      'sabah_farz',
      'ogle_ilk_sunnet',
      'ogle_farz',
      'ogle_son_sunnet',
      'ikindi_sunnet',
      'ikindi_farz',
      'aksam_farz',
      'aksam_son_sunnet',
      'yatsi_ilk_sunnet',
      'yatsi_farz',
      'yatsi_son_sunnet',
      'vitir',
    ]);
    for (final p in data.prayers) {
      expect(p.rakahs, hasLength(p.rakats), reason: p.id);
      expect(p.madhhab, 'hanafi');
      expect(p.niyet, isNotEmpty);
      expect(data.groups.map((g) => g.id), contains(p.group));
    }
  });

  test('every referenced step, visual and dua exists', () {
    final visuals = {for (final s in PrayerVisualCatalog.steps) s.id};
    for (final step in data.steps.values) {
      expect(visuals, contains(step.visual), reason: step.id);
      for (final dua in step.duaIds) {
        expect(prayerDuaIds, contains(dua), reason: '${step.id} → $dua');
      }
    }
    for (final p in data.prayers) {
      for (final r in p.rakahs) {
        for (final id in r.steps) {
          expect(data.steps.keys, contains(id), reason: '${p.id} r${r.number}');
        }
        if (r.surah != null) {
          expect(prayerDuaIds, contains('surah_${r.surah}'));
        }
        for (final tip in r.tips) {
          expect(r.steps, contains(tip.step), reason: '${p.id} tip');
        }
        for (final why in r.whys) {
          expect(r.steps, contains(why.step), reason: '${p.id} why');
        }
      }
      expect(data.flow(p).length,
          p.rakahs.fold<int>(0, (sum, r) => sum + r.steps.length));
    }
  });

  test('every prayer opens and closes correctly', () {
    for (final p in data.prayers) {
      final first = p.rakahs.first.steps;
      expect(
          first.take(6),
          [
            'niyet',
            'iftitah_tekbiri',
            'subhaneke',
            'euzu_besmele',
            'fatiha',
            'sure',
          ],
          reason: p.id);
      final last = p.rakahs.last.steps;
      expect(last.sublist(last.length - lastSitting.length), lastSitting,
          reason: '${p.id}: son oturuşta Salli/Barik/Rabbena/selam eksik');
      expect(
          'son_oturus'
              .allMatches(p.rakahs.map((r) => r.steps.join(',')).join(',')),
          hasLength(1),
          reason: '${p.id}: tek son oturuş olmalı');
      for (final r in p.rakahs) {
        final isLast = r == p.rakahs.last;
        expect(r.steps.contains('selam_sag'), isLast, reason: p.id);
        expect(r.steps.last == 'kalkis', !isLast, reason: p.id);
        if (r.number >= 2) expect(r.steps.contains('niyet'), isFalse);
      }
    }
  });

  test('first sitting only in rakah 2 of 3 and 4 rakah prayers', () {
    for (final p in data.prayers) {
      for (final r in p.rakahs) {
        final hasFirst = r.steps.contains('ilk_oturus');
        expect(hasFirst, p.rakats > 2 && r.number == 2,
            reason: '${p.id} r${r.number}');
      }
    }
  });

  test('farz prayers skip zamm-ı sûre after the second rakah', () {
    for (final id in ['ogle_farz', 'ikindi_farz', 'yatsi_farz', 'aksam_farz']) {
      final p = prayer(id);
      for (final r in p.rakahs) {
        expect(r.steps.contains('sure'), r.number <= 2,
            reason: '$id r${r.number}');
      }
      expect(steps(id, 2).contains('salli'), isFalse,
          reason: '$id: ilk oturuşta yalnız Ettehiyyâtü');
      expect(steps(id, 3).first, 'besmele');
    }
    for (final p in data.prayers.where((p) => p.type != 'farz')) {
      for (final r in p.rakahs) {
        expect(r.steps, contains('sure'), reason: '${p.id} r${r.number}');
      }
    }
  });

  test(
      'gayr-i müekkede sunnahs: Salli-Barik at first sitting, Sübhaneke in rakah 3',
      () {
    for (final id in ['ikindi_sunnet', 'yatsi_ilk_sunnet']) {
      expect(steps(id, 2).sublist(steps(id, 2).indexOf('ilk_oturus')),
          ['ilk_oturus', 'ettehiyyatu', 'salli', 'barik', 'kalkis'],
          reason: id);
      expect(
          steps(id, 3).take(4), ['subhaneke', 'euzu_besmele', 'fatiha', 'sure'],
          reason: id);
    }
  });

  test('öğle ilk sünnet is not confused with ikindi sünnet', () {
    expect(
        steps('ogle_ilk_sunnet', 2)
            .sublist(steps('ogle_ilk_sunnet', 2).indexOf('ilk_oturus')),
        ['ilk_oturus', 'ettehiyyatu', 'kalkis']);
    expect(steps('ogle_ilk_sunnet', 3).first, 'besmele');
    expect(steps('ogle_ilk_sunnet', 3).contains('subhaneke'), isFalse);
    for (var r = 2; r <= 4; r++) {
      expect(steps('ikindi_sunnet', r), isNot(steps('ikindi_farz', r)),
          reason: 'ikindi sünnet/farz r$r aynı olmamalı');
      expect(steps('yatsi_ilk_sunnet', r), isNot(steps('yatsi_farz', r)),
          reason: 'yatsı ilk sünnet/farz r$r aynı olmamalı');
      if (r < 4) {
        expect(steps('ogle_ilk_sunnet', r), isNot(steps('ikindi_sunnet', r)),
            reason: 'öğle ilk sünnet/ikindi sünnet r$r aynı olmamalı');
      }
    }
  });

  test('akşam farzı ends with the last sitting in rakah 3', () {
    final r3 = steps('aksam_farz', 3);
    expect(r3.take(2), ['besmele', 'fatiha']);
    expect(r3.contains('sure'), isFalse);
    expect(r3.contains('ilk_oturus'), isFalse);
    expect(r3, containsAllInOrder(lastSitting));
  });

  test('vitir: kunut tekbiri after the surah and before rükû in rakah 3', () {
    for (final r in prayer('vitir').rakahs) {
      expect(r.steps.contains('kunut_tekbiri'), r.number == 3);
      expect(r.steps.contains('kunut_dualari'), r.number == 3);
    }
    final r3 = steps('vitir', 3);
    expect(r3.take(6), [
      'besmele',
      'fatiha',
      'sure',
      'kunut_tekbiri',
      'kunut_dualari',
      'ruku',
    ]);
    expect(steps('vitir', 2).contains('salli'), isFalse);
    expect(prayer('vitir').type, 'vacip');
    final kunut = data.steps['kunut_dualari']!;
    expect(kunut.duaIds, ['kunut_1', 'kunut_2']);
    for (final p in data.prayers.where((p) => p.id != 'vitir')) {
      expect(p.rakahs.expand((r) => r.steps), isNot(contains('kunut_tekbiri')));
    }
  });

  test('flow attaches the rakah surah to the zamm-ı sûre step', () {
    final flow = data.flow(prayer('sabah_sunnet'));
    final sure = flow.where((item) => item.step.id == 'sure').toList();
    expect(sure.map((item) => item.duaIds.single), ['surah_109', 'surah_112']);
    expect(flow.first.step.id, 'niyet');
    expect(flow.where((item) => item.opensRakah), hasLength(2));
  });

  test('niyet texts follow the Diyanet wording', () {
    expect(prayer('ikindi_sunnet').niyet,
        'Niyet ettim Allah rızası için bugünkü ikindi namazının sünnetini kılmaya.');
    expect(prayer('yatsi_ilk_sunnet').niyet, contains('ilk sünnetini'));
    expect(prayer('ogle_son_sunnet').niyet, contains('son sünnetini'));
    expect(prayer('sabah_farz').niyet, contains('farzını'));
    expect(prayer('vitir').niyet,
        'Niyet ettim Allah rızası için vitir namazını kılmaya.');
  });
}
