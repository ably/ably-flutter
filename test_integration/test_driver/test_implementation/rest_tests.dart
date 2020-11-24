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
