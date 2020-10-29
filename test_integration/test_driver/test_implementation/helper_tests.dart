import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future testShouldReportUnhandledException(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.testHelperUnhandledExceptionTest);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['error']['exceptionType'], 'String');
  expect(response.payload['error']['exception'], contains('Unhandled'));
}

// FlutterError seems to break the test app
// and needs to be run last
Future testShouldReportFlutterError(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.testHelperFlutterErrorTest);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['error']['exceptionType'], 'String');
  expect(response.payload['error']['exception'], contains('FlutterError'));
}
