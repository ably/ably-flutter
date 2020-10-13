@Timeout.factor(3)

import 'package:ably_flutter_integration_test/driver_data_handler.dart';

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

  test('Realtime publish', () async {
    final message = TestControlMessage(TestName.realtimePublish);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });

  test('Realtime events', () async {
    final message = TestControlMessage(TestName.realtimeEvents);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    // TODO(zoechi) check more events
    expect(
        (response.payload['connectionStates'] as List)
            .map((e) => (e as Map)['event']),
        orderedEquals(const [
          'connecting',
          'connected',
        ]));

    expect(
        (response.payload['filteredConnectionStates'] as List)
            .map((e) => (e as Map)['event']),
        const []);

    expect(
        (response.payload['channelStates'] as List)
            .map((e) => (e as Map)['event']),
        orderedEquals(const [
          'attaching',
          'attached',
        ]));
    expect(
        (response.payload['filteredChannelStates'] as List)
            .map((e) => (e as Map)['event']),
        orderedEquals(const [
          'attaching',
        ]));
  });

  Future testImplementation(FlutterDriver driver) async {
    final message = TestControlMessage(TestName.restPublish);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));

    // TODO(zoechi) there probably should be log messages
    // expect(response.payload['log'], isNotEmpty);
  }

  test('Rest publish', () => testImplementation(driver));

  test('Rest publish should also succeed when run twice',
      () => testImplementation(driver));

  test('Should report unhandled exception', () async {
    final message =
        TestControlMessage(TestName.testHelperUnhandledExceptionTest);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['error']['exceptionType'], 'String');
    expect(response.payload['error']['exception'], contains('Unhandled'));
  });

  // FlutterError breaks the test app and needs to be run last
  test('Should report FlutterError', () async {
    final message = TestControlMessage(TestName.testHelperFlutterErrorTest);

    final response = await getTestResponse(driver, message);

    expect(response.testName, message.testName);

    expect(response.payload['error']['exceptionType'], 'String');
    expect(response.payload['error']['exception'], contains('FlutterError'));
  });
}
