import 'package:soft_plc/src/helpers/smart_buffer.dart';

class Debug {
  const Debug();
}

class Task {
  const Task();
}

class Retain {
  const Retain();
}

class Logging {
  const Logging();
}

class Monitoring {
  final Type eventType;
  final String? eventFactory;
  const Monitoring(this.eventType, [this.eventFactory]);
}

class NetworkSubscriber {
  final String topic;
  final BinType? type;
  final String? factory;
  final bool bigEndian;
  const NetworkSubscriber(this.topic, {this.type, this.factory, this.bigEndian = false});
}

class NetworkPublisher {
  final String topic;
  final BinType? type;
  final String? factory;
  final bool bigEndian;
  const NetworkPublisher(this.topic, {this.type, this.factory, this.bigEndian = false});
}
