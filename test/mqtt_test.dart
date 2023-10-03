import 'dart:async';

import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:soft_plc/src/system/mqtt_311.dart';
import 'package:test/test.dart';

void main() {
  test('mqtt_simple_test', () async {
    const baseTopic = "/soft-plc/test/mqtt_311/";
    final client = Mqtt311(NetworkConfig());
    await client.connect();

    client.subscribe("$baseTopic#");

    client.listen((topic, buffer) {
      if (topic == "${baseTopic}x1") {
        expect(buffer.getAsString(), "55");
      } else if (topic == "${baseTopic}x2") {
        expect(buffer.getAsInt32(), 55);
      } else {
        expect(true, false);
      }
    });

    client.publication("${baseTopic}x1", SmartBuffer()..addString(55));
    client.publication("${baseTopic}x2", SmartBuffer()..addUint32(55));

    await Future.delayed(Duration(seconds: 1));

    await client.disconnect();
  });
}
