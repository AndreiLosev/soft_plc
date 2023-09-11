import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/mqtt_payload_builder.dart';
import 'package:typed_data/typed_data.dart';

class NetworkPropertyHeandler {

    final List<INetworkProperty> _tasks;
    final MqttConfig _config;
    final IErrorLogger _errorLogger;
    final MqttServerClient _mqtt;

    NetworkPropertyHeandler(
        this._tasks,
        this._config,
        this._errorLogger,
    ): _mqtt = MqttServerClient.withPort(
            _config.host,
            '',
            _config.port,
        );

    Future<void> build() async {

        int count = 0;

        while (count <= _config.numberAttemptsConnect) {
            _mqtt
                ..logging(on: _config.logging)
                ..setProtocolV311()
                ..keepAlivePeriod = _config.keepAlivePeriod.inSeconds
                ..connectTimeoutPeriod = _config.connectTimeoutPeriod.inMilliseconds
                ..connectionMessage = _getConnectMessage()
            ;

            try {
                count += 1;
                await _mqtt.connect(_config.username, _config.password);
                break;
            } catch (e, s) {
                _errorLogger.log(e, s, count >= _config.numberAttemptsConnect);
            }
        }
        
        for (var t in _tasks) {
            for (var topic in t.getTopicSubscriptions()) {
                _mqtt.subscribe(topic, _config.subscriptionQot);          
            }
        }
    }

    Future<void> run() async {

        _mqtt.updates!.listen((message) {
            final topic = message.first.topic;
            final value = (message.first.payload as MqttPublishMessage).payload.message;

            for (final t in _tasks) {
                t.setNetworkProperty(
                    topic,
                    MqttPayloadBuilder()..addBuffer(value),
                );
            }
        });

        while (_mqtt.connectionStatus!.state == MqttConnectionState.connected) {
            await Future.delayed(_config.publicationPeriod);

            for (var t in _tasks) {
                for (var item in t.getPeriodicallyPublishedValues().entries) {
                    _mqtt.publishMessage(
                        item.key,
                        _config.publicationQot,
                        item.value.payload,
                    );
                }
            }
        }
    }

    void publishMessage(String topic, Uint8Buffer message) {
        _mqtt.publishMessage(topic, _config.publicationQot, message);
    }

    void cancel() {
        _mqtt.disconnect();
    }

    MqttConnectMessage _getConnectMessage() {
        final connMessage = MqttConnectMessage()
            .withClientIdentifier(_config.clientIdentifier);

        if (_config.cleanSession) {
            connMessage.startClean();
        }

        final willTopic = _config.willTopic;
        final willMessage = _config.willMessage;

        if (willTopic is String && willMessage is String) {
            connMessage.withWillTopic(willTopic)
                .withWillMessage(willMessage)
                .withWillQos(_config.willQos);

            if (_config.willRetain) {
                connMessage.withWillRetain();
            }
        }

        return connMessage;
    }
}
