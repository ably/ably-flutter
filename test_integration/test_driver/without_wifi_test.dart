@TestOn('android') // because disable wifi only works for Android
import 'dart:io';

import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Example Driver without WiFi', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      await disableWifi();

      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        final _ = driver.close();
      }

      await enableWifi();
    });

    // TODO(zoechi) these are not valid tests to be run without wifi
    test('version', () async {
      final data = {'message': 'foo'};
      final message = TestControlMessage('version', data);

      final result = await driver.requestData(message.toJson());
      final response = TestControlMessage.fromJson(result);

      expect(response.testName, message.testName);

      // Use the `driver.getText` method to verify the counter starts at 0.
      expect(response.payload['platformVersion'], 'Android 10');
      expect(response.payload['ablyVersion'], 'android-1.1.10');
    });

    test('provision ', () async {
      final data = {'message': 'foo'};
      final message = TestControlMessage('provision', data);

      final response = TestControlMessage.fromJson(
          await driver.requestData(message.toJson()));

      expect(response.testName, message.testName);

      // Use the `driver.getText` method to verify the counter starts at 0.
      expect(response.payload['appKey'], isA<String>());
      expect(response.payload['appKey'], isNotEmpty);
    });
  });
}

Future disableWifi() async {
  // TODO(zoechi)
  // from https://stackoverflow.com/questions/10033757/how-to-turn-off-wifi-via-adb
  // but didn't work because `su` is not found on my phone
  // perhaps it's working with the emulator
  await Process.run('adb', ['shell', 'su', '-c', 'svc wifi disable']);

  // This worked on my phone
  // await Process.run('adb', ['shell', 'svc wifi disable']);
}

Future enableWifi() async {
  await Process.run('adb', ['shell', 'su', '-c', 'svc wifi enable']);

  // This doesn't work on my phone because I'm debugging over WiFi and
  // I can't enable it over WiFi when it's disabled.
  // await Process.run('adb', ['shell', 'svc wifi enable']);
}
