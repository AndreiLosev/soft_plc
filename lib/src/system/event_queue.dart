import 'dart:collection';

import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/contracts/task.dart';

class EventQueue {

    final Queue<Event> _queue = Queue();
    final IErrorLogger _errorLogger;
    bool _run = true;

    EventQueue(this._errorLogger);

    void dispatch(Event event) {
        if (_run) {
            _queue.add(event);
        }
    }

    Stream<Event> listen() async* {
        
        while (_run || _queue.isNotEmpty) {
            try {
                final e = _queue.removeFirst();
                yield await Future.delayed(Duration.zero,() => e);
            } on StateError {
                await Future.delayed(Duration(milliseconds: 25));
            } catch (e, s) {
                _errorLogger.log(e, s);
                await Future.delayed(Duration(milliseconds: 50));
            }
        }
    }

    void cancel() {
        _run = false;
    }

}
