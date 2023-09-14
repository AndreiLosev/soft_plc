library system_whith_db_test;

import 'package:soft_plc/src/system/sqlite_db_connect.dart';
import 'package:soft_plc/src/system/sqlite_error_logger.dart';
import 'package:test/test.dart';

void main() {
    test('sqlite_error_logger', () async {
        final db = SqliteDbConnect();
        final errorLoger = SqliteErrorLogger(db);
        await errorLoger.build();

        final e = Exception("test Exception"); 
        final s = StackTrace.fromString("test stec trase");

        await errorLoger.log(e, s);

        var res = await db.select("SELECT * from ${errorLoger.table}");

        expectLater(res[0]['error'], e.toString());
        expectLater(res[0]['stack_trace'], s.toString());
    });
}
