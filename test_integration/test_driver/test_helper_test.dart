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

  test('Should report unhandled exception', () async {
    final data = <String, dynamic>{};
    final message =
        TestControlMessage(TestName.testHelperUnhandledExceptionTest, data);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['error']['exceptionType'], 'String');
    expect(response.payload['error']['exception'], contains('Unhandled'));
  });

  // FlutterError seems to break the test app
  // and needs to be run last
  test('Should report FlutterError', () async {
    final data = <String, dynamic>{};
    final message =
        TestControlMessage(TestName.testHelperFlutterErrorTest, data);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['error']['exceptionType'], 'String');
    expect(response.payload['error']['exception'], contains('FlutterError'));
  });
}
