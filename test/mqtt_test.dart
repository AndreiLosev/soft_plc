import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:soft_plc/src/configs/network_config.dart';
import 'package:soft_plc/src/helpers/smart_buffer.dart';
import 'package:soft_plc/src/plc_fields/network_property_handler.dart';
import 'package:soft_plc/src/system/console_error_logger.dart';
import 'package:soft_plc/src/system/event_queue.dart';
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
    final task3 = TwoTask();
    final config = TestConf();
    final eloger = ConsoleErrorLogger();
    final handler = NetworkPropertyHandler(
      [task2],
      [task1, task3],
      config,
      eloger,
      Mqtt311(config),
    );

    handler.run();

    Timer(Duration(milliseconds: 50), () {
      handler.publication(
        "soft_plc/test/handler_mqtt_test/${task3.addClassName('val')}",
        SmartBuffer()..addString('wasa'),
      );
    });

    await Future.delayed(Duration(milliseconds: 200));

    handler.cancel();

    expect(task1.x1, 11);
    expect(task1.x2.toString(), "9.88");
    expect(task3.val, 'wasa');

  });

  test('handler mqtt reconnect test', () async {
    final task1 = OneTask();
    final task2 = FifthTask();
    final task3 = TwoTask();
    final config = TestConf();
    final eloger = ConsoleErrorLogger();
    final handler = NetworkPropertyHandler(
      [task2],
      [task1, task3],
      config,
      eloger,
      Mqtt311(config),
    );

    handler.run();

    handler.publication(
      'soft_plc/test/handler_mqtt_test/x1',
      SmartBuffer()..addUint64(555),
    );

    await Future.delayed(Duration(milliseconds: 100));
    
    dockerStop();

    handler.publication(
      "soft_plc/test/handler_mqtt_test/${task3.addClassName('val')}",
      SmartBuffer()..addString(task1.x1),
    );

    dockerStart();
    
    task2.sumTwo = 999;

    await Future.delayed(Duration(milliseconds: 500));

    handler.cancel();

    expect(task3.val, '555');
    expect(task3.val2, '999');
  });

  tearDownAll(() => dockerComposeDown());
}


class TestConf extends NetworkConfig {
  @override
  String get host => '127.0.0.1';
  @override
  Duration get publicationPeriod => Duration(milliseconds: 50);
  @override
  Duration get autoReconnectPeriod => Duration(milliseconds: 10);
}


void dockerComposeUp() {
  Process.runSync("docker-compose", ["-f", dockerComposePath(), 'up', "-d"]);
}

void dockerComposeDown() {
  Process.runSync("docker-compose", ["-f", dockerComposePath(), 'down']);
}

void dockerStop() {
  Process.runSync('docker', ['stop', 'mqtt-test']);
}

void dockerStart() {
  Process.runSync('docker', ['start', 'mqtt-test']);
}

String dockerComposePath() {
  final pathTodcfile = [Directory.current.path];

  if (!Directory.current.path.contains('test')) {
    pathTodcfile.add('test');
  }
  pathTodcfile.add("docker-compose.yml");

  return joinAll(pathTodcfile);
}
