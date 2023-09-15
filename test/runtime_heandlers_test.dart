library runtime_heandlers;

import 'dart:async';

import 'package:soft_plc/src/plc_fields/logging_property_handler.dart';
import 'package:soft_plc/src/service_container.dart';
import 'package:soft_plc/src/system/console_error_logger.dart';
import 'package:soft_plc/src/system/sqlite_db_connect.dart';
import 'package:soft_plc/src/system/sqlite_logging_service.dart';
import 'configs_for_tests.dart';
import 'tasks_for_tests.dart';
import 'package:test/test.dart';

void main() {
    test('logging_property', () async {
        final task = OneTask();
        final db = SqliteDbConnect();
        final service = SqliteLoggingLervice(db);
        await service.build();
        final eLogger = ConsoleErrorLogger();
        final config = LoggingHandlerConfig();    

        final handler = LoggingPropertyHandler(
            [task],
            service,
            eLogger,
            config,
        );

        handler.run();

        Timer(Duration(milliseconds: 30), () {
            task.execute(ServiceContainer());
        });

        await Future.delayed(config.loggingPeriod * 2.5, () {
            handler.cancel();
        });

        final result = await db.select("SELECT name, value FROM ${service.table}");

        print(result);

        expect(result.length, 4);

        expect(
            result,
            [
                {'name': task.addPrefix('x1'), 'value': 0.toString()},
                {'name': task.addPrefix('x2'), 'value': 0.0.toString()},
                {'name': task.addPrefix('x1'), 'value': 1.toString()},
                {'name': task.addPrefix('x2'), 'value':1.1.toString()},
            ],
        );

    });
}
