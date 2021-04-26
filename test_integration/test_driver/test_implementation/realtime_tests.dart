import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils.dart';

Future testRealtimePublish(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePublish);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));
}

Future testRealtimeEvents(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimeEvents);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  final connectionStates = (response.payload['connectionStates'] as List)
      .map((e) => e as String)
      .toList();
  final connectionStateChanges =
      (response.payload['connectionStateChanges'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
  final filteredConnectionStateChanges =
      (response.payload['filteredConnectionStateChanges'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
  final channelStates = (response.payload['channelStates'] as List)
      .map((e) => e as String)
      .toList();
  final channelStateChanges = (response.payload['channelStateChanges'] as List)
      .map((e) => e as Map<String, dynamic>)
      .toList();
  final filteredChannelStateChanges =
      (response.payload['filteredChannelStateChanges'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

  // connectionStates
  expect(
      connectionStates,
      orderedEquals(const [
        'initialized',
        'initialized',
        'connected',
        'connected',
        'closed',
      ]));

  // connectionStateChanges
  expect(
      connectionStateChanges.map((e) => e['event']),
      orderedEquals(const [
        'connecting',
        'connected',
        'closing',
        'closed',
      ]));

  expect(
      connectionStateChanges.map((e) => e['current']),
      orderedEquals(const [
        'connecting',
        'connected',
        'closing',
        'closed',
      ]));

  expect(
      connectionStateChanges.map((e) => e['previous']),
      orderedEquals(const [
        'initialized',
        'connecting',
        'connected',
        'closing',
      ]));

  // filteredConnectionStateChanges
  expect(filteredConnectionStateChanges.map((e) => e['event']), const [
    'connected',
  ]);

  expect(filteredConnectionStateChanges.map((e) => e['current']), const [
    'connected',
  ]);

  expect(filteredConnectionStateChanges.map((e) => e['previous']), const [
    'connecting',
  ]);

  // channelStates
  expect(
      channelStates,
      orderedEquals(const [
        'initialized',
        'initialized',
        'attached',
        'attached',
        'detached',
        'detached',
      ]));

  // channelStateChanges

  // TODO(tiholic): get rid of _stateChangeEvents and _stateChangePrevious
  //  variables as they are a way to make tests pass due to
  //  https://github.com/ably/ably-flutter/issues/63
  List<String> _stateChangeEvents;
  List<String> _stateChangePrevious;
  if (channelStateChanges.length == 5) {
    // ios
    _stateChangeEvents = const [
      'attaching',
      'attached',
      'detaching',
      'detached',
      'detached',
    ];
    _stateChangePrevious = const [
      'initialized',
      'attaching',
      'attached',
      'detaching',
      'detached',
    ];
  } else {
    _stateChangeEvents = const [
      'attaching',
      'attached',
      'detaching',
      'detached',
    ];
    _stateChangePrevious = const [
      'initialized',
      'attaching',
      'attached',
      'detaching',
    ];
  }

  expect(channelStateChanges.map((e) => e['event']),
      orderedEquals(_stateChangeEvents));

  expect(channelStateChanges.map((e) => e['current']),
      orderedEquals(_stateChangeEvents));

  expect(channelStateChanges.map((e) => e['previous']),
      orderedEquals(_stateChangePrevious));

  // filteredChannelStateChanges
  expect(filteredChannelStateChanges.map((e) => e['event']),
      orderedEquals(const ['attaching']));

  expect(filteredChannelStateChanges.map((e) => e['current']),
      orderedEquals(const ['attaching']));

  expect(filteredChannelStateChanges.map((e) => e['previous']),
      orderedEquals(const ['initialized']));
}

Future testRealtimeSubscribe(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimeSubscribe);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  // Testing realtime subscribe to all messages
  final all = response.payload['all']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m as Map))
      .toList();

  testAllPublishedMessages(all);

  // Testing realtime subscribe to messages filtered with name
  final filteredWithName = response.payload['filteredWithName']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m as Map))
      .toList();

  expect(filteredWithName, isA<List<Map<String, dynamic>>>());
  expect(filteredWithName.length, equals(2));

  expect(filteredWithName[0]['name'], 'name1');
  expect(filteredWithName[0]['data'], isNull);

  expect(filteredWithName[1]['name'], 'name1');
  expect(filteredWithName[1]['data'], equals('Ably'));

  // Testing realtime subscribe to messages filtered with multiple names
  final filteredWithNames = response.payload['filteredWithNames']
      .map<Map<String, dynamic>>(
          (m) => Map.castFrom<dynamic, dynamic, String, dynamic>(m as Map))
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

Future testRealtimePublishWithAuthCallback(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePublishWithAuthCallback);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['handle'], isA<int>());
  expect(response.payload['handle'], greaterThan(0));

  expect(response.payload['authCallbackInvoked'], isTrue);
}

