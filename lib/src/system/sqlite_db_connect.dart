import 'package:soft_plc/soft_plc.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteDbConnect implements IDbConnect {
  late final Database _driver;

  SqliteDbConnect([String? dbpath]) {
    _driver = dbpath is String ? sqlite3.open(dbpath) : sqlite3.openInMemory();
  }

  @override
  Future<void> execute(String sql, [List<Object?> params = const []]) {
    _driver.execute(sql, params);
    return Future.value();
  }

  @override
  Future<List<DbRow>> select(String sql, [List<Object?> params = const []]) {
    final dbSet = _driver.select(sql, params);

    final out = <DbRow>[];

    for (var row in dbSet) {
      final map = Map.fromEntries(row.entries);
      out.add(map);
    }

    return Future.value(out);
  }

  void dispose() => _driver.dispose();
}
