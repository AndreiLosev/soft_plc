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

  bool match(Event event) {
    return _task.eventSubscriptions.contains(event.runtimeType);
  }

  Future<void> run(ServiceContainer container, Event event) async {
    try {
      _task.execute(container, event);

      if (_task is IRetainProperty) {
        await _retainHeandler.save(_task as IRetainProperty);
      }
    } catch (e, s) {
      _errorLogger.log(e, s);
    }
  }
}
