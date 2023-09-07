import 'dart:async';

import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/plc_fields/event_task_field.dart';
import 'package:soft_plc/src/service_container.dart';
import 'package:soft_plc/src/system/event_queue.dart';

class EventTaskCollection {
    final List<EventTaskField> _tasks;
    final EventQueue _eventQueue;

    EventTaskCollection(
        this._tasks,
        this._eventQueue,
    );

    Future<void> build() async {
        final futures = _tasks.map((t) => t.init());
        await Future.wait(futures);
    }

    Future<void> run(ServiceContainer container) async {

        await for (Event event in _eventQueue.listen()) {

            try {
                final launchTasks = _tasks.where((t) => t.match(event));
                await Future.wait(launchTasks.map((e) => e.run(container, event)));
            } on StateError {
                await Future.delayed(Duration.zero);
            }
        }
    }

    void cancel() {
        _eventQueue.cancel();
    }
}
