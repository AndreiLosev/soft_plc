import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/system_events.dart';
import 'package:soft_plc/src/plc_fields/network_property_heandler.dart';
import 'package:soft_plc/src/service_container.dart';

class PublishMessageTask extends EventTask<PublishMessageEvent> {

    @override
    void execute(ServiceContainer container, PublishMessageEvent event) {
        container.get<NetworkPropertyHeandler>().publishMessage(
            event.topic,
            event.message,
        );
    }
}
