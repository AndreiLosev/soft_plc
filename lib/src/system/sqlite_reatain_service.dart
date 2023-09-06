import 'dart:convert';

import 'package:soft_plc/src/contracts/services.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteReatainService implements IReatainService, IUsesDatabase {

    static const String _name = "name";
    static const String _value = "value";

    final Database _db;

    late final PreparedStatement _updateStmt;
    bool _init = false;

    SqliteReatainService(this._db);

    @override
    String get table => 'retain_property';

    @override
    Future<void> createIfNotExists(String name, Object value) {
        _createTable();

        _updateStmt = _db.prepare(
            '''
                UPDATE $table
                SET $_value = ?
                WHERE $_name = ? AND $_value != ? ;
            '''
        );
        
        final strValue = jsonEncode(value);

        var sql = '''
            SELECT * from $table
            WHERE $_name = '$name'
            Limit 1;
        ''';
        final result = _db.select(sql);

        if (result.isNotEmpty) {
            return Future.value();
        }

        sql = '''
            INSERT INTO $table ($_name, $_value)
            VALUES ('$name', '$strValue'); 
        ''';

        _db.execute(sql);

        return Future.value();
    }

    @override
    Future<Map<String, Object>> select(Iterable<String> names) {

        final keys = names.map((e) => "'$e").join(",");
        final sql = "SELECT * from {$this->table} WHERE name in ({$keys})";
        final dbResult = _db.select(sql);
        final result = {} as Map<String, Object>;

        for (Row row in dbResult) {
            result[row[_name]] = jsonDecode(row[_value]);
        }

        return Future.value(result);
    }

    @override
    Future<void> update(String name, Object value) {
        
        final strValue = jsonEncode(value);
        _updateStmt.execute([strValue, name, strValue]);

        return Future.value();
    }

    void _createTable() {
        if (_init) {
            return;
        }

        final sql = '''
                CREATE TABLE IF NOT EXISTS $table (
                $_name TEXT PRIMARY KEY,
                $_value TEXT
            );
        ''';

        _db.execute(sql);

        _init = true;
    }
}
