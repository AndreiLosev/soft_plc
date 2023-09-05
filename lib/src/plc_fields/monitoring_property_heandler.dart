import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/system/event_queue.dart';

class MonitoringPropertyHeandler {

    final List<IMonitoringProperty> _tasks;
    final Config _config;
    final EventQueue _eventQueue; 
    bool _run = false;
    final Map<String, dynamic> _oldValues = {};

    MonitoringPropertyHeandler(
        this._tasks,
        this._config,
        this._eventQueue,
    );

    Future<void> build() async {
        await for (final item in _enumeration()) {
            _oldValues[item.key] = item.value;
        }
    }

    Future<void> run() async {
        _run = true;

        while (_run) {
            await for (final item in _enumeration()) {
                await _runOne(item);
            }
            await Future.delayed(Duration.zero);
        }
    }

    Stream<MapEntry<String, dynamic>> _enumeration() async* {
        for (final t in _tasks) {
            for (final item in t.getEventValues().entries) {
                yield item;
            }
        }
    }

    Future<void> _runOne(MapEntry<String, dynamic> item) async {
        if (_valueIsChanged(item)) {
            _eventQueue.dispatch(item.key);                    
        }
        
        await Future.delayed(Duration.zero);
    }

    bool _valueIsChanged(MapEntry<String, dynamic> item) {

        final oldValue = _oldValues[item.key];
        
        if (oldValue is double) {
            return !_config.floatIsEquals(item.value, oldValue);
        }

        return !(oldValue == item.value);
    }

    void cancel() {
        _run = false;
    }

}
