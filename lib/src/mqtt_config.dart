import 'package:mqtt_client/mqtt_client.dart';

class MqttConfig {

    String get host => 'test.mosquitto.org';
    int get port => 1883;
    
    String? get lastWilTopic => null;
    String? get lastWilMessage => null;
    MqttQos get lastWilQos => MqttQos.atMostOnce;

    Duration get keepAlivePeriod => Duration(seconds: 60);
    Duration get connectTimeoutPeriod => Duration(seconds: 2);

    String? get username => null;
    String? get password => null;
}
