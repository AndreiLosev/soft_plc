import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/mqtt_config.dart';

class NetworkPropertyHeandler {

    final List<INetworkProperty> _tasks;
    final MqttConfig _config;
    final IErrorLogger _errorLogger;
    bool _run = false;

    NetworkPropertyHeandler(
        this._tasks,
        this._config,
        this._errorLogger,
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
