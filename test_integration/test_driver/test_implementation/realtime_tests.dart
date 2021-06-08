import 'dart:convert';

import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils.dart';

void testRealtimePublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePublish);
  const message2 = TestControlMessage(TestName.realtimePublishWithAuthCallback);
  TestControlMessage response;
  TestControlMessage response2;
  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    response2 = await getTestResponse(getDriver(), message2);
  });

  test('publishes message without any response', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
  test('invokes authCallback if available in clientOptions', () {
    expect(response2.payload['authCallbackInvoked'], isTrue);
  });
}

void testRealtimeEvents(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeEvents);
  TestControlMessage response;
  List<String> connectionStates;
  List<Map<String, dynamic>> connectionStateChanges;
  List<Map<String, dynamic>> filteredConnectionStateChanges;
  List<String> channelStates;
  List<Map<String, dynamic>> channelStateChanges;
  List<Map<String, dynamic>> filteredChannelStateChanges;

  List<String> transformState(items) =>
      List.from(items as List).map((t) => t as String).toList();

  List<Map<String, dynamic>> transformStateChange(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    connectionStates = transformState(response.payload['connectionStates']);
    connectionStateChanges = transformStateChange(
      response.payload['connectionStateChanges'],
    );
    filteredConnectionStateChanges = transformStateChange(
      response.payload['filteredConnectionStateChanges'],
    );
    channelStates = transformState(response.payload['channelStates']);
    channelStateChanges = transformStateChange(
      response.payload['channelStateChanges'],
    );
    filteredChannelStateChanges = transformStateChange(
      response.payload['filteredChannelStateChanges'],
    );
  });

  group('realtime#channel#connection', () {
    test('#state', () {
      expect(
          connectionStates,
          orderedEquals(const [
            'initialized',
            'initialized',
            'connected',
            'connected',
            'closed',
          ]));
    });
    test(
      '#on returns a stream which can be subscribed for connectionStateChanges',
      () {
        expect(
            connectionStateChanges.map((e) => e['event']),
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
      },
    );

    test(
      '#on returns a stream which can be subscribed'
      ' for connection state changes with filter',
      () {
        expect(filteredConnectionStateChanges.map((e) => e['event']), const [
          'connected',
        ]);
        expect(filteredConnectionStateChanges.map((e) => e['current']), const [
          'connected',
        ]);
        expect(filteredConnectionStateChanges.map((e) => e['previous']), const [
          'connecting',
        ]);
      },
    );
  });

  group('realtime#channel#chanenls#channel', () {
    test(
      '#state',
      () {
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
      },
    );
    test(
      '#on returns a stream which can be subscribed for channel state changes',
      () {
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
      },
    );

    test(
      '#on returns a stream which can be subscribed'
      ' for channel state changes with filter',
      () {
        // filteredChannelStateChanges
        expect(filteredChannelStateChanges.map((e) => e['event']),
            orderedEquals(const ['attaching']));

        expect(filteredChannelStateChanges.map((e) => e['current']),
            orderedEquals(const ['attaching']));

        expect(filteredChannelStateChanges.map((e) => e['previous']),
            orderedEquals(const ['initialized']));
      },
    );
  });
}

void testRealtimeSubscribe(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeSubscribe);
  TestControlMessage response;
  List<Map<String, dynamic>> all;
  List<Map<String, dynamic>> filteredWithName;
  List<Map<String, dynamic>> filteredWithNames;
  List<Map<String, dynamic>> extrasMessages;

  List<Map<String, dynamic>> transformMessages(messages) =>
      List.from(messages as List)
          .map((t) => t as Map<String, dynamic>)
          .toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    all = transformMessages(response.payload['all']);
    filteredWithName = transformMessages(response.payload['filteredWithName']);
    filteredWithNames = transformMessages(
      response.payload['filteredWithNames'],
    );
    extrasMessages = transformMessages(response.payload['extrasMessages']);
  });

  test(
    'realtime#channels#channel#subscribe should subscribe to'
    ' all message on channel',
    () {
      testAllPublishedMessages(all);
    },
  );

  test(
    'realtime#channels#channel#subscribe(name: string)'
    ' should subscribe to messages with specified name',
    () {
      expect(filteredWithName.length, equals(2));

      expect(filteredWithName[0]['name'], 'name1');
      expect(filteredWithName[0]['data'], isNull);

      expect(filteredWithName[1]['name'], 'name1');
      expect(filteredWithName[1]['data'], equals('Ably'));
    },
  );

  test(
    'realtime#channels#channel#subscribe(names: List<string>)'
    ' should subscribe to messages with specified names',
    () {
      expect(filteredWithNames.length, equals(4));

      expect(filteredWithNames[0]['name'], 'name1');
      expect(filteredWithNames[0]['data'], isNull);

      expect(filteredWithNames[1]['name'], 'name1');
      expect(filteredWithNames[1]['data'], equals('Ably'));

      expect(filteredWithNames[2]['name'], 'name2');
      expect(filteredWithNames[2]['data'], equals([1, 2, 3]));

      expect(filteredWithNames[3]['name'], 'name2');
      expect(filteredWithNames[3]['data'], equals(['hello', 'ably']));
    },
  );

  test('retrieves extras posted in message', () {
    expect(extrasMessages[0]['name'], 'name');
    expect(extrasMessages[0]['data'], 'data');
    expect(
      json.encode(extrasMessages[0]['extras']['extras'] as Map),
      json.encode({...pushPayload}),
    );
    expect(extrasMessages[0]['extras']['delta'], null);
  });
}

