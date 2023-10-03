import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/reatain_value.dart';

class SqliteReatainService implements IReatainService, IUsesDatabase {
  static const String _name = "name";
  static const String _value = "value";

  final IDbConnect _db;
  late final String _updateSql;

  final _values = <String, ReatainValue>{};

  bool _init = false;

  SqliteReatainService(this._db) {
    _updateSql = '''
            UPDATE $table
            SET $_value = ?
            WHERE $_name = ? AND $_value != ? ;
        ''';
  }

  @override
  String get table => 'retain_property';

  @override
  Future<void> createIfNotExists(String name, ReatainValue value) async {
    _createTable();

    _values[name] = value;

    final strValue = value.toJson();

    var sql = '''
            SELECT * from $table
            WHERE $_name = '$name'
            Limit 1;
        ''';
    final result = await _db.select(sql);

    if (result.isNotEmpty) {
      return Future.value();
    }

    sql = '''
            INSERT INTO $table ($_name, $_value)
            VALUES ('$name', '$strValue'); 
        ''';

    await _db.execute(sql);
  }

  @override
  Future<Map<String, ReatainValue>> select(Set<String> names) async {
    final keys = names.map((e) => "'$e'").join(",");
    final sql = "SELECT * from $table WHERE name in ($keys)";
    final dbResult = await _db.select(sql);
    final result = <String, ReatainValue>{};

    for (final row in dbResult) {
      final name = row[_name] as String;
      final strValue = row[_value] as String;
      _values[name]?.fromJson(strValue);
      result[name] = _values[name]!;
    }

    return Future.value(result);
  }

  @override
  Future<void> update(String name, ReatainValue value) async {
    final strValue = value.toJson();

    await _db.execute(_updateSql, [strValue, name, strValue]);
  }

  void _createTable() async {
    if (_init) {
      return;
    }

    final sql = '''
                CREATE TABLE IF NOT EXISTS $table (
                $_name TEXT PRIMARY KEY,
                $_value TEXT
            );
        ''';

    await _db.execute(sql);

    _init = true;
  }
}
