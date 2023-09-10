import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/system/event_queue.dart';

class NetworkPropertyHeandler {

    final List<INetworkProperty> _tasks;
    final Config _config;
    bool _run = false;

    NetworkPropertyHeandler(
        this._tasks,
        this._config,
    );

    Future<void> build() async {
        // TODO
        UnimplementedError();
    }

    Future<void> run() async {
        _run = true;
        UnimplementedError();
    }

    void cancel() {
        _run = false;
    }
}
