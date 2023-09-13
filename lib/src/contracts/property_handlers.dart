
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/mqtt_payload_builder.dart';
import 'package:soft_plc/src/helpers/reatain_value.dart';

abstract interface class IRetainProperty {
    
    Map<String, ReatainValue> getRetainProperty();
    void setRetainProperties(Map<String, ReatainValue> properties);
}

abstract interface class ILoggingProperty {
    
    Map<String, Object> getLoggingProperty();
}

abstract interface class IMonitoringProperty {
    
    List<(Event, Object)> getEventValues();
    bool floatIsEquals(double a, double b);
}

abstract interface class INetworkProperty {

    Set<String> getTopicSubscriptions();
    void setNetworkProperty(String topic, MqttPayloadBuilder value);
    Map<String, MqttPayloadBuilder> getPeriodicallyPublishedValues();
}
