import 'package:mqtt_client/mqtt_client.dart';

class NetworkConfig {
  String get host => "test.mosquitto.org";
  int get port => 1883;

  String? get username => null;
  String? get password => null;

  String get clientIdentifier => 'soft_plc_default_id';

  Duration get keepAlivePeriod => const Duration(minutes: 5);
  Duration get connectTimeoutPeriod => const Duration(seconds: 2);

  bool get logging => false;

  bool get autoReconnect => true;

  MqttQos get subscriptionQot => MqttQos.atMostOnce;
  MqttQos get publicationQot => MqttQos.atMostOnce;

  Map<String, bool> get publicationRetain => {};

  String? get willTopic => null;
  String? get willMessage => null;
  MqttQos get willQos => MqttQos.atMostOnce;

  bool get cleanSession => true;

  bool get willRetain => false;

  int get numberAttemptsConnect => 3;

  Duration publicationPeriod = const Duration(milliseconds: 200);

  Duration autoReconnectPeriod = const Duration(seconds: 2);
}
