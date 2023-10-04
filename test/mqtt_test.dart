import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:soft_plc/src/system/mqtt_311.dart';
import 'package:test/test.dart';

void main() {
  test('mqtt_simple_test', () async {

    final pathTodcfile = [Directory.current.path];

    if (!Directory.current.path.contains('test')) {
      pathTodcfile.add('test');
    }
    pathTodcfile.add("docker-compose.yml");

    final dcfile = joinAll(pathTodcfile);

    final pr = Process.runSync("docker-compose", ["-f", dcfile, "up", "-d"]);



    print(pr.stdout);

    const baseTopic = "/soft-plc/test/mqtt_311/";
    final client = Mqtt311(TestConf());
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

    Process.runSync("docker-compose", ["down"]);
  });
}


class TestConf extends NetworkConfig {
  @override
  String get host => '127.0.0.1';
}



