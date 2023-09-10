import 'dart:convert';

import 'package:soft_plc/src/contracts/services.dart';

class SqliteReatainService implements IReatainService, IUsesDatabase {

    static const String _name = "name";
    static const String _value = "value";

    final IDbConnect _db;
    late final String _updateSql; 

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
    Future<void> createIfNotExists(String name, Object value) async {
        _createTable();
        
        final strValue = jsonEncode(value);

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
    Future<Map<String, Object>> select(Iterable<String> names) async {

        final keys = names.map((e) => "'$e").join(",");
        final sql = "SELECT * from {$this->table} WHERE name in ({$keys})";
        final dbResult = await _db.select(sql);
        final result = {} as Map<String, Object>;

        for (final row in dbResult) {
            result[row[_name] as String] = jsonDecode(row[_value] as String);
        }

        return Future.value(result);
    }

    @override
    Future<void> update(String name, Object value) async {
        
        final strValue = jsonEncode(value);

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
