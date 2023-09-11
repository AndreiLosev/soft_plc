import 'dart:async';

import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';
import 'package:soft_plc/src/helpers/system_tasks.dart';
import 'package:soft_plc/src/plc_fields/event_task_collection.dart';
import 'package:soft_plc/src/plc_fields/event_task_field.dart';
import 'package:soft_plc/src/plc_fields/logging_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/monitoring_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/network_property_heandler.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_collection.dart';
import 'package:soft_plc/src/plc_fields/periodic_task_field.dart';
import 'package:soft_plc/src/plc_fields/retain_property_heandler.dart';
import 'package:soft_plc/src/system/sqlite_db_connect.dart';

class SoftPlcBuilder {

    final ServiceContainer _container = ServiceContainer();
    final List<Task> _tasks = [];
    final List<ILoggingProperty> _loggingTasks = [];
    final List<IMonitoringProperty> _monitorigTask = [];
    final List<INetworkProperty> _networkTask = [];
    late final LoggingPropertyHeandler _loggingPropertyHeandler;
    late final MonitoringPropertyHeandler _monitoringPropertyHeandler;
    late final NetworkPropertyHeandler _networkPropertyHeandler; 
    late final PeriodicTaskCollection _periodicTaskCollection;
    late final EventTaskCollection _eventTaskCollection;

    SoftPlcBuilder registerTask<T extends Task>(T task) {
        _tasks.add(task);
        _container.registerSingleton(() => task);

        return this;
    }

    SoftPlcBuilder registerSingleton<T extends Object>(
        T instance, {
        String? scope,
        FutureOr<void> Function(T service)? dispose,
    }) {
        _container.registerSingleton<T>(
            instance,
            dispose: dispose,
            scope: scope,
        );

        return this;
    }

    SoftPlcBuilder registerFactory<T extends Object, P1>(
        T Function(P1 param1) create,
        {String? scope}
    ) {
        _container.registerFactory<T, P1>(
            (param) => create(param),
            scope: scope,
        );

        return this;
    }

    Future<SoftPlc> build() async {
        _registerDefaultServices();
        _registerSystemTasks();
        _setTaskTypes();
        await _createHeandlers();

        return SoftPlc(
            _container,
            _loggingPropertyHeandler,
            _monitoringPropertyHeandler,
            _networkPropertyHeandler,
            _periodicTaskCollection,
            _eventTaskCollection,
        );
    }

    void _setTaskTypes() {
        if (_tasks.isEmpty) {
            throw Exception("unregistered more than one task");
        }

        final periodicTaskFields = <PeriodicTaskField>[];
        final eventTasls = <EventTaskField>[];

        for (final t in _tasks) {
            if (t is ILoggingService) {
                _loggingTasks.add(t as ILoggingProperty);
            }

            if (t is IMonitoringProperty) {
                _monitorigTask.add(t as IMonitoringProperty);
            }
            
            if (t is INetworkProperty) {
                _networkTask.add(t as INetworkProperty);
            }

            if (t is PeriodicTask) {
                periodicTaskFields.add(PeriodicTaskField(
                    t,
                    RetainPropertyHeandler(_container.get<IReatainService>()),
                    _container.get<IErrorLogger>(),
                ));
            }

            if (t is EventTask) {
                eventTasls.add(EventTaskField(
                    t,
                    RetainPropertyHeandler(_container.get<IReatainService>()),
                    _container.get<IErrorLogger>(),
                ));
            }
        }

        _periodicTaskCollection = PeriodicTaskCollection(periodicTaskFields);
        _eventTaskCollection = EventTaskCollection(
            eventTasls,
            _container.get<EventQueue>(),
        );

    }

    void _registerSystemTasks() {
        registerTask(PublishMessageTask());
    }

    void _registerDefaultServices() {

        if (!_container.has<MqttConfig>()) {
            _container.registerSingleton(MqttConfig());
        }

        if (!_container.has<Config>()) {
            _container.registerSingleton<Config>(Config(
                _container.get<MqttConfig>(),
            ));
        }

        final useDefaultDatabase = _container.get<Config>().database == defaultDatabase;

        if (!_container.has<IDbConnect>() && useDefaultDatabase) {
            _container.registerSingleton<IDbConnect>(SqliteDbConnect(
                _container.get<Config>().sqlitePath,
            ));
        }

        if (!_container.has<IReatainService>()) {
            _container.registerSingleton<IReatainService>(SqliteReatainService(
                _container.get<IDbConnect>(),
            ));
        }

        if (!_container.has<ILoggingService>()) {
            _container.registerSingleton<ILoggingService>(SqliteLoggingLervice(
                _container.get<IDbConnect>(),
            ));
        }

        if (!_container.has<IErrorLogger>()) {
            _container.registerSingleton<IErrorLogger>(ConsoleErrorLogger());
        }

        if (!_container.has<EventQueue>()) {
            _container.registerSingleton(EventQueue(
                _container.get<IErrorLogger>()
            ));
        }
    }

    Future<void> _createHeandlers() async {
        _loggingPropertyHeandler = LoggingPropertyHeandler(
            _loggingTasks,
            _container.get<ILoggingService>(),
            _container.get<Config>()
        );

        _monitoringPropertyHeandler = MonitoringPropertyHeandler(
            _monitorigTask,
            _container.get<Config>(),
            _container.get<EventQueue>(),
        );

        _networkPropertyHeandler = NetworkPropertyHeandler(
            _networkTask,
            _container.get<Config>().mqttConfig,
            _container.get<IErrorLogger>(),
        );

        await Future.wait([
            _loggingPropertyHeandler.build(),
            _monitoringPropertyHeandler.build(),
            _networkPropertyHeandler.build(),
            _periodicTaskCollection.build(),
            _eventTaskCollection.build(),

        ]);
    }
}
