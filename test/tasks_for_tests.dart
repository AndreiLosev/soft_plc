import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/reatain_value.dart';
import 'package:soft_plc/src/service_container.dart';

class OneTask extends PeriodicTask
    implements ILoggingProperty, IRetainProperty, IMonitoringProperty {
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
  void setRetainProperties(Map<String, ReatainValue> properties) {
    x1 = properties[addClassName('x1')]!.value as int;
    x2 = properties[addClassName('x2')]!.value as double;
  }

  @override
  List<(Event, Object)> getEventValues() {
    return [(TwoEvent(x1), x1)];
  }
}

class TwoTask extends EventTask<TwoEvent> {
  String val = '0';

  @override
  void execute(ServiceContainer container, TwoEvent event) {
    val = "$val ${event.val}";
  }
}

class FourthTask extends EventTask<FourthEvent> {
  int sum = 0;

  @override
  void execute(ServiceContainer container, FourthEvent event) {
    sum += event.list.reduce((v, e) => v + e);
  }
}

class FourthEvent extends Event {
  final List<int> list;

  FourthEvent(this.list);
}

class FifthTask extends EventTask<Event> {
  int sumTwo = 0;
  int sumFourth = 0;
  int product = 0;

  @override
  Set<Type> get eventSubscriptions => {FourthEvent, TwoEvent};

  @override
  void execute(ServiceContainer container, Event event) {
    if (event is TwoEvent) {
      sumTwo += event.val;
    }

    if (event is FourthEvent) {
      sumFourth += event.list.reduce((v, e) => v + e);
    }

    product = sumTwo * sumFourth;
  }
}

class ThreeTask extends PeriodicTask {
  String s = "1";

  @override
  Duration get period => Duration(milliseconds: 15);

  @override
  void execute(ServiceContainer container) {
    s = "1 $s";
  }
}

class TwoEvent extends Event {
  final int val;

  TwoEvent(this.val);
}
