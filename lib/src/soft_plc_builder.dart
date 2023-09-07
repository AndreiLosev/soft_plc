import 'dart:async';

import 'package:soft_plc/soft_plc.dart';
import 'package:sqlite3/sqlite3.dart';

class SoftPlcBuilder {

    final ServiceContainer _container = ServiceContainer();
    final List<Type> _tasks = [];
    final List<Type> _liggingTasks = [];
    final List<Type> _monitorigTask = [];
    final List<Type> _networkTask = [];

    void registerTask<T extends Task>(T task) {
        _tasks.add(task.runtimeType);
        _container.registerSingleton(() => task);
    }

    void registerSingleton<T extends Object>(
        T Function() create, {
        String? id,
        FutureOr<void> Function(T service)? dispose,
    }) {
        _container.registerSingleton<T>(
            create,
            dispose: dispose,
            id: id,
        );
    }

    void registerFactory<T extends Object, P1>(
        T Function(P1 param1) create,
        {String? id}
    ) {
        _container.registerFactory<T, P1>(
            (param) => create(param),
            id: id,
        );
    }

    void build() {
        _setTaskTypes();
        _registerDefaultServices();
    }

    void _setTaskTypes() {
        for (final t in _tasks) {
            if (_container.get(type: t) is ILoggingService) {
                _liggingTasks.add(t);
            }

            if (_container.get(type: t) is IMonitoringProperty) {
                _monitorigTask.add(t);
            }
            
            if (_container.get(type: t) is INetworkProperty) {
                _networkTask.add(t);
            }
        }
    }

    void _registerDefaultServices() {

        if (!_container.has<Config>()) {
            _container.registerSingleton<Config>(() => Config());
        }

        if (_container.get<Config>().database == defaultDatabase) {
            _container.registerSingleton(() => sqlite3.open(
                _container.get<Config>().sqlitePath,
            ));
        }

        // if (!_container.has<IReatainService>()) {
        //     _container.registerSingleton<IReatainService>(() => SqliteReatainService(
        //         _container.get<Database>(),
        //     ));
        // }

        // if (!_container.has<ILoggingService>()) {
        //     _container.registerSingleton<ILoggingService>(() => SqliteLoggingLervice(
        //         _container.get<Database>(),
        //     ));
        // }

        // if (!_container.has<IErrorLogger>()) {
        //     _container.registerSingleton<IErrorLogger>(() => ConsoleErrorLogger());
        // }

        _container.registerSingleton(() => EventQueue(
            _container.get<IErrorLogger>()
        ));
    }

}
