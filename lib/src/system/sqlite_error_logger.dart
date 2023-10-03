import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/mixins.dart';

class SqliteErrorLogger with CreatedAt implements IErrorLogger, IUsesDatabase {
  static const _id = 'id';
  static const _error = 'error';
  static const _stackTrace = 'stack_trace';
  static const _isFatal = 'is_fatal';
  static const _createdAt = 'created_at';

  final IDbConnect _db;

  late final String _logSql;

  SqliteErrorLogger(this._db) {
    _logSql = '''
            INSERT INTO $table ($_error, $_stackTrace, $_isFatal, $_createdAt)
            VALUES (?, ?, ?, ?);
        ''';
  }

  @override
  String get table => 'error_log';

  @override
  Future<void> build() async {
    final sql = '''
            CREATE TABLE IF NOT EXISTS $table (
                $_id INTEGER PRIMARY KEY AUTOINCREMENT,
                $_error TEXT,
                $_stackTrace TEXT,
                $_isFatal INTEGER,
                $_createdAt TEXT 
            );
        ''';

    await _db.execute(sql);
  }

  @override
  Future<void> log(Object e, StackTrace s, [bool isFatal = false]) async {
    await _db
        .execute(_logSql, [e.toString(), s.toString(), isFatal, createdAt]);
  }
}
