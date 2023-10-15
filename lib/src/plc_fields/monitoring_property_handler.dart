import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/system/event_queue.dart';

class MonitoringPropertyHandler {
  final List<IMonitoringProperty> _tasks;
  final Config _config;
  final EventQueue _eventQueue;
  final IErrorLogger _errorLogger;
  bool _run = false;
  final _oldValues = <String, Object>{};

  MonitoringPropertyHandler(
    this._tasks,
    this._config,
    this._eventQueue,
    this._errorLogger,
  );

  Future<void> build() async {
    await for (final (id, value, _) in _enumeration()) {
      _oldValues[id] = value;
    }
  }

  Future<void> run() async {
    _run = true;

    while (_run) {
      await for (final (id, value, task) in _enumeration()) {
        await _runOne(id, value, task);
      }
      await Future.delayed(Duration.zero);
    }
  }

  void cancel() {
    _run = false;
  }

  Stream<(String, Object, IMonitoringProperty)> _enumeration() async* {
    for (final t in _tasks) {
      for (final item in t.getEventValues()) {
        yield (item.$1, item.$2, t);
      }
    }
  }

  Future<void> _runOne(String id, Object value, IMonitoringProperty task) async {
    try {
      if (_valueIsChanged(id, value)) {
        _eventQueue.dispatch(task.getEventById(id));
        _oldValues[id] = value;
      }
    } catch (e, s) {
      _errorLogger.log(e, s);
    }

    await Future.delayed(Duration.zero);
  }

  bool _valueIsChanged(String key, Object value) {
    final oldValue = _oldValues[key];

    if (oldValue is double) {
      if (value is! double) {
        throw Exception("$this.runtimeType:  oldValue type !== value type");
      }
      return !_config.floatIsEquals(value, oldValue);
    }

    return !(oldValue == value);
  }
}
