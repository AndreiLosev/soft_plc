import 'package:soft_plc/src/service_container.dart';

abstract class Task {
    String addPrefix(String name) => 
        "${runtimeType.toString()}:$name";
}

abstract class PeriodicTask extends Task {
    Duration get period;
    void execute(ServiceContainer container);
}

abstract class EventTask<T extends Event> extends Task {
    Set<String> get eventSubscriptions;
    void execute(ServiceContainer container, T event);

}

abstract class Event {
    String get name => runtimeType.toString();
}
