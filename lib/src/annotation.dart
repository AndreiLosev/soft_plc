import 'package:soft_plc/src/helpers/smart_buffer.dart';

class Debug {
  const Debug();
}

class Task {
  const Task();
}

class Retain {
  final Type? reatainValueType;
  const Retain([this.reatainValueType]);
}

class Logging {
  const Logging();
}

class Monitoring {
  final Type eventType;
  final List<String>? eventParams;
  final String? eventFactory;
  const Monitoring(this.eventType, {this.eventParams, this.eventFactory});
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
