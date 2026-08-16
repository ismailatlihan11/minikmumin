import 'dart:math';

import '../../data/models/dhikr.dart';

class ZikrCollectRound {
  const ZikrCollectRound({required this.target, required this.choices});

  final Dhikr target;
  final List<Dhikr> choices;
}

abstract final class ZikrCollectGame {
  static List<ZikrCollectRound> build(
    List<Dhikr> catalog, {
    int choiceCount = 4,
    Random? random,
  }) {
    final pool = [
      for (final item in catalog)
        if (item.meaning.trim().isNotEmpty && item.title.trim().isNotEmpty) item,
    ];
    if (pool.length < 2) return const [];
    final rng = random ?? Random();
    final order = List<Dhikr>.from(pool)..shuffle(rng);
    final n = choiceCount.clamp(2, pool.length);
    return [
      for (final target in order)
        ZikrCollectRound(
          target: target,
          choices: _choices(pool, target, n, rng),
        ),
    ];
  }

  static List<Dhikr> _choices(
    List<Dhikr> pool,
    Dhikr target,
    int count,
    Random rng,
  ) {
    final others = [
      for (final item in pool)
        if (item.id != target.id) item,
    ]..shuffle(rng);
    final picks = <Dhikr>[target, ...others.take(count - 1)]..shuffle(rng);
    return picks;
  }
}
