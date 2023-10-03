import 'package:soft_plc/src/service_container.dart';

abstract class Task {
  String addClassName(String name) => "${runtimeType.toString()}:$name";
}

abstract class PeriodicTask extends Task {
  Duration get period;
  void execute(ServiceContainer container);
}

abstract class EventTask<T extends Event> extends Task {
  Set<Type> get eventSubscriptions => {T};
  void execute(ServiceContainer container, T event);
}

abstract class ListeningTask extends Task {
  Future<void> execute(
    ServiceContainer container,
    void Function() notification,
  );
}

abstract class Event {}
