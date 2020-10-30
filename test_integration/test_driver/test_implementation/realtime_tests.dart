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

  // Testing realtime subscribe to all messages
  List<Map<String, dynamic>> all = response.payload['all']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m))
      .toList();

  expect(all, isA<List<Map<String, dynamic>>>());
  expect(all.length, equals(8));

  expect(all[0]['name'], isNull);
  expect(all[0]['data'], isNull);

  expect(all[1]['name'], isNull);
  expect(all[1]['data'], equals('Ably'));

  expect(all[2]['name'], 'name1');
  expect(all[2]['data'], isNull);

  expect(all[3]['name'], 'name1');
  expect(all[3]['data'], equals('Ably'));

  expect(all[4]['name'], 'name2');
  expect(all[4]['data'], equals([1, 2, 3]));

  expect(all[5]['name'], 'name2');
  expect(all[5]['data'], equals(['hello', 'ably']));

  expect(all[6]['name'], 'name3');
  expect(
      all[6]['data'],
      equals({
        'hello': 'ably',
        'items': ['1', 2.2, true]
      }));

  expect(all[7]['name'], 'name3');
  expect(
      all[7]['data'],
      equals([
        {'hello': 'ably'},
        'ably',
        'realtime'
      ]));

  // Testing realtime subscribe to messages filtered with name
  List<Map<String, dynamic>> filteredWithName = response
      .payload['filteredWithName']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m))
      .toList();

  expect(filteredWithName, isA<List<Map<String, dynamic>>>());
  expect(filteredWithName.length, equals(2));

  expect(filteredWithName[0]['name'], 'name1');
  expect(filteredWithName[0]['data'], isNull);

  expect(filteredWithName[1]['name'], 'name1');
  expect(filteredWithName[1]['data'], equals('Ably'));

  // Testing realtime subscribe to messages filtered with multiple names
  List<Map<String, dynamic>> filteredWithNames = response
      .payload['filteredWithNames']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m))
      .toList();

  expect(filteredWithNames, isA<List<Map<String, dynamic>>>());
  expect(filteredWithNames.length, equals(4));

  expect(filteredWithNames[0]['name'], 'name1');
  expect(filteredWithNames[0]['data'], isNull);

  expect(filteredWithNames[1]['name'], 'name1');
  expect(filteredWithNames[1]['data'], equals('Ably'));

  expect(filteredWithNames[2]['name'], 'name2');
  expect(filteredWithNames[2]['data'], equals([1, 2, 3]));

  expect(filteredWithNames[3]['name'], 'name2');
  expect(filteredWithNames[3]['data'], equals(['hello', 'ably']));

}
