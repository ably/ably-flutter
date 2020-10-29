import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'test_implementation/helper_tests.dart';

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

  test('Should report unhandled exception',
      () => testShouldReportUnhandledException(driver));

  // FlutterError seems to break the test app
  // and needs to be run last
  test(
      'Should report FlutterError', () => testShouldReportFlutterError(driver));
}
