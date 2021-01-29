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

  // TODO(tiholic) enable this after implementing logger
  // expect(response.payload['log'], isNotEmpty);
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
  final membersInitial = transform(response.payload['membersInitial']);
  final membersDefault = transform(response.payload['membersDefault']);
  final membersLimit4 = transform(response.payload['membersLimit4']);
  final membersLimit2 = transform(response.payload['membersLimit2']);
  final membersClientId =
      transform(response.payload['membersClientId']);
  final membersConnectionId =
      transform(response.payload['membersConnectionId']);

  expect(membersInitial.length, equals(0));
  expect(membersDefault.length, equals(8));
  expect(membersLimit4.length, equals(8));
  expect(membersLimit2.length, equals(8));
  expect(membersClientId.length, equals(1));
  expect(membersConnectionId.length, equals(0));


  int timestampSorter(Map a, Map b){
    if (DateTime.parse(a['timestamp'] as String).millisecondsSinceEpoch >
        DateTime.parse(b['timestamp'] as String).millisecondsSinceEpoch) {
      return 1;
    } else {
      return -1;
    }
  }

  testAllPresenceMembers(membersDefault..sort(timestampSorter));
  testAllPresenceMembers(membersLimit4..sort(timestampSorter));
  testAllPresenceMembers(membersLimit2..sort(timestampSorter));

  // there is only 1 client with clientId 'client-1
  expect(membersClientId[0]['clientId'], equals('client-1'));
  checkMessageData(1, membersClientId[0]['data']);

  // TODO similarly check for membersConnectionId
}

Future testRestPresenceHistory(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.restPresenceHistory);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  final membersDefault = transform(response.payload['historyDefault']);
  final membersLimit4 = transform(response.payload['historyLimit4']);
  final membersLimit2 = transform(response.payload['historyLimit2']);
  final historyForwards = transform(response.payload['historyForwards']);
  final historyWithStart = transform(response.payload['historyWithStart']);
  final historyWithStartAndEnd =
      transform(response.payload['historyWithStartAndEnd']);
  final historyAll = transform(response.payload['historyAll']);

  expect(membersDefault.length, equals(0));
  expect(membersLimit4.length, equals(0));
  expect(membersLimit2.length, equals(0));
  expect(historyWithStart.length, equals(0));
  expect(historyWithStartAndEnd.length, equals(0));
  expect(historyAll.length, equals(0));

  testAllPresenceMembers(membersDefault.toList());
  testAllPresenceMembers(membersLimit4.toList());
  testAllPresenceMembers(membersLimit2.toList());
  testAllPresenceMembers(historyForwards.toList());
  testAllPresenceMembers(historyWithStart.toList());
  testAllPresenceMembers(historyWithStartAndEnd.toList());
  testAllPresenceMembers(historyAll.toList());
}
