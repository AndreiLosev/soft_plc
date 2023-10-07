import 'dart:collection';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/cancelable_future_delayed.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';

class NetworkPropertyHandler {
  final List<INetworkSubscriber> _tasksSubscriber;
  final List<INetworkPublisher> _tasksPublisher;
  final NetworkConfig _config;
  final IErrorLogger _errorLogger;
  final INetworkService _networkService;
  final _publickMessageBuffer = Queue<(String, SmartBuffer)>();

  bool _run = false;
  late final CancelableFutureDelayed _reconnectDalay;
  late final CancelableFutureDelayed _publicationDalay;

  NetworkPropertyHandler(
    this._tasksPublisher,
    this._tasksSubscriber,
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
        _publicationFromBuffer();
        await _publishing();
        break;
      } catch (e, s) {
        _errorLogger.log(e, s);
        await _reconnectDalay();
      }
    }
  }

  void publication(String topic, SmartBuffer value) {
    if (_networkService.isConnected()) {
      _networkService.publication(topic, value);
    }

    _publickMessageBuffer.add((topic, value));
  }

  void cancel() {
    _run = false;
    _reconnectDalay.cancel();
    _publicationDalay.cancel();
    _networkService.disconnect();
  }

  Future<void> _publishing() async {
    while (_networkService.isConnected()) {

    if (!_networkService.isConnected()) {
        throw Exception("Disconnect exception");
     }

      await _publicationDalay();

      try {
        for (var task in _tasksPublisher) {
          for (var message in task.getPeriodicallyPublishedValues().entries) {
            _networkService.publication(message.key, message.value);
          }
        }
      } catch (e, s) {
        _errorLogger.log(e, s);
        if (!_networkService.isConnected()) {
          throw Exception("Disconnect exception");
        }
      }
    }
  }

  void _listenTopicks() {
    _networkService.listen((topic, buffer) {
      for (var task in _tasksSubscriber) {
        task.setNetworkProperty(topic, buffer);
      }
    });
  }

  void _subscribe() {
    for (var task in _tasksSubscriber) {
      for (var topic in task.getTopicSubscriptions()) {
        _networkService.subscribe(topic);
      }
    }
  }

  void _publicationFromBuffer() {
    while (_publickMessageBuffer.isNotEmpty) {
      final (topic, value) = _publickMessageBuffer.removeFirst();
      _networkService.publication(topic, value);
    }
  }
}
