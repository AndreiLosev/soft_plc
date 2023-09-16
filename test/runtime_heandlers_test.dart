import 'dart:async';

import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';
import 'package:soft_plc/src/plc_fields/logging_property_handler.dart';
import 'package:soft_plc/src/plc_fields/monitoring_property_handler.dart';
import 'package:soft_plc/src/plc_fields/retain_property_heandler.dart';
import 'package:soft_plc/src/service_container.dart';
import 'package:soft_plc/src/system/console_error_logger.dart';
import 'package:soft_plc/src/system/event_queue.dart';
import 'package:soft_plc/src/system/sqlite_db_connect.dart';
import 'package:soft_plc/src/system/sqlite_logging_service.dart';
import 'package:soft_plc/src/system/sqlite_reatain_service.dart';
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

    test('retain_property', () async {
        final task = OneTask();
        final db = SqliteDbConnect();
        final service = SqliteReatainService(db);

        final handler = RetainPropertyHeandler(service);
        await handler.init(task);

        final sc = ServiceContainer();
        task.execute(sc);
        task.execute(sc);
        task.execute(sc);

        await handler.save(task);

        final task1 = OneTask();

        await handler.init(task1);

        db.dispose();

        expect([task.x1, task.x2], [task1.x1, task1.x2]);
    });

    test("monitoring_property", () async {
        final ptask = OneTask();
        final eloger = ConsoleErrorLogger();
        final equeue = EventQueue(eloger);
        final config = Config(MqttConfig());
        final sc = ServiceContainer();

        final handler = MonitoringPropertyHandler([ptask], config, equeue, eloger);

        await handler.build();

        handler.run();

        await Future.delayed(Duration(milliseconds: 10));
        ptask.execute(sc);
        await Future.delayed(Duration(milliseconds: 10));
        ptask.execute(sc);
        await Future.delayed(Duration(milliseconds: 10));
        ptask.execute(sc);

        int i = 0;
        await for (final e in equeue.listen()) {    
            if (e is TwoEvent) {
                i += 1;
                expect(e.val, i);
            } else {
                expect(true, false);
            }

            if (i >= 3) {
                break;
            }
        }


});
}