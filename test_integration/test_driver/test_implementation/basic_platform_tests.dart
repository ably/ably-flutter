import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void testPlatformAndAblyVersion(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.platformAndAblyVersion);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('platformVersion is a string', () {
    expect(response.payload['platformVersion'], isA<String>());
  });

  test('platformVersion is not empty', () {
    expect(response.payload['platformVersion'], isNot(isEmpty));
  });

  test('ablyVersion is a string', () {
    expect(response.payload['ablyVersion'], isA<String>());
  });

  test('ablyVersion is not empty', () {
    expect(response.payload['ablyVersion'], isNot(isEmpty));
  });
}

void testDemoDependencies(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.appKeyProvisioning);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('appKey is a string', () {
    expect(response.payload['appKey'], isA<String>());
    expect(response.payload['appKey'], isNotEmpty);
  });

  group('token request has', () {
    late Map<String, dynamic> tokenRequest;

    setUp(() {
      tokenRequest = response.payload['tokenRequest'] as Map<String, dynamic>;
    });

    test('non-empty keyName', () {
      expect(tokenRequest['keyName'], isA<String>());
      expect(tokenRequest['keyName'], isNotEmpty);
    });

    test('non-empty nonce', () {
      expect(tokenRequest['nonce'], isA<String>());
      expect(tokenRequest['nonce'], isNotEmpty);
    });

    test('non-empty mac', () {
      expect(tokenRequest['mac'], isA<String>());
      expect(tokenRequest['mac'], isNotEmpty);
    });

    test('non-empty timestamp', () {
      expect(tokenRequest['timestamp'], isA<int>());
    });

    test('non-empty ttl', () {
      expect(tokenRequest['ttl'], isA<int>());
    });
  });
}
