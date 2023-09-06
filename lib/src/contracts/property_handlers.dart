import 'package:soft_plc/src/contracts/task.dart';

abstract interface class IRetainProperty {
    
    Map<String, Object> getRetainProperty();
    void setRetainProperties(Map<String, Object> properties);
}

abstract interface class ILoggingProperty {
    
    Map<String, Object> getLoggingProperty();
}

abstract interface class IMonitoringProperty {
    
    List<(Event, Object)> getEventValues();
    bool floatIsEquals(double a, double b);
}

abstract interface class INetworkProperty {

    Map<String, Object> getNetworkProperty();
    void setNetworkProperty(Map<String, Object> properties);
}
