import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void testPushNotificationActivate(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.pushNotificationActivate);
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

void testPushNotificationDeactivate(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.pushNotificationDeactivate);
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

void testPushNotificationChannelSubscribe(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.pushNotificationChannelSubscribe);
  late TestControlResponseMessage response;

  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('rest push channel instance has a valid handle on subscribe', () {
    expect(response.payload['restPushChannelHandle'], isA<int>());
    expect(response.payload['restPushChannelHandle'], greaterThan(0));
  });

  test('realtime push channel instance has a valid handle on subscribe', () {
    expect(response.payload['realtimePushChannelHandle'], isA<int>());
    expect(response.payload['realtimePushChannelHandle'], greaterThan(0));
  });
}

void testPushNotificationChannelSubscriptionList(
    FlutterDriver Function() getDriver) {
  const message =
      TestControlMessage(TestName.testPushNotificationChannelSubscriptionList);
  late TestControlResponseMessage response;

  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  // TODO(ikurek): Tests here will always fail on Android
  // Because there's no Firebase App inscance created
}
