import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils.dart';

Future testRestPublish(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPublish);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));
}

Future testRestPublishSpec(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPublishSpec);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  expect(response.payload['exception'], isA<Map>());
  expect(response.payload['publishedMessages'], isA<List>());
  expect(response.payload['publishedMessages2'], isA<List>());

  final messages = response.payload['publishedMessages'] as List;
  final messages2 = response.payload['publishedMessages2'] as List;
  final exception = Map.castFrom<dynamic, dynamic, String, dynamic>(
      response.payload['exception'] as Map);

  // publish without name and data
  expect(messages[0]['name'], null);
  expect(messages[0]['data'], null);

  // publish without data
  expect(messages[1]['name'], 'name1');
  expect(messages[1]['data'], null);

  // publish without name
  expect(messages[2]['name'], null);
  expect(messages[2]['data'], 'data1');

  // publish with name and data
  expect(messages[3]['name'], 'name1');
  expect(messages[3]['data'], 'data1');

  // publish as one Message object
  expect(messages[4]['name'], 'message-name1');
  expect(messages[4]['data'], 'message-data1');

  // publish multiple Messages at once
  expect(messages[5]['name'], 'messages-name1');
  expect(messages[5]['data'], 'messages-data1');
  expect(messages[6]['name'], 'messages-name2');
  expect(messages[6]['data'], 'messages-data2');
  expect(messages[5]['timestamp'] == messages[6]['timestamp'], true);
  expect(messages[5]['timestamp'] != messages[4]['timestamp'], true);

  // (RSL1d) Raises an error if the message was not successfully published
  //  -- and --
  // (RSL1m4) Publishing a Message with a clientId set to a different value
  //  from the clientId in the client options should result in a message
  //  being rejected by the server.
  expect(exception['code'], '14');
  expect(
    exception['message'],
    'Error publishing rest message;'
    ' err = attempted to publish message with an invalid clientId',
  );
  expect(exception['errorInfo']['message'],
      'attempted to publish message with an invalid clientId');

  // (RSL1m1) Publishing a Message with no clientId when the clientId
  //  is set to some value in the client options should result in a message
  //  received with the clientId property set to that value
  // expect(messages[0]['clientId'], 'someClientId');

  // (RSL1m2) Publishing a Message with a clientId set to the same
  //  value as the clientId in the client options should result in
  //  a message received with the clientId property set to that value
  expect(messages[7]['clientId'], 'someClientId');

  // (RSL1m3) Publishing a Message with a clientId set to a value
  //  from an unidentified client (no clientId in the client options
  //  and credentials that can assume any clientId) should result in
  //  a message received with the clientId property set to that value
  expect(messages2[0]['clientId'], 'client-id');
}

Future testRestPublishWithAuthCallback(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPublishWithAuthCallback);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  expect(response.payload['authCallbackInvoked'], isTrue);
}

Future testRestHistory(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restHistory);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  final paginatedResult =
      response.payload['paginatedResult'] as Map<String, dynamic>;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  final historyDefault = transform(response.payload['historyDefault']);
  final historyLimit4 = transform(response.payload['historyLimit4']);
  final historyLimit2 = transform(response.payload['historyLimit2']);
  final historyForwardLimit4 =
      transform(response.payload['historyForwardLimit4']);
  final historyWithStart = transform(response.payload['historyWithStart']);
  final historyWithStartAndEnd =
      transform(response.payload['historyWithStartAndEnd']);

  expect(paginatedResult['hasNext'], false);
  expect(paginatedResult['isLast'], true);
  expect(paginatedResult['items'], isA<List>());

  expect(historyDefault.length, equals(8));
  expect(historyLimit4.length, equals(8));
  expect(historyLimit2.length, equals(8));
  expect(historyForwardLimit4.length, equals(8));
  expect(historyWithStart.length, equals(2));
  expect(historyWithStartAndEnd.length, equals(1));

  testAllPublishedMessages(historyDefault.reversed.toList());
  testAllPublishedMessages(historyLimit4.reversed.toList());
  testAllPublishedMessages(historyLimit2.reversed.toList());
  testAllPublishedMessages(historyForwardLimit4);

  // start and no-end test (backward)
  expect(historyWithStart[0]['name'], equals('history'));
  expect(historyWithStart[0]['data'], equals('test2'));

  expect(historyWithStart[1]['name'], equals('history'));
  expect(historyWithStart[1]['data'], equals('test'));

  // start and end test
  expect(historyWithStartAndEnd[0]['name'], equals('history'));
  expect(historyWithStartAndEnd[0]['data'], equals('test'));
}

