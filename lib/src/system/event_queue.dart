import 'dart:collection';

import 'package:soft_plc/src/contracts/services.dart';

class EventQueue {

    final Queue<String> _queue = Queue();
    final IErrorLogger _errorLogger;
    bool _run = true;

    EventQueue(this._errorLogger);

    void dispatch(String event) {
        if (_run) {
            _queue.add(event);
        }
    }

    Stream<String> listen() async* {
        
        while (_run && _queue.isNotEmpty) {
            try {
                yield await Future.delayed(Duration.zero, _queue.removeFirst);
            } on StateError {
                await Future.delayed(Duration.zero);
                continue;
            } catch (e) {
                _errorLogger.log(e);
                await Future.delayed(Duration.zero);
                continue;
            }
        }
    }

    void cancel() {
        _run = false;
    }

}
