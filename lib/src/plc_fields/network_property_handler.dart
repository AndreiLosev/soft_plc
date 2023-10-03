import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/cancelable_future_delayed.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';

class NetworkPropertyHandler {
  final List<INetworkProperty> _tasks;
  final NetworkConfig _config;
  final IErrorLogger _errorLogger;
  final INetworkService _networkService;

  bool _run = false;
  late final CancelableFutureDelayed _reconnectDalay;
  late final CancelableFutureDelayed _publicationDalay;

  NetworkPropertyHandler(
    this._tasks,
    this._config,
    this._errorLogger,
    this._networkService,
  ) {
    _reconnectDalay = CancelableFutureDelayed(_config.autoReconnectPeriod);
    _publicationDalay = CancelableFutureDelayed(_config.publicationPeriod);
  }

  Future<void> run() async {
    _run = true;

    while (_run) {
      try {
        await _networkService.connect();
        _subscribe();
        _listenTopicks();
        await _publishing();
        break;
      } catch (e, s) {
        _errorLogger.log(e, s);
        await _reconnectDalay.call();
      }
    }
  }

  void publication(String topic, SmartBuffer value) {
    _networkService.publication(topic, value);
  }

  Future<void> _publishing() async {
    while (_networkService.isConnected()) {
      await _publicationDalay.call();

      try {
        for (var task in _tasks) {
          for (var message in task.getPeriodicallyPublishedValues().entries) {
            _networkService.publication(message.key, message.value);
          }
        }
      } catch (e, s) {
        _errorLogger.log(e, s);
      }
    }
  }

  void _listenTopicks() {
    _networkService.listen((topic, buffer) {
      for (var task in _tasks) {
        task.setNetworkProperty(topic, buffer);
      }
    });
  }

  void _subscribe() {
    for (var task in _tasks) {
      for (var topic in task.getTopicSubscriptions()) {
        _networkService.subscribe(topic);
      }
    }
  }

  void cancel() {
    _run = false;
    _reconnectDalay.cancel();
    _publicationDalay.cancel();
    _networkService.disconnect();
  }
}
