import 'package:soft_plc/src/contracts/task.dart';
import 'package:typed_data/typed_data.dart';

class PublishMessageEvent extends Event {
    final String topic;
    final Uint8Buffer message;

    PublishMessageEvent(this.topic, this.message);
}
