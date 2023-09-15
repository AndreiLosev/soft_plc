import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/service_container.dart';

class OneTask extends PeriodicTask implements ILoggingProperty {

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
            addPrefix('x1'): x1,
            addPrefix('x2'): x2,
        };
    }
}
