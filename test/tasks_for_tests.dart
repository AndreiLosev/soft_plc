import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/reatain_value.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:soft_plc/src/service_container.dart';

class OneTask extends PeriodicTask
    implements ILoggingProperty, IRetainProperty, IMonitoringProperty, INetworkSubscriber {
  int x1 = 0;
  double x2 = 0.0;

  @override
  Duration get period => Duration(milliseconds: 15);

  @override
  void execute(ServiceContainer container) {
    x1 += 1;
    x2 += 1.1;
  }

  @override
  Map<String, Object> getLoggingProperty() {
    return {
      addClassName('x1'): x1,
      addClassName('x2'): x2,
    };
  }

  @override
  Map<String, ReatainValue<Object>> getRetainProperty() {
    return {
      addClassName('x1'): ReatainNumValue(x1),
      addClassName('x2'): ReatainNumValue(x2),
    };
  }

  @override
  Set<String> getTopicSubscriptions() {
    return {
      'soft_plc/test/handler_mqtt_test/x1',
      'soft_plc/test/handler_mqtt_test/x2',
    };    
  }

  @override
  void setNetworkProperty(String topic, SmartBuffer value) {
    switch (topic) {
      case 'soft_plc/test/handler_mqtt_test/x1':
        x1 = value.getAsInt64();
      case 'soft_plc/test/handler_mqtt_test/x2':
        x2 = value.getAsDouble();
    }
  }

  @override
  void setRetainProperties(Map<String, ReatainValue> properties) {
    x1 = properties[addClassName('x1')]!.value as int;
    x2 = properties[addClassName('x2')]!.value as double;
  }

  @override
  List<(String, Object)> getEventValues() {
    return [('xfghjkl', x1)];
  }

  @override
  Event getEventById(String id) {
    return switch (id) {
      'xfghjkl' => TwoEvent(x1),
      _ => TwoEvent(55555),
    };
  }
}

class TwoTask extends EventTask<TwoEvent> implements INetworkSubscriber {
  String val = '0';
  String val2 = "";
  late TwoEvent _e;

  @override
  set event(TwoEvent event) {
    _e = event;
  }

  @override
  void execute(ServiceContainer container) {
    val = "$val ${_e.val}";
  }

  @override
  Set<String> getTopicSubscriptions() {
    return {
      "soft_plc/test/handler_mqtt_test/${addClassName('val')}",
      "soft_plc/test/handler_mqtt_test/${addClassName('val2')}"
    };
  }

  @override
  void setNetworkProperty(String topic, SmartBuffer value) {
    if (topic == "soft_plc/test/handler_mqtt_test/${addClassName('val')}") {
      val = value.getAsString();
    } else if (topic == "soft_plc/test/handler_mqtt_test/${addClassName('val2')}") {
      val2 = value.getAsString();
    }
  }
}

class FourthTask extends EventTask<FourthEvent> {
  int sum = 0;
  late FourthEvent _e;

  @override
  set event(FourthEvent event) {
    _e = event;
  }

  @override
  void execute(ServiceContainer container) {
    sum += _e.list.reduce((v, e) => v + e);
  }
}

class FourthEvent extends Event {
  final List<int> list;

  FourthEvent(this.list);
}

class FifthTask extends EventTask<Event> implements INetworkPublisher {
  int sumTwo = 0;
  int sumFourth = 0;
  int product = 0;
  late Event _e;

  @override
  Set<Type> get eventSubscriptions => {FourthEvent, TwoEvent};

  @override
  set event(Event event) {
    _e = event;
  }

  @override
  void execute(ServiceContainer container) {
    if (_e is TwoEvent) {
      sumTwo += (_e as TwoEvent).val;
    }

    if (_e is FourthEvent) {
      sumFourth += (_e as FourthEvent).list.reduce((v, e) => v + e);
    }

    product = sumTwo * sumFourth;
  }

  @override
  Map<String, SmartBuffer> getPeriodicallyPublishedValues() {
    return {
      "soft_plc/test/handler_mqtt_test/TwoTask:val2": SmartBuffer()..addString(sumTwo),
    };
  }
}

class ThreeTask extends PeriodicTask implements INetworkPublisher {
  String s = "1";

  @override
  Duration get period => Duration(milliseconds: 15);

  @override
  void execute(ServiceContainer container) {
    s = "1 $s";
  }

  @override
  Map<String, SmartBuffer> getPeriodicallyPublishedValues() {
    return {
      'soft_plc/test/handler_mqtt_test/x1': SmartBuffer()..addUint64(11),
      'soft_plc/test/handler_mqtt_test/x2': SmartBuffer()..addDouble(9.88),
    };
  }
}

class TwoEvent extends Event {
  final int val;

  TwoEvent(this.val);
}
