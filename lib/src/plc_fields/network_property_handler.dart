import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';
import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/services.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:typed_data/typed_data.dart';

class NetworkPropertyHandler {

    final List<INetworkProperty> _tasks;
    final MqttConfig _config;
    final IErrorLogger _errorLogger;
    final MqttServerClient _mqtt;
    bool _run = false;

    NetworkPropertyHandler(
        this._tasks,
        this._config,
        this._errorLogger,
    ): _mqtt = MqttServerClient.withPort(
            _config.host,
            '',
            _config.port,
        );

    Future<void> build() async {
        
        for (var t in _tasks) {
            for (var topic in t.getTopicSubscriptions()) {
                _mqtt.subscribe(topic, _config.subscriptionQot);          
            }
        }

        return Future.value();
    }

    Future<void> run() async {

        int count = 0;
        _run = true;

        while (_run) {
            try {
                _mqtt
                    ..logging(on: _config.logging)
                    ..setProtocolV311()
                    ..keepAlivePeriod = _config.keepAlivePeriod.inSeconds
                    ..connectTimeoutPeriod = _config.connectTimeoutPeriod.inMilliseconds
                    ..autoReconnect = true
                    ..connectionMessage = _getConnectMessage()
                ;

                count = (count += 1) % 10;
                await _mqtt.connect(_config.username, _config.password);
                break;
            } catch (e, s) {
                _errorLogger.log(e, s);
                await Future.delayed(Duration(seconds: count));
            }
        }

        _mqtt.updates!.listen((message) {
            try {
                final topic = message.first.topic;
                final value = (message.first.payload as MqttPublishMessage).payload.message;

                for (final t in _tasks) {
                    t.setNetworkProperty(
                        topic,
                        SmartBuffer()..addBuffer(value),
                    );
                }
            } catch (e, s) {
                _errorLogger.log(e, s);
            }
        });

        while (_mqtt.connectionStatus!.state == MqttConnectionState.connected) {
            await Future.delayed(_config.publicationPeriod);

            try {
                for (var t in _tasks) {
                    for (var item in t.getPeriodicallyPublishedValues().entries) {
                        _mqtt.publishMessage(
                            item.key,
                            _config.publicationQot,
                            item.value.payload,
                        );
                    }
                }
            } catch (e, s) {
                _errorLogger.log(e, s);
            }
        }
    }

    void publishMessage(String topic, Uint8Buffer message, [bool retain = false]) {
        _mqtt.publishMessage(topic, _config.publicationQot, message, retain: retain);
    }

    void cancel() {
        _run = false;
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
