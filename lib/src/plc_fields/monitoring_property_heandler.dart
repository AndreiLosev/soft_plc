import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/system/event_queue.dart';

class MonitoringPropertyHeandler {

    final List<IMonitoringProperty> _tasks;
    final Config _config;
    final EventQueue _eventQueue; 
    bool _run = false;
    final Map<String, Object> _oldValues = {};

    MonitoringPropertyHeandler(
        this._tasks,
        this._config,
        this._eventQueue,
    );

    Future<void> build() async {
        await for (final (event, value, id) in _enumeration()) {
            _oldValues[_getKey(event, id)] = value;
        }
    }

    Future<void> run() async {
        _run = true;

        while (_run) {
            await for (final (event, value, id) in _enumeration()) {
                await _runOne(event, value, id);
            }
            await Future.delayed(Duration.zero);
        }
    }

    void cancel() {
        _run = false;
    }


    Stream<(Event, Object, int)> _enumeration() async* {
        int id = 0;
        for (final t in _tasks) {
            for (final item in t.getEventValues()) {
                id += 1;
                yield (item.$1, item.$2, id);
            }
        }
    }

    Future<void> _runOne(Event event, Object value, int id) async {
        if (_valueIsChanged(_getKey(event, id), value)) {
            _eventQueue.dispatch(event);                    
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

    String _getKey(Event event, int id) => "${event.name}_$id";
}
