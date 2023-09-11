import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';

class Config {

    final MqttConfig mqttConfig;

    Config(this.mqttConfig);
    
    Duration get loggingPeriod => Duration(minutes: 10);

    String get database => defaultDatabase;
    String get sqlitePath => 'soft_pls.db'; 

    bool floatIsEquals(double a, double b) =>
        (a - b).abs() < 0.1;
}
