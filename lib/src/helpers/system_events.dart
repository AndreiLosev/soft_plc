import 'package:soft_plc/src/contracts/task.dart';
import 'package:typed_data/typed_data.dart';

class PublishMqttMessage extends Event {
    final String topic;
    final Uint8Buffer message;

    PublishMqttMessage(this.topic, this.message);
}
