import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:ably_flutter_integration_test/test_names.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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

  test('Realtime publish', () async {
    final data = <String, dynamic>{};
    final message = TestControlMessage(TestName.realtimePublish, data);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });

  test('Realtime events', () async {
    final data = <String, dynamic>{};
    final message = TestControlMessage(TestName.realtimeEvents, data);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    // TODO(zoechi) check more events
    expect(
        ((response.payload['connectionStates'] as List).last as Map)['current'],
        'connected');
  });
}
