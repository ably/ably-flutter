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

  test('Rest publish', () async {
    final data = <String,dynamic>{};
    final message = TestControlMessage(TestName.restPublish, data);

    final result = await driver.requestData(message.toJson());
    final response = TestControlMessage.fromJson(result);

    print(response.payload);
    expect(response.testName, message.testName);

    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}
