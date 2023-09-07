import 'dart:async';

import 'package:get_it/get_it.dart';

class ServiceContainer {
    final _container = GetIt.asNewInstance();

    T get<T extends Object>({String? id, Object? param, Type? type}) =>
        _container.get<T>(instanceName: id, param1: param, type: type);

    void registerSingleton<T extends Object>(
        T Function() create, {
        String? id,
        FutureOr<void> Function(T service)? dispose,
    }) {
        _container.registerLazySingleton<T>(
            create,
            dispose: dispose,
            instanceName: id,
        );
    }

    void registerFactory<T extends Object, P1>(
        T Function(P1 param1) create,
        {String? id}
    ) {
        _container.registerFactoryParam<T, P1, void>(
            (param, _) => create(param),
            instanceName: id,
        );
    }

    bool has<T extends Object>({String? id}) =>
        _container.isRegistered<T>(instanceName: id);
}