void testRealtimeHistory(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeHistory);
  TestControlMessage response;

  Map<String, dynamic> paginatedResult;
  List<Map<String, dynamic>> historyDefault;
  List<Map<String, dynamic>> historyLimit4;
  List<Map<String, dynamic>> historyLimit2;
  List<Map<String, dynamic>> historyForwardLimit4;
  List<Map<String, dynamic>> historyWithStart;
  List<Map<String, dynamic>> historyWithStartAndEnd;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    paginatedResult =
        response.payload['paginatedResult'] as Map<String, dynamic>;
    historyDefault = transform(response.payload['historyDefault']);
    historyLimit4 = transform(response.payload['historyLimit4']);
    historyLimit2 = transform(response.payload['historyLimit2']);
    historyForwardLimit4 = transform(response.payload['historyForwardLimit4']);
    historyWithStart = transform(response.payload['historyWithStart']);
    historyWithStartAndEnd = transform(
      response.payload['historyWithStartAndEnd'],
    );
  });

  group('paginated result', () {
    test('#items is a list', () {
      expect(paginatedResult['items'], isA<List>());
    });
    test('#hasNext indicates whether there are more entries', () {
      expect(paginatedResult['hasNext'], false);
    });
    test('#isLast indicates if current page is last page', () {
      expect(paginatedResult['isLast'], true);
    });
  });

  group('realtime#channels#channel#history', () {
    test('queries all entries by default', () {
      expect(historyDefault.length, equals(8));
      testAllPublishedMessages(historyDefault.reversed.toList());
    });
    test('queries all entries by paginating with limit', () {
      expect(historyLimit4.length, equals(8));
      expect(historyLimit2.length, equals(8));
      testAllPublishedMessages(historyLimit4.reversed.toList());
      testAllPublishedMessages(historyLimit2.reversed.toList());
    });
    test('queries entries in reverse order with direction set to "forward"',
        () {
      expect(historyForwardLimit4.length, equals(8));
      testAllPublishedMessages(historyForwardLimit4);
    });
    test('returns entries created after specified time', () {
      expect(historyWithStart.length, equals(2));
      expect(historyWithStart[0]['name'], equals('history'));
      expect(historyWithStart[0]['data'], equals('test2'));
      expect(historyWithStart[1]['name'], equals('history'));
      expect(historyWithStart[1]['data'], equals('test'));
    });
    test('returns entries created between specified start and end', () {
      expect(historyWithStartAndEnd.length, equals(1));
      expect(historyWithStartAndEnd[0]['name'], equals('history'));
      expect(historyWithStartAndEnd[0]['data'], equals('test'));
    });
  });
}

void testRealtimePresenceGet(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceGet);
  TestControlMessage response;

  List<Map<String, dynamic>> membersInitial;
  List<Map<String, dynamic>> membersDefault;
  List<Map<String, dynamic>> membersClientId;
  List<Map<String, dynamic>> membersConnectionId;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    membersInitial = transform(response.payload['membersInitial']);
    membersDefault = transform(response.payload['membersDefault']);
    membersClientId = transform(response.payload['membersClientId']);
    membersConnectionId = transform(response.payload['membersConnectionId']);
  });

  group('realtime#channels#channel#presence#get', () {
    test('has 0 members without any clients joined', () {
      expect(membersInitial.length, equals(0));
    });
    test('queries all entries by default', () {
      expect(membersDefault.length, equals(8));
      testAllPresenceMembers(membersDefault..sort(timestampSorter));
    });
    test('filters entries with clientId when specified', () {
      // there is only 1 client with clientId 'client-1
      expect(membersClientId.length, equals(1));
      expect(membersClientId[0]['clientId'], equals('client-1'));
      checkMessageData(1, membersClientId[0]['data']);
    });
    test('filters entries with clientId when specified', () {
      // TODO similarly check for membersConnectionId after implementing
      //  connection id (sync from platform) on realtime connection
      expect(membersConnectionId.length, equals(0));
    });
  });
}

