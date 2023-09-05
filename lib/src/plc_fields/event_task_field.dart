
import 'dart:async';

import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/plc_fields/retain_property_heandler.dart';
import 'package:soft_plc/src/service_container.dart';

class EventTaskField {
    final EventTask _task;
    final RetainPropertyHeandler _retainHeandler;
    final IErrorLogger _errorLogger;
    bool _run = false;

    EventTaskField(
        this._task,
        this._retainHeandler,
        this._errorLogger,
    );

    Future<void> init() async {
        if (_task is IRetainProperty) {
            await _retainHeandler.init(_task as IRetainProperty);
        }
    }

    bool match(String eventName)
    {
        return _task.getEvent() == eventName;
    }

    Future<void> run(ServiceContainer container) async {

        while (_run) {
            try {
                _task.execute(container);
                
                if (_task is IRetainProperty) {
                    await _retainHeandler.save(_task as IRetainProperty);
                }
                
            } catch (e) {
                _errorLogger.log(e);
            }
        }
    }

     void cancel() {
        _run = false;
    }
}
