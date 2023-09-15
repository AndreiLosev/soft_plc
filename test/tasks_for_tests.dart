import 'package:soft_plc/src/contracts/property_handlers.dart';
import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/reatain_value.dart';
import 'package:soft_plc/src/service_container.dart';

class OneTask extends PeriodicTask implements ILoggingProperty, IRetainProperty {

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

    @override
    Map<String, ReatainValue<Object>> getRetainProperty() {
        return {
            addPrefix('x1'): ReatainNumValue(x1),
            addPrefix('x2'): ReatainNumValue(x2),
        };
    }

    @override
    void setRetainProperties(Map<String, ReatainValue> properties) {
        x1 = properties[addPrefix('x1')]!.value as int;
        x2 = properties[addPrefix('x2')]!.value as double;
    }
}
