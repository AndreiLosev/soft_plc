import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/configs/mqtt_config.dart';

class LoggingHandlerConfig extends Config {
    
    LoggingHandlerConfig(): super(MqttConfig());

    @override
    Duration get loggingPeriod => Duration(milliseconds: 20);
}
