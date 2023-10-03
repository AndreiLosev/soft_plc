import 'package:soft_plc/src/contracts/task.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';

class PublishNetwokMessage extends Event {
    final String topic;
    final SmartBuffer message;

    PublishNetwokMessage(this.topic, this.message);
}
