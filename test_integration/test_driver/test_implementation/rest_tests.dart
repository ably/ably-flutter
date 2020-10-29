import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future testImplementation(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.restPublish);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  // TODO(zoechi) there probably should be log messages
  // expect(response.payload['log'], isNotEmpty);
}