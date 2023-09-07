import 'dart:async';

import 'package:get_it/get_it.dart';

class ServiceContainer {
    final _container = GetIt.asNewInstance();

    T get<T extends Object>({String? scope, Object? param, Type? type}) =>
        _container.get<T>(instanceName: scope, param1: param, type: type);

    void registerSingleton<T extends Object>(
        T instance, {
        String? scope,
        FutureOr<void> Function(T service)? dispose,
    }) {
        _container.registerSingleton<T>(
            instance,
            dispose: dispose,
            instanceName: scope,
        );
    }

    void registerFactory<T extends Object, P1>(
        T Function(P1 param1) create,
        {String? scope}
    ) {
        _container.registerFactoryParam<T, P1, void>(
            (param, _) => create(param),
            instanceName: scope,
        );
    }

    bool has<T extends Object>({String? scope}) =>
        _container.isRegistered<T>(instanceName: scope);
}
