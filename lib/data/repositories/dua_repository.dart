import '../../app/constants/asset_paths.dart';
import '../../core/utils/daily_seed.dart';
import '../../core/utils/json_map.dart';
import '../datasources/json_content_datasource.dart';
import '../models/dua.dart';

typedef DuaCategory = ({String id, String title});

class DuaRepository {
  DuaRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Dua>? _duas;
  List<DuaCategory>? _categories;
  List<PrayerDua>? _prayerDuas;

  Future<List<Dua>> getAll() async {
    if (_duas != null) return _duas!;
    final raw = await _datasource.loadObject(
      key: 'duas',
      fallbackPath: AssetPaths.duas,
    );
    final categories = [
      for (final row in JsonMap.extractList(raw['categories']))
        (id: JsonMap.str(row['id']), title: JsonMap.str(row['title'])),
    ];
    final titles = {for (final c in categories) c.id: c.title};
    final rows = JsonMap.extractList(raw, itemsKey: 'items');
    final parsed = [
      for (final (index, row) in rows.indexed)
        Dua.fromJson(
          {
            ...row,
            if (JsonMap.str(row['description']).isEmpty)
              'description': titles[JsonMap.str(row['category'])] ?? '',
          },
          order: index + 1,
        ),
    ];
    parsed.sort((a, b) => a.order.compareTo(b.order));
    _categories = List.unmodifiable(categories);
    _duas = List<Dua>.unmodifiable(parsed);
    return _duas!;
  }

  /// Category order from the JSON; the list groups duas by these.
  Future<List<DuaCategory>> getCategories() async {
    await getAll();
    return _categories!;
  }

  Future<List<PrayerDua>> getPrayerDuas() async {
    if (_prayerDuas != null) return _prayerDuas!;
    final rows = await _datasource.loadList(
      key: 'prayerDuas',
      fallbackPath: AssetPaths.prayerDuas,
    );
    final parsed = rows.map(PrayerDua.fromJson).toList();
    parsed.sort((a, b) => a.order.compareTo(b.order));
    _prayerDuas = List<PrayerDua>.unmodifiable(parsed);
    return _prayerDuas!;
  }

  Future<Dua?> getDaily({DateTime? now}) async {
    final all = await getAll();
    if (all.isEmpty) return null;
    return pickDaily(all, now: now);
  }

  Future<List<DuaEntry>> getCatalog() async {
    final duas = await getAll();
    return duas.map(DuaEntry.fromDua).toList(growable: false);
  }

  Future<DuaEntry?> getEntryById(String id) async {
    for (final dua in await getCatalog()) {
      if (dua.id == id) return dua;
    }
    for (final dua in await getPrayerDuas()) {
      if (dua.id == id) return DuaEntry.fromPrayerDua(dua);
    }
    return null;
  }
}