void testRealtimePresenceHistory(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceHistory);
  TestControlMessage response;

  List<Map<String, dynamic>> historyInitial;
  List<Map<String, dynamic>> historyDefault;
  List<Map<String, dynamic>> historyLimit4;
  List<Map<String, dynamic>> historyLimit2;
  List<Map<String, dynamic>> historyForwards;
  List<Map<String, dynamic>> historyWithStart;
  List<Map<String, dynamic>> historyWithStartAndEnd;
  List<Map<String, dynamic>> historyExtras;
  List<Map<String, dynamic>> historyAll;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    historyInitial = transform(response.payload['historyInitial']);
    historyDefault = transform(response.payload['historyDefault']);
    historyLimit4 = transform(response.payload['historyLimit4']);
    historyLimit2 = transform(response.payload['historyLimit2']);
    historyForwards = transform(response.payload['historyForwards']);
    historyWithStart = transform(
      response.payload['historyWithStart'],
    ).reversed.toList();
    historyWithStartAndEnd = transform(
      response.payload['historyWithStartAndEnd'],
    );
    historyAll = transform(response.payload['historyAll']);
    historyExtras = transform(response.payload['historyExtras']);
  });

  test('queries all entries by default', () {
    expect(historyInitial.length, equals(0));
    expect(historyAll.length, equals(10));

    expect(historyDefault.length, equals(8));
    testAllPresenceMessagesHistory(historyDefault.reversed.toList());
  });
  test('queries all entries by paginating with limit', () {
    expect(historyLimit4.length, equals(8));
    expect(historyLimit2.length, equals(8));
    testAllPresenceMessagesHistory(historyLimit4.reversed.toList());
    testAllPresenceMessagesHistory(historyLimit2.reversed.toList());
  });
  test(
    'queries entries in reverse order with direction set to "forward"',
    () {
      expect(historyForwards.length, equals(8));
      testAllPresenceMessagesHistory(historyForwards.toList());
    },
  );
  test('returns entries created after specified time', () {
    expect(historyWithStart.length, equals(2));
    expect(historyWithStart[0]['clientId'], equals('someClientId'));
    expect(historyWithStart[0]['data'], equals('enter-start-time'));
    expect(historyWithStart[1]['clientId'], equals('someClientId'));
    expect(historyWithStart[1]['data'], equals('leave-end-time'));
  });
  test('returns entries created between specified start and end', () {
    expect(historyWithStartAndEnd.length, equals(1));
    expect(historyWithStartAndEnd[0]['clientId'], equals('someClientId'));
    expect(historyWithStartAndEnd[0]['data'], equals('enter-start-time'));
  });
  test('receives messages extras in PresenceMessage', () {
    expect(historyExtras[0]['name'], 'name');
    expect(historyExtras[0]['data'], 'data');
    expect(
      json.encode(historyExtras[0]['extras']['extras'] as Map),
      json.encode({...pushPayload}),
    );
    expect(historyExtras[0]['extras']['delta'], null);
  });
}

void testRealtimeEnterUpdateLeave(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceEnterUpdateLeave);
  TestControlMessage response;

  List<Map<String, dynamic>> clientIDClashMatrix;
  List<Map<String, dynamic>> actionMatrix;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    clientIDClashMatrix = transform(response.payload['clientIDClashMatrix']);
    actionMatrix = transform(response.payload['actionMatrix']);
  });

  void testMatrixEntry(
    Map entry, {
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

  test(
      'clientID should be same in both realtime ClientOptions as well as'
      ' the one passed to presence enter/update/leave APIs.'
      ' If unequal, throw error.', () {
    for (final clashEntry in clientIDClashMatrix) {
      final realtimeClientID = clashEntry['realtimeClientId'] as String;
      final presenceClientID = clashEntry['presenceClientId'] as String;

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
  });

  test('supports all data types as payload for presence actions', () {
    for (final actionEntry in actionMatrix) {
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
  });
}

void testRealtimePresenceSubscription(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceSubscribe);
  TestControlMessage response;
  List<Map<String, dynamic>> allMessages;
  List<Map<String, dynamic>> enterMessages;
  List<Map<String, dynamic>> enterUpdateMessages;
  List<Map<String, dynamic>> partialMessages;

  List<Map<String, dynamic>> transform(items) =>
      List.from(items as List).map((t) => t as Map<String, dynamic>).toList();

  setUpAll(() async {
    response = await getTestResponse(getDriver(), message);
    allMessages = transform(response.payload['allMessages']);
    enterMessages = transform(response.payload['enterMessages']);
    enterUpdateMessages = transform(response.payload['enterUpdateMessages']);
    partialMessages = transform(response.payload['partialMessages']);
  });

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

  test('listens to messages', () {
    expect(allMessages.length, equals(8));
    _test(allMessages);
  });

  test('filters messages with single action', () {
    expect(enterMessages.length, equals(1));
    _test(enterMessages);
  });

  test('filters messages with multiple actions', () {
    expect(enterUpdateMessages.length, equals(7));
    _test(enterUpdateMessages);
  });

  test('listens to messages only until subscription is active', () {
    expect(partialMessages.length, equals(7));
    expect(partialMessages, equals(enterUpdateMessages));
  });
}
