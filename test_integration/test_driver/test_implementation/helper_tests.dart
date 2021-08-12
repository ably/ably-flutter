import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void testShouldReportUnhandledException(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.testHelperUnhandledExceptionTest);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('returns appropriate error message', () {
    expect(response.payload['error']['exceptionType'], 'String');
    expect(response.payload['error']['exception'], contains('Unhandled'));
  });
}
