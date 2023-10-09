import 'package:soft_plc/src/contracts/task.dart';

class Debug {
  const Debug();
}

class PeriodicTaskAn {
  final Duration period;
  final Duration Function()? overridePeriod;

  const PeriodicTaskAn(this.period, [this.overridePeriod]);
}

class EventTaskAn<T extends Event> {
  final T event;
  final Set<Event>? overrideEventSubscriptions;

  const EventTaskAn(this.event, [this.overrideEventSubscriptions]);
}

class Retain {
  const Retain();
}

class Logging {
  const Logging();
}

class Monitoring {
  const Monitoring(Event e);
}

class NetworkSubscriber {
  const NetworkSubscriber(String topic);
}

class NetworkPublisher {
  const NetworkPublisher(String topic);
}
