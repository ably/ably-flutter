import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'test_implementation/realtime_tests.dart';

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

  test('Realtime publish', () => testRealtimePublish(driver));

  test('Realtime events', () => testRealtimeEvents(driver));

  // TODO(tiholic) Remove
  test('Realtime events 2', () async {
    final message = TestControlMessage(TestName.realtimeEvents);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    // TODO(zoechi) check more events
    expect(
        ((response.payload['connectionStates'] as List).last as Map)['current'],
        'connected');
  });
}
