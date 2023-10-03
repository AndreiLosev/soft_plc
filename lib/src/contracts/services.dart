import 'package:soft_plc/src/helpers/reatain_value.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';

abstract interface class IReatainService {
  Future<void> createIfNotExists(String name, ReatainValue value);

  Future<void> update(String name, ReatainValue value);

  Future<Map<String, ReatainValue>> select(Set<String> names);
}

abstract interface class IErrorLogger {
  Future<void> build();
  Future<void> log(Object e, StackTrace s, [bool isFatal = false]);
}

abstract interface class ILoggingService {
  Future<void> build();

  Future<void> setLog(Map<String, Object> property);
}

abstract interface class IUsesDatabase {
  String get table;
}

typedef DbRow = Map<String, Object?>;

abstract interface class IDbConnect {
  Future<void> execute(String sql, [List<Object?> params = const []]);

  Future<List<DbRow>> select(
    String sql, [
    List<Object?> params = const [],
  ]);
}

abstract interface class INetworkService {
  Future<void> connect();
  Future<void> disconnect();
  void subscribe(String topic);
  bool topicContains(Set<String> topics, String topic);
  void listen(void Function(String topic, SmartBuffer buffer) onData);
  void publication(String topic, SmartBuffer buffer);
  bool isConnected();
}
