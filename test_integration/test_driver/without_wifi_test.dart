@TestOn('android')
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

    // TODO(tiholic) these are not valid tests when run without wifi,
    // This is just an example how such a test could be built.
    test('Platform and Ably version', () async {
      final data = {'message': 'foo'};
      final message =
          TestControlMessage(TestName.platformAndAblyVersion, payload: data);

      final response = await getTestResponse(driver, message);

      expect(response.testName, message.testName);

      expect(response.payload['platformVersion'], isA<String>());
      expect(response.payload['platformVersion'], isNot(isEmpty));
      expect(response.payload['ablyVersion'], isA<String>());
      expect(response.payload['ablyVersion'], isNot(isEmpty));
    });

    test('AppKey provision ', () async {
      final data = {'message': 'foo'};
      final message =
          TestControlMessage(TestName.appKeyProvisioning, payload: data);

      final response = await getTestResponse(driver, message);

      expect(response.testName, message.testName);

      expect(response.payload['appKey'], isA<String>());
      expect(response.payload['appKey'], isNotEmpty);
    });
  });
}

Future disableWifi() async {
  // TODO(tiholic)
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
