import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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
