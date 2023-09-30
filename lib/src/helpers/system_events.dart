import 'package:soft_plc/src/contracts/task.dart';
import 'package:typed_data/typed_data.dart';

class PublishMqttMessage extends Event {
    final String topic;
    final Uint8Buffer message;
    final bool retain;

    PublishMqttMessage(this.topic, this.message, [this.retain = false]);
}
