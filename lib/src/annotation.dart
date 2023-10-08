import 'package:soft_plc/src/contracts/task.dart';

class Debug {
  const Debug();
}

class Retain {
  const Retain();
}

class Logging {
  const Logging();
}

class Monitoring {
  const Monitoring(Event e);
}

class NetworkSubscriber {
  const NetworkSubscriber(String topic);
}

class NetworkPublisher {
  const NetworkPublisher(String topic);
}
