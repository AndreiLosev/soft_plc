import 'dart:convert';

import 'package:soft_plc/src/helpers/reatain_value.dart';
import 'package:soft_plc/src/system/sqlite_db_connect.dart';
import 'package:soft_plc/src/system/sqlite_error_logger.dart';
import 'package:soft_plc/src/system/sqlite_logging_service.dart';
import 'package:soft_plc/src/system/sqlite_reatain_service.dart';
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

    db.dispose();

    expectLater(res[0]['error'], e.toString());
    expectLater(res[0]['stack_trace'], s.toString());
  });

  test('sqlite_logging', () async {
    final db = SqliteDbConnect();
    final logger = SqliteLoggingLervice(db);
    await logger.build();

    final data = {
      'x1': true,
      'x2': 33,
      'x3': 4.2,
      'x4': 'Ok ok oK',
      'x5': [false, -33, 2.4, 'test 222'],
    };

    await logger.setLog(data);

    final res = await db.select("SELECT * FROM ${logger.table}");

    db.dispose();

    for (var row in res) {
      if (row['name'] == 'x1') {
        expect(jsonEncode(data['x1']), row['value']);
        expect(true, parseDateTime(row['created_at']) is DateTime);
      } else if (row['name'] == 'x2') {
        expect(data['x2'].toString(), row['value']);
      } else if (row['name'] == 'x3') {
        expect(jsonEncode(data['x3']), row['value']);
      } else if (row['name'] == 'x4') {
        expect(jsonEncode(data['x4']), row['value']);
      } else if (row['name'] == 'x5') {
        expect(jsonEncode(data['x5']), row['value']);
      }
    }
  });

  test('sqlite_reatain', () async {
    final db = SqliteDbConnect();
    final retainService = SqliteReatainService(db);

    final data = <String, ReatainValue>{
      'x1': ReatainBoolValue(true),
      'x2': ReatainNumValue(33),
      'x3': ReatainNumValue(4.2),
      'x4': ReatainStringValue('Ok ok oK'),
      'x5': ReatainListValue([false, -33, 2.4, 'test 222']),
    };

    final data2 = <String, ReatainValue>{
      'x1': ReatainBoolValue(false),
      'x2': ReatainNumValue(330),
      'x3': ReatainNumValue(14.2),
      'x4': ReatainStringValue('Ok-oK'),
      'x5': ReatainListValue([false, -303, -2.4, 'test 2 222']),
    };

    for (var item in data.entries) {
      await retainService.createIfNotExists(item.key, item.value);
    }

    for (var item in data2.entries) {
      await retainService.update(item.key, item.value);
    }

    final select = await retainService.select(data.keys.toSet());

    for (var i in data2.entries) {
      expect(i.value.value, select[i.key]!.value);
    }
  });
}

Object parseDateTime(Object? dt) {
  return DateTime.parse(jsonDecode(dt as String)[0]);
}
