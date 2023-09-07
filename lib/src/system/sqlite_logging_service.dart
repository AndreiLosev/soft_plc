import 'dart:convert';

import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/mixins.dart';

class SqliteLoggingLervice with CreatedAt implements ILoggingService, IUsesDatabase {

    static const _id = 'id';
    static const _name = 'name';
    static const _value = 'value';
    static const _createdAt = 'created_at';

    final IDbConnect _db;

    SqliteLoggingLervice(this._db);

    @override
    String get table => 'logging';

    @override
    Future<void> build() {
        final sql = '''
            CREATE TABLE IF NOT EXISTS $table (
                $_id INTEGER PRIMARY KEY AUTOINCREMENT,
                $_name TEXT,
                $_value TEXT,
                $_createdAt TEXT 
            );
        ''';

        _db.execute(sql);

        return Future.value();
    }

    @override
    Future<void> setLog(Map<String, Object> property) async {

        final sqlB = StringBuffer('''
            INSERT INTO $table ($_name, $_value, $_createdAt)
            VALUES
        ''');
        
        for (var item in property.entries) {
            final strValue = jsonEncode(item.value);
            sqlB.write("('${item.key}','$strValue','$createdAt'),");
        }

        var sql = sqlB.toString();
        sql = sql.substring(0, sql.length - 1);
        sql = "$sql;";

        print(sql);

        await _db.execute(sql);

        return Future.value();
    }
}
