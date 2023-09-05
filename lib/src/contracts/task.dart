import 'package:soft_plc/src/service_container.dart';

abstract class Task {
    void execute(ServiceContainer container);

    String classNamePrefix(String name) => 
        "${runtimeType.toString()}:$name";
}

abstract class PeriodicTask extends Task {
    Duration getPeriod();
}

abstract class EventTask extends Task {
    String getEvent();
}
