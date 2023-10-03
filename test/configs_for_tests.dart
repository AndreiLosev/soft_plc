import 'package:soft_plc/src/config.dart';
import 'package:soft_plc/src/configs/network_config.dart';

class LoggingHandlerConfig extends Config {
    
    LoggingHandlerConfig(): super(NetworkConfig());

    @override
    Duration get loggingPeriod => Duration(milliseconds: 20);
}
