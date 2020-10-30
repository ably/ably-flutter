import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'test_implementation/basic_platform_tests.dart';
import 'test_implementation/helper_tests.dart';
import 'test_implementation/realtime_tests.dart';
import 'test_implementation/rest_tests.dart';

void main() {
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

  test('Realtime publish', () => testRealtimePublish(driver));

  test('Realtime events', () => testRealtimeEvents(driver));

  test('Realtime subscribe', () => testRealtimeSubscribe(driver));

  test('Rest publish', () => testRestPublish(driver));

  test('Rest publish should also succeed when run twice',
      () => testRestPublish(driver));

  test('Should report unhandled exception',
      () => testShouldReportUnhandledException(driver));

  // FlutterError seems to break the test app
  // and needs to be run last
  test(
      'Should report FlutterError', () => testShouldReportFlutterError(driver));
}
