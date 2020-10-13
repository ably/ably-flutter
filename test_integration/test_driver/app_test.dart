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

    test('AppKey provision', () async {
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
