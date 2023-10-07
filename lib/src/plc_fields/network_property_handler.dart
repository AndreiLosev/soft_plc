import 'dart:async';
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
        await Future.wait([_publicationFromQueue(), _publishingPeriodic()]);
        await _reconnectDalay();
      } catch (e, s) {
        _errorLogger.log(e, s);
        await _reconnectDalay();
      }
    }
  }

  void publication(String topic, SmartBuffer value) {
    _publickMessageBuffer.add((topic, value));
  }

  void cancel() {
    _run = false;
    _reconnectDalay.cancel();
    _publicationDalay.cancel();
    _networkService.disconnect();
  }

  Future<void> _publishingPeriodic() async {
    while (_networkService.isConnected()) {

      try {
        for (var task in _tasksPublisher) {
          for (var message in task.getPeriodicallyPublishedValues().entries) {
            _networkService.publication(message.key, message.value);
          }
        }
      } on ConnectionException {

        return;
      }

      await _publicationDalay();
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

  Future<void> _publicationFromQueue() async {
    while (_networkService.isConnected()) {
      
      String? topic;
      SmartBuffer? message;

      try {

        (topic, message) = _publickMessageBuffer.removeFirst();
        await Future(() => _networkService.publication(topic!, message!)); 

      } on StateError {

        await Future.delayed(Duration(milliseconds: 100));

      } on ConnectionException {

        if (topic is String && message is SmartBuffer) {
          _publickMessageBuffer.add((topic, message));
        }
        _publicationDalay.cancel();
        return;
      }
    }
  }
}
