@Timeout(Duration(seconds: 45))
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

Future testRealtimeSubscribe(FlutterDriver driver) async {
  final message = TestControlMessage(TestName.realtimeSubscribe);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  List<Map<String, dynamic>> messages = response.payload['messages']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m))
      .toList();

  expect(messages, isA<List<Map<String, dynamic>>>());
  expect(messages.length, equals(8));

  expect(messages[0]['name'], isNull);
  expect(messages[0]['data'], isNull);

  expect(messages[1]['name'], isNull);
  expect(messages[1]['data'], equals('Ably'));

  expect(messages[2]['name'], 'Hello');
  expect(messages[2]['data'], isNull);
  expect(messages[3]['data'], equals('Ably'));
  expect(messages[4]['data'], equals([1, 2, 3]));
  expect(messages[5]['data'], equals(['hello', 'ably']));
  expect(
      messages[6]['data'],
      equals({
        'hello': 'ably',
        'items': ['1', 2.2, true]
      }));
  expect(
      messages[7]['data'],
      equals([
        {'hello': 'ably'},
        'ably',
        'realtime'
      ]));
}
