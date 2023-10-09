import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/system_events.dart';
import 'package:soft_plc/src/plc_fields/network_property_handler.dart';
import 'package:soft_plc/src/service_container.dart';

class PublishMessageTask extends EventTask<PublishNetwokMessage> {

  late PublishNetwokMessage e;

  @override
  set event(PublishNetwokMessage event) {
    e = event;
  }

  @override
  void execute(ServiceContainer container) {
    container.get<NetworkPropertyHandler>().publication(
          e.topic,
          e.message,
        );
  }
}
