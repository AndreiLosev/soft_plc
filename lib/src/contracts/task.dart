import 'package:soft_plc/src/service_container.dart';

abstract class AbstractTask {
  String addClassName(String name) => "${runtimeType.toString()}:$name";
  void execute(ServiceContainer container);
}

abstract class PeriodicTask extends AbstractTask {
  Duration get period;
}

abstract class EventTask<T extends Event> extends AbstractTask {
  Set<Type> get eventSubscriptions => {T};
  set event(T event);
}

abstract class ListeningTask extends AbstractTask {

  late void Function() saveRetain;
}

abstract class Event {}
