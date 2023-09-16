import 'dart:async';
import 'dart:math';

import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';
import 'package:soft_plc/src/plc_fields/event_task_collection.dart';
import 'package:soft_plc/src/plc_fields/event_task_field.dart';
import 'package:soft_plc/src/plc_fields/logging_property_handler.dart';
import 'package:soft_plc/src/plc_fields/monitoring_property_handler.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_collection.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_field.dart';
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
                {'name': task.addClassName('x1'), 'value': 0.toString()},
                {'name': task.addClassName('x2'), 'value': 0.0.toString()},
                {'name': task.addClassName('x1'), 'value': 1.toString()},
                {'name': task.addClassName('x2'), 'value':1.1.toString()},
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

    test('periodic_task', () async {
        final task = OneTask();
        final tasl1 = ThreeTask();
        final eloger = ConsoleErrorLogger();
        final db = SqliteDbConnect();
        final retainSercie = SqliteReatainService(db);
        final reatinHandler = RetainPropertyHeandler(retainSercie);
        final taskField = PeriodicTaskField(task, reatinHandler, eloger);
        final taskField1 = PeriodicTaskField(tasl1, reatinHandler, eloger);
        final sc = ServiceContainer();

        final handler = PeriodicTaskCollection([taskField, taskField1]);

        await handler.build();

        handler.run(sc);

        await Future.delayed(Duration(milliseconds: 50), () => handler.cancel());

        expect(
            [task.x1, task.x2, tasl1.s],
            [4, 4.4, "1 1 1 1 1"],
        );
    });

    test('event_tsk', () async {
        final task1 = TwoTask();
        final task2 = FourthTask();
        final task3 = FifthTask();

        final eLog = ConsoleErrorLogger();
        final db = SqliteDbConnect();
        final retainSercie = SqliteReatainService(db);
        final reatinHandler = RetainPropertyHeandler(retainSercie);

        final taskField1 = EventTaskField(task1, reatinHandler, eLog);
        final taskField2 = EventTaskField(task2, reatinHandler, eLog);
        final taskField3 = EventTaskField(task3, reatinHandler, eLog);

        final queue = EventQueue(eLog);

        final handler = EventTaskCollection([taskField1, taskField2, taskField3], queue);
        final sc = ServiceContainer();

        await handler.build();
        
        handler.run(sc);

        queue.dispatch(TwoEvent(2));
        queue.dispatch(FourthEvent([1, 2]));
        queue.dispatch(TwoEvent(4));
        queue.dispatch(FourthEvent([2, 3]));
        queue.dispatch(TwoEvent(8));
        queue.dispatch(FourthEvent([3, 4]));

        await Future.delayed(Duration(milliseconds: 50));

        expect(
            [task1.val, task2.sum, task3.sumTwo, task3.sumFourth, task3.product],
            ["0 2 4 8", 15, 14, 15, 210],
        );

    });
}
