import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'test_implementation/basic_platform_tests.dart';

void main() {
  group('Example Driver with WiFi', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        final _ = driver.close();
      }
    });

    test('Platform and Ably version', () => testPlatformAndAblyVersion(driver));

    test('AppKey provision', () => testAppKeyProvisioning(driver));
  });
}