Future testRestPresenceGet(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPresenceGet);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  int timestampSorter(Map a, Map b) {
    if (DateTime.parse(a['timestamp'] as String).millisecondsSinceEpoch >
        DateTime.parse(b['timestamp'] as String).millisecondsSinceEpoch) {
      return 1;
    } else {
      return -1;
    }
  }

  final membersInitial = transform(response.payload['membersInitial']);
  expect(membersInitial.length, equals(0));

  final membersDefault = transform(response.payload['membersDefault']);
  expect(membersDefault.length, equals(8));
  testAllPresenceMembers(membersDefault..sort(timestampSorter));

  final membersLimit4 = transform(response.payload['membersLimit4']);
  expect(membersLimit4.length, equals(8));
  testAllPresenceMembers(membersLimit4..sort(timestampSorter));

  final membersLimit2 = transform(response.payload['membersLimit2']);
  expect(membersLimit2.length, equals(8));
  testAllPresenceMembers(membersLimit2..sort(timestampSorter));

  // there is only 1 client with clientId 'client-1
  final membersClientId = transform(response.payload['membersClientId']);
  expect(membersClientId.length, equals(1));
  expect(membersClientId[0]['clientId'], equals('client-1'));
  checkMessageData(1, membersClientId[0]['data']);

  // TODO similarly check for membersConnectionId after implementing
  //  connection id (sync from platform) on realtime connection
  final membersConnectionId =
      transform(response.payload['membersConnectionId']);
  expect(membersConnectionId.length, equals(0));
}

Future testRestPresenceHistory(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPresenceHistory);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  final historyInitial = transform(response.payload['historyInitial']);
  expect(historyInitial.length, equals(0));

  final historyDefault = transform(response.payload['historyDefault']);
  expect(historyDefault.length, equals(8));
  testAllPresenceMessagesHistory(historyDefault.reversed.toList());

  final historyLimit4 = transform(response.payload['historyLimit4']);
  expect(historyLimit4.length, equals(8));
  testAllPresenceMessagesHistory(historyLimit4.reversed.toList());

  final historyLimit2 = transform(response.payload['historyLimit2']);
  expect(historyLimit2.length, equals(8));
  testAllPresenceMessagesHistory(historyLimit2.reversed.toList());

  final historyForwards = transform(response.payload['historyForwards']);
  expect(historyForwards.length, equals(8));
  testAllPresenceMessagesHistory(historyForwards.toList());

  final historyWithStart =
      transform(response.payload['historyWithStart']).reversed.toList();
  expect(historyWithStart.length, equals(2));
  expect(historyWithStart[0]['clientId'], equals('someClientId'));
  expect(historyWithStart[0]['data'], equals('enter-start-time'));
  expect(historyWithStart[1]['clientId'], equals('someClientId'));
  expect(historyWithStart[1]['data'], equals('leave-end-time'));

  final historyWithStartAndEnd =
      transform(response.payload['historyWithStartAndEnd']);
  expect(historyWithStartAndEnd.length, equals(1));
  expect(historyWithStartAndEnd[0]['clientId'], equals('someClientId'));
  expect(historyWithStartAndEnd[0]['data'], equals('enter-start-time'));

  final historyAll = transform(response.payload['historyAll']);
  expect(historyAll.length, equals(10));
}
