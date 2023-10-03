import 'package:soft_plc/soft_plc.dart';
import 'package:soft_plc/src/configs/network_config.dart';

class Config {
  final NetworkConfig mqttConfig;

  Config(this.mqttConfig);

  Duration get loggingPeriod => Duration(minutes: 10);

  String get database => defaultDatabase;
  String get sqlitePath => 'soft_pls.db';

  bool floatIsEquals(double a, double b) => (a - b).abs() < 0.1;
}
