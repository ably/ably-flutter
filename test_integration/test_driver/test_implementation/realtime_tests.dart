import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future testRealtimePublish(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.realtimePublish);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));
}

Future testRealtimeEvents(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.realtimeEvents);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

// TODO(tiholic) check more events
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
}
