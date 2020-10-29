import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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

  test('Rest publish', () => testRestPublish(driver));

  test('Rest publish should also succeed when run twice',
      () => testRestPublish(driver));
}
