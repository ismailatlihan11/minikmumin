import '../../app/constants/asset_paths.dart';
import '../../core/utils/daily_seed.dart';
import '../datasources/json_content_datasource.dart';
import '../models/dua.dart';

class DuaRepository {
  DuaRepository({JsonContentDatasource? datasource})
      : _datasource = datasource ?? JsonContentDatasource();

  final JsonContentDatasource _datasource;
  List<Dua>? _duas;
  List<PrayerDua>? _prayerDuas;

  Future<List<Dua>> getAll() async {
    if (_duas != null) return _duas!;
    final rows = await _datasource.loadList(
      key: 'duas',
      fallbackPath: AssetPaths.duas,
    );
    final parsed = rows.map(Dua.fromJson).toList();
    parsed.sort((a, b) => a.order.compareTo(b.order));
    _duas = List<Dua>.unmodifiable(parsed);
    return _duas!;
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