Future testRealtimeHistory(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimeHistory);

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

Future testRealtimePresenceGet(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePresenceGet);

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

Future testRealtimePresenceHistory(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePresenceHistory);

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

Future testRealtimeEnterUpdateLeave(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePresenceEnterUpdateLeave);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['clientIDClashMatrix'], isA<List>());
  expect(response.payload['actionMatrix'], isA<List>());

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  void testMatrixEntry(
    entry, {
    bool enter = false,
    bool update = false,
    bool leave = false,
    bool enterClient = false,
    bool updateClient = false,
    bool leaveClient = false,
  }) {
    expect(
      entry['enter'],
      equals(enter),
      reason: 'enter should be $enter for $entry',
    );
    expect(
      entry['update'],
      equals(update),
      reason: 'update should be $update for $entry',
    );
    expect(
      entry['leave'],
      equals(leave),
      reason: 'leave should be $leave for $entry',
    );
    expect(
      entry['enterClient'],
      equals(enterClient),
      reason: 'enterClient should be $enterClient for $entry',
    );
    expect(
      entry['updateClient'],
      equals(updateClient),
      reason: 'updateClient should be $updateClient for $entry',
    );
    expect(
      entry['leaveClient'],
      equals(leaveClient),
      reason: 'leaveClient should be $leaveClient for $entry',
    );
  }

  final clientIDClashMatrix =
      transform(response.payload['clientIDClashMatrix']);
  for (final clashEntry in clientIDClashMatrix) {
    final realtimeClientID = clashEntry['realtimeClientId'];
    final presenceClientID = clashEntry['presenceClientId'];

    if (realtimeClientID != presenceClientID) {
      if (realtimeClientID == null) {
        // only presenceClientID is present
        testMatrixEntry(
          clashEntry,
          enterClient: true,
          updateClient: true,
          leaveClient: true,
        );
      } else if (presenceClientID == null) {
        // only realtimeClientID is present
        testMatrixEntry(
          clashEntry,
          enter: true,
          update: true,
          leave: true,
        );
      } else {
        // both clientIDs are present and are unequal
        testMatrixEntry(
          clashEntry,
          enter: true,
          update: true,
          leave: true,
        );
      }
    } else {
      if (presenceClientID == null) {
        // both clientIDs are equal and null
        testMatrixEntry(clashEntry);
      } else {
        // both clientIDs are equal and not null
        testMatrixEntry(
          clashEntry,
          enter: true,
          update: true,
          leave: true,
          enterClient: true,
          updateClient: true,
          leaveClient: true,
        );
      }
    }
  }

  final actionMatrix = transform(response.payload['actionMatrix']);
  for (final actionEntry in actionMatrix) {
    // all cases should succeed
    testMatrixEntry(
      actionEntry,
      enter: true,
      update: true,
      leave: true,
      enterClient: true,
      updateClient: true,
      leaveClient: true,
    );
  }
}

Future testRealtimePresenceSubscription(FlutterDriver driver) async {
  const message = TestControlMessage(TestName.realtimePresenceSubscribe);

  final response = await getTestResponse(driver, message);

  expect(response.testName, message.testName);

  expect(response.payload['allMessages'], isA<List>());
  expect(response.payload['enterMessages'], isA<List>());
  expect(response.payload['enterUpdateMessages'], isA<List>());
  expect(response.payload['partialMessages'], isA<List>());

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  final allMessages = transform(response.payload['allMessages']);
  final enterMessages = transform(response.payload['enterMessages']);
  final enterUpdateMessages =
      transform(response.payload['enterUpdateMessages']);
  final partialMessages = transform(response.payload['partialMessages']);

  expect(allMessages.length, equals(8));
  expect(enterMessages.length, equals(1));
  expect(enterUpdateMessages.length, equals(7));
  expect(partialMessages.length, equals(7));

  void _test(List<Map<String, dynamic>> messages) {
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      expect(message['clientId'], equals('someClientId'));
      expect(
        message['action'],
        (i == 0) ? 'enter' : ((i < 7) ? 'update' : 'leave'),
      );
      checkMessageData(i, message['data']);
    }
  }

  _test(allMessages);
  _test(enterMessages);
  _test(enterUpdateMessages);
  expect(partialMessages, equals(enterUpdateMessages));
}
