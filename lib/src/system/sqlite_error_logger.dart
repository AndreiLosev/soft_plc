import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/mixins.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteErrorLogger with CreatedAt implements IErrorLogger, IUsesDatabase {
    
    static const _id = 'id';
    static const _error = 'error';
    static const _stackTrace = 'stack_trace';
    static const _isFatal = 'is_fatal';
    static const _createdAt = 'created_at';

    final Database _db;
    late final PreparedStatement _logStmt;

    SqliteErrorLogger(
        this._db
    );

    @override
    String get table => 'error_log';

    @override
    Future<void> build() {
        
        final sql = '''
            CREATE TABLE IF NOT EXISTS $table (
                $_id INTEGER PRIMARY KEY AUTOINCREMENT,
                $_error TEXT,
                $_stackTrace TEXT,
                $_isFatal INTEGER,
                $_createdAt TEXT 
            );
        ''';

        _db.execute(sql);
        
        _logStmt = _db.prepare('''
            INSERT INTO $table ($_error, $_stackTrace, $_isFatal, $_createdAt)
            VALUES (?, ?, ?, ?);
        ''');

        return Future.value();
    }

    @override
    Future<void> log(Object e, Object s, [bool isFatal = false]) {
        _logStmt.execute([e.toString(), s.toString(), isFatal, createdAt]);

        return Future.value();
    }
}
