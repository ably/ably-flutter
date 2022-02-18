import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void testPushNotificationActivation(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.pushNotificationActivationTest);
  late TestControlResponseMessage response;

  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('rest instance has a valid handle on activation', () {
    expect(response.payload['restPushHandle'], isA<int>());
    expect(response.payload['restPushHandle'], greaterThan(0));
  });

  test('realtime instance has a valid handle on activation', () {
    expect(response.payload['realtimePushHandle'], isA<int>());
    expect(response.payload['realtimePushHandle'], greaterThan(0));
  });
}

void testPushNotificationDeactivation(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.pushNotificationDeactivationTest);
  late TestControlResponseMessage response;

  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('rest instance has a valid handle on deactivation', () {
    expect(response.payload['restPushHandle'], isA<int>());
    expect(response.payload['restPushHandle'], greaterThan(0));
  });

  test('realtime instance has a valid handle on deactivation', () {
    expect(response.payload['realtimePushHandle'], isA<int>());
    expect(response.payload['realtimePushHandle'], greaterThan(0));
  });
}
