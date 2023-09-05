
import 'dart:async';

import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/plc_fields/retain_property_heandler.dart';
import 'package:soft_plc/src/service_container.dart';

class PeriodicTaskField {
    final PeriodicTask _task;
    final RetainPropertyHeandler _retainHeandler;
    final IErrorLogger _errorLogger;
    DateTime _lastStart = DateTime.now();
    bool _run = false;

    PeriodicTaskField(
        this._task,
        this._retainHeandler,
        this._errorLogger,
    );

    Future<void> init() async {
        if (_task is IRetainProperty) {
            await _retainHeandler.init(_task as IRetainProperty);
        }
    }

    Future<void> run(ServiceContainer container) async {

        _run = true;

        while (_run) {
            try {
                _lastStart = DateTime.now();
                _task.execute(container);
                
                if (_task is IRetainProperty) {
                    await _retainHeandler.save(_task as IRetainProperty);
                }
                
            } catch (e) {
                _errorLogger.log(e);
            }
            await Future.delayed(_getPause());
        }
    }

     void cancel() {
        _run = false;
    }

    Duration _getPause() {
        final timeLeft = DateTime.now().difference(_lastStart);
        return _task.getPeriod() - timeLeft;
    }
}
