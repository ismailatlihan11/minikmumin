int dailySeed([DateTime? now]) {
  final date = now ?? DateTime.now();
  return date.year * 10000 + date.month * 100 + date.day;
}

T pickDaily<T>(List<T> items, {DateTime? now}) {
  if (items.isEmpty) {
    throw StateError('Cannot pick from an empty list');
  }
  return items[dailySeed(now) % items.length];
}
