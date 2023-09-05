import 'dart:async';

import 'package:soft_plc/src/plc_fields/periodic_task_field.dart';
import 'package:soft_plc/src/service_container.dart';

class PeriodicTaskCollection {
    final List<PeriodicTaskField> _tasks;

    PeriodicTaskCollection(
        this._tasks,
    );

    Future<void> build() async {
        final futures = _tasks.map((t) => t.init());
        await Future.wait(futures);
    }

    Future<void> run(ServiceContainer container) async {
        final futures = _tasks.map((t) => t.run(container));
        await Future.wait(futures);
    }

     void cancel() {
        for (final t in _tasks) {
            t.cancel();
        }
    }
}
