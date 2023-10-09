import 'package:soft_plc/src/service_container.dart';

abstract class Task {
  String addClassName(String name) => "${runtimeType.toString()}:$name";
  void execute(ServiceContainer container);
}

abstract class PeriodicTask extends Task {
  Duration get period;
}

abstract class EventTask<T extends Event> extends Task {
  Set<Type> get eventSubscriptions => {T};
  set event(T event);
}

abstract class ListeningTask extends Task {

  late void Function() saveRetain;
}

abstract class Event {}
