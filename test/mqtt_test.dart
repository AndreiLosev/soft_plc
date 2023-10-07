import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:soft_plc/src/plc_fields/network_property_handler.dart';
import 'package:soft_plc/src/system/console_error_logger.dart';
import 'package:soft_plc/src/system/mqtt_311.dart';
import 'package:test/test.dart';

import 'tasks_for_tests.dart';

void main() {
  setUpAll(() => dockerComposeUp());

  test('mqtt_simple_test', () async {


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

    await Future.delayed(Duration(milliseconds: 100));

    await client.disconnect();
  });

  test('handler mqtt test', () async {
    final task1 = OneTask();
    final task2 = ThreeTask();
    final config = TestConf();
    final handler = NetworkPropertyHandler(
      [task2],
      [task1],
      config,
      ConsoleErrorLogger(),
      Mqtt311(config),
    );

    handler.run();

    await Future.delayed(Duration(milliseconds: 500));

    handler.cancel();

    expect(task1.x1, 11);
    expect(task1.x2.toString(), "9.88");

  });

  tearDownAll(() => dockerComposeDown());
}


class TestConf extends NetworkConfig {
  @override
  String get host => '127.0.0.1';
  @override
  Duration get publicationPeriod => Duration(milliseconds: 50);
}


void dockerComposeUp() {
  Process.runSync("docker-compose", ["-f", dockerComposePath(), 'up', "-d"]);
}

void dockerComposeDown() {
  Process.runSync("docker-compose", ["-f", dockerComposePath(), 'down']);
}

String dockerComposePath() {
  final pathTodcfile = [Directory.current.path];

  if (!Directory.current.path.contains('test')) {
    pathTodcfile.add('test');
  }
  pathTodcfile.add("docker-compose.yml");

  return joinAll(pathTodcfile);
}
