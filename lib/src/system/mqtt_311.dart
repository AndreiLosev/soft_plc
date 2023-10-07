import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';

class Mqtt311 implements INetworkService {
  final NetworkConfig _config;
  late final MqttServerClient _client;

  Mqtt311(this._config) {
    _client = MqttServerClient.withPort(_config.host, '', _config.port);
  }

  @override
  Future<void> connect() async {
    _client
      ..logging(on: _config.logging)
      ..setProtocolV311()
      ..keepAlivePeriod = _config.keepAlivePeriod.inSeconds
      ..connectTimeoutPeriod = _config.connectTimeoutPeriod.inMilliseconds
      ..autoReconnect = false
      ..connectionMessage = _getConnectMessage();

    await _client.connect(_config.username, _config.password);
  }

  @override
  void subscribe(String topic) {
    _client.subscribe(topic, _config.subscriptionQot);
  }

  @override
  void publication(String topic, SmartBuffer buffer) {
    _client.publishMessage(topic, _config.publicationQot, buffer.payload,
        retain: _config.publicationRetain[topic] ?? false);
  }

  @override
  bool isConnected() {
    return _client.connectionStatus!.state == MqttConnectionState.connected;
  }

  @override
  void listen(void Function(String topic, SmartBuffer buffer) onData) {
    _client.updates!.listen((message) {
      final topic = message.first.topic;
      final value =
          (message.first.payload as MqttPublishMessage).payload.message;

      onData(topic, SmartBuffer(value));
    });
  }

  @override
  Future<void> disconnect() {
    _client.disconnect();
    return Future.value();
  }

  MqttConnectMessage _getConnectMessage() {
    final connMessage =
        MqttConnectMessage().withClientIdentifier(_config.clientIdentifier);

    if (_config.cleanSession) {
      connMessage.startClean();
    }

    final willTopic = _config.willTopic;
    final willMessage = _config.willMessage;

    if (willTopic is String && willMessage is String) {
      connMessage
          .withWillTopic(willTopic)
          .withWillMessage(willMessage)
          .withWillQos(_config.willQos);

      if (_config.willRetain) {
        connMessage.withWillRetain();
      }
    }

    return connMessage;
  }
}
