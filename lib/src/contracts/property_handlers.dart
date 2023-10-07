import 'package:soft_plc/soft_plc.dart';

abstract interface class IRetainProperty {
  Map<String, ReatainValue> getRetainProperty();
  void setRetainProperties(Map<String, ReatainValue> properties);
}

abstract interface class ILoggingProperty {
  Map<String, Object> getLoggingProperty();
}

abstract interface class IMonitoringProperty {
  List<(Event, Object)> getEventValues();
}

abstract interface class INetworkSubscriber {
  Set<String> getTopicSubscriptions();
  void setNetworkProperty(String topic, SmartBuffer value);
}

abstract interface class INetworkPublisher {
  Map<String, SmartBuffer> getPeriodicallyPublishedValues();
}
