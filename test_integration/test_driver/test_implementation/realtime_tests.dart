import 'dart:typed_data';

import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils.dart';

void testRealtimePublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePublish);
  const message2 = TestControlMessage(TestName.realtimePublishWithAuthCallback);
  late TestControlResponseMessage response;
  late TestControlResponseMessage response2;
  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    response2 = await requestDataForTest(getDriver(), message2);
  });

  test('publishes message without any response', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
  test('invokes authCallback if available in clientOptions', () {
    expect(response2.payload['authCallbackInvoked'], isTrue);
  });
}

void testRealtimeEncryptedPublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeEncryptedPublish);
  late TestControlResponseMessage response;
  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
  });

  test('publishes encrypted message without any response', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}

void testRealtimePublishSpec(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePublishSpec);
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> messages;
  late List<Map<String, dynamic>> messages2;
  late List<Map<String, dynamic>> messages3;
  late List<Map<String, dynamic>> messagesWithExtras;
  Map<String, dynamic>? exception;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);

    messages = transformListResponse(response.payload['publishedMessages']);
    messages2 = transformListResponse(response.payload['publishedMessages2']);
    messages3 = transformListResponse(response.payload['publishedMessages3']);
    messagesWithExtras =
        transformListResponse(response.payload['publishedExtras']);
    exception = response.payload['exception'] as Map<String, dynamic>?;
  });

  group('RSl1', () {
    test('publishes without a name and data', () {
      expect(messages[0]['name'], null);
      expect(messages[0]['data'], null);
    });

    test('publishes without data', () {
      expect(messages[1]['name'], 'name1');
      expect(messages[1]['data'], null);
    });

    test('publishes without a name', () {
      expect(messages[2]['name'], null);
      expect(messages[2]['data'], 'data1');
    });

    test('publishes with name and data', () {
      expect(messages[3]['name'], 'name1');
      expect(messages[3]['data'], 'data1');
    });

    test('publishes single message object', () {
      expect(messages[4]['name'], 'message-name1');
      expect(messages[4]['data'], 'message-data1');
    });

    test('publishes multiple message objects', () {
      expect(messages[5]['name'], 'messages-name1');
      expect(messages[5]['data'], 'messages-data1');
      expect(messages[6]['name'], 'messages-name2');
      expect(messages[6]['data'], 'messages-data2');
    });

    test('publishes multiple messages at once', () {
      expect(messages[5]['timestamp'] == messages[6]['timestamp'], true);
      expect(messages[5]['timestamp'] != messages[4]['timestamp'], true);
    });

    test(
        '(RSL1m1) Publishing a Message with no clientId when the clientId'
        ' is set to some value in the client options should result in a message'
        ' received with the clientId property set to that value', () {
      expect(messages[0]['clientId'], 'someClientId');
    });

    test(
        '(RSL1m2) Publishing a Message with a clientId set to the same'
        ' value as the clientId in the client options should result in'
        ' a message received with the clientId property set to that value', () {
      expect(messages[7]['clientId'], 'someClientId');
    });

    test(
      '(RSL1d) Raises an error if the message was not successfully published',
      () => expect(exception == null, false),
    );

    test(
      '(RSL1m4) Publishing a Message with a clientId set to a different value'
      ' from the clientId in the client options should result in a message'
      ' being rejected by the server.',
      () {
        expect(response.payload['exception'], isA<Map<String, dynamic>>());
      },
    );

    test(
      '(RSL1m3) Publishing a Message with a clientId set to a value'
      ' from an unidentified client (no clientId in the client options'
      ' and credentials that can assume any clientId) should result in'
      ' a message received with the clientId property set to that value',
      () => expect(messages2[0]['clientId'], 'client-id'),
    );

    test(
      'publishes non-ascii characters',
      () {
        expect(messages3[0]['name'], 'Ωπ');
        expect(messages3[0]['data'], 'ΨΔ');
      },
    );
  });

  test('(RSL6a2) publishes message extras', () {
    expect(messagesWithExtras[0]['name'], 'name');
    expect(messagesWithExtras[0]['data'], 'data');
    checkMessageExtras(messagesWithExtras[0]['extras']['extras'] as Map);
    expect(messagesWithExtras[0]['extras']['delta'], null);
  });
}

void testRealtimeConnectWithAuthUrl(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeWithAuthUrl);
  late TestControlResponseMessage response;
  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
  });

  test('Connects to realtime with a valid handle', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}

void testRealtimeEncryptedPublishSpec(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeEncryptedPublishSpec);
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> historyOfEncryptedChannel;
  late List<Map<String, dynamic>> historyOfPlaintextChannel;
  late List<Map<String, dynamic>> historyOfEncryptedPushEnabledChannel;
  late List<Map<String, dynamic>> historyOfPlaintextPushEnabledChannel;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);

    historyOfEncryptedChannel =
        transformListResponse(response.payload['historyOfEncryptedChannel']);
    historyOfPlaintextChannel =
        transformListResponse(response.payload['historyOfPlaintextChannel']);
    historyOfEncryptedPushEnabledChannel = transformListResponse(
        response.payload['historyOfEncryptedPushEnabledChannel']);
    historyOfPlaintextPushEnabledChannel = transformListResponse(
        response.payload['historyOfPlaintextPushEnabledChannel']);
  });

  group('RSL5', () {
    test('does not encrypt name', () {
      for (var i = 0; i < historyOfEncryptedPushEnabledChannel.length; i++) {
        expect(historyOfEncryptedChannel[i]['name'],
            equals(historyOfPlaintextChannel[i]['name']));
      }
    });

    test('does encrypt data', () {
      for (var i = 0; i < historyOfEncryptedPushEnabledChannel.length; i++) {
        final encryptedData = historyOfEncryptedChannel[i]['data'];
        final plaintextData = historyOfPlaintextChannel[i]['data'];

        if (encryptedData != null) {
          expect(encryptedData, isNot(equals(plaintextData)));
          expect(plaintextData, isA<Uint8List>());
        }
      }
    });

    test('does not encrypt extras', () {
      for (var i = 0; i < historyOfEncryptedPushEnabledChannel.length; i++) {
        expect(historyOfEncryptedPushEnabledChannel[i]['name'],
            equals(historyOfPlaintextPushEnabledChannel[i]['name']));
      }
    });
  });
}

void testRealtimeEvents(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeEvents);
  late TestControlResponseMessage response;
  late List<String> connectionStates;
  late List<Map<String, dynamic>> connectionStateChanges;
  late List<Map<String, dynamic>> filteredConnectionStateChanges;
  late List<String> channelStates;
  late List<Map<String, dynamic>> channelStateChanges;
  late List<Map<String, dynamic>> filteredChannelStateChanges;

  List<String> transformState(dynamic items) =>
      List<dynamic>.from(items as List).map((t) => t as String).toList();

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    connectionStates = transformState(response.payload['connectionStates']);
    connectionStateChanges = transformListResponse(
      response.payload['connectionStateChanges'],
    );
    filteredConnectionStateChanges = transformListResponse(
      response.payload['filteredConnectionStateChanges'],
    );
    channelStates = transformState(response.payload['channelStates']);
    channelStateChanges = transformListResponse(
      response.payload['channelStateChanges'],
    );
    filteredChannelStateChanges = transformListResponse(
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
        List<String> _stateChangeCurrent;
        List<String> _stateChangePrevious;
        List<String> _stateChangeEvents;
        if (channelStateChanges.length == 4) {
          // iOS
          _stateChangeCurrent = const [
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
          _stateChangeEvents = _stateChangeCurrent;
        } else {
          // android
          _stateChangeCurrent = const [
            'attaching',
            'attaching',
            'attached',
            'attached',
            'detaching',
            'detached',
          ];
          _stateChangePrevious = const [
            'initialized',
            'attaching',
            'attaching',
            'attached',
            'attached',
            'detaching',
          ];
          _stateChangeEvents = const [
            'attaching',
            'attaching',
            'attached',
            'update',
            'detaching',
            'detached',
          ];
        }

        expect(channelStateChanges.map((e) => e['event']),
            orderedEquals(_stateChangeEvents));

        expect(channelStateChanges.map((e) => e['current']),
            orderedEquals(_stateChangeCurrent));

        expect(channelStateChanges.map((e) => e['previous']),
            orderedEquals(_stateChangePrevious));
      },
    );

    test(
      '#on returns a stream which can be subscribed'
      ' for channel state changes with filter',
      () {
        List<String> _stateChangeCurrent;
        List<String> _stateChangePrevious;
        List<String> _stateChangeEvents;
        if (channelStateChanges.length == 4) {
          // iOS
          _stateChangeCurrent = const [
            'attaching',
          ];
          _stateChangePrevious = const [
            'initialized',
          ];
        } else {
          // Android
          _stateChangeCurrent = const [
            'attaching',
            'attaching',
          ];
          _stateChangePrevious = const [
            'initialized',
            'attaching',
          ];
        }
        _stateChangeEvents = _stateChangeCurrent;
        // filteredChannelStateChanges
        expect(filteredChannelStateChanges.map((e) => e['event']),
            orderedEquals(_stateChangeEvents));

        expect(filteredChannelStateChanges.map((e) => e['current']),
            orderedEquals(_stateChangeCurrent));

        expect(filteredChannelStateChanges.map((e) => e['previous']),
            orderedEquals(_stateChangePrevious));
      },
    );
  });
}

void testRealtimeSubscribe(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeSubscribe);
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> all;
  late List<Map<String, dynamic>> filteredWithName;
  late List<Map<String, dynamic>> filteredWithNames;
  late List<Map<String, dynamic>> extrasMessages;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    all = transformListResponse(response.payload['all']);
    filteredWithName =
        transformListResponse(response.payload['filteredWithName']);
    filteredWithNames = transformListResponse(
      response.payload['filteredWithNames'],
    );
    extrasMessages = transformListResponse(response.payload['extrasMessages']);
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
    checkMessageExtras(extrasMessages[0]['extras']['extras'] as Map);
    expect(extrasMessages[0]['extras']['delta'], null);
  });
}

void testRealtimeHistory(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeHistory);
  late TestControlResponseMessage response;

  late Map<String, dynamic> paginatedResult;
  late List<Map<String, dynamic>> historyDefault;
  late List<Map<String, dynamic>> historyLimit4;
  late List<Map<String, dynamic>> historyLimit2;
  late List<Map<String, dynamic>> historyForwardLimit4;
  late List<Map<String, dynamic>> historyWithStart;
  late List<Map<String, dynamic>> historyWithStartAndEnd;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    paginatedResult =
        response.payload['paginatedResult'] as Map<String, dynamic>;
    historyDefault = transformListResponse(response.payload['historyDefault']);
    historyLimit4 = transformListResponse(response.payload['historyLimit4']);
    historyLimit2 = transformListResponse(response.payload['historyLimit2']);
    historyForwardLimit4 =
        transformListResponse(response.payload['historyForwardLimit4']);
    historyWithStart =
        transformListResponse(response.payload['historyWithStart']);
    historyWithStartAndEnd = transformListResponse(
      response.payload['historyWithStartAndEnd'],
    );
  });

  group('paginated result', () {
    test('#items is a list', () {
      expect(paginatedResult['items'], isA<List<dynamic>>());
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

void testRealtimeHistoryWithAuthCallback(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeHistoryWithAuthCallback);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('auth callback is invoked', () {
    expect(response.payload['authCallbackInvoked'], isTrue);
  });
}

void testRealtimeTime(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimeTime);
  late TestControlResponseMessage response;
  late DateTime realtimeTime;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    realtimeTime = DateTime.parse(response.payload['time'] as String);
  });

  group('realtime#time', () {
    test('returns non-zero date and time', () {
      expect(realtimeTime.millisecondsSinceEpoch, isNot(0));
    });
  });
}

void testRealtimePresenceGet(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceGet);
  late TestControlResponseMessage response;

  late List<Map<String, dynamic>> membersInitial;
  late List<Map<String, dynamic>> membersDefault;
  late List<Map<String, dynamic>> membersClientId;
  late List<Map<String, dynamic>> membersConnectionId;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    membersInitial = transformListResponse(response.payload['membersInitial']);
    membersDefault = transformListResponse(response.payload['membersDefault']);
    membersClientId =
        transformListResponse(response.payload['membersClientId']);
    membersConnectionId =
        transformListResponse(response.payload['membersConnectionId']);
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
  late TestControlResponseMessage response;

  late List<Map<String, dynamic>> historyInitial;
  late List<Map<String, dynamic>> historyDefault;
  late List<Map<String, dynamic>> historyLimit4;
  late List<Map<String, dynamic>> historyLimit2;
  late List<Map<String, dynamic>> historyForwards;
  late List<Map<String, dynamic>> historyWithStart;
  late List<Map<String, dynamic>> historyWithStartAndEnd;
  late List<Map<String, dynamic>> historyAll;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    historyInitial = transformListResponse(response.payload['historyInitial']);
    historyDefault = transformListResponse(response.payload['historyDefault']);
    historyLimit4 = transformListResponse(response.payload['historyLimit4']);
    historyLimit2 = transformListResponse(response.payload['historyLimit2']);
    historyForwards =
        transformListResponse(response.payload['historyForwards']);
    historyWithStart = transformListResponse(
      response.payload['historyWithStart'],
    ).reversed.toList();
    historyWithStartAndEnd = transformListResponse(
      response.payload['historyWithStartAndEnd'],
    );
    historyAll = transformListResponse(response.payload['historyAll']);
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
}

void testRealtimeEnterUpdateLeave(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.realtimePresenceEnterUpdateLeave);
  late TestControlResponseMessage response;

  late List<Map<String, dynamic>> clientIDClashMatrix;
  late List<Map<String, dynamic>> actionMatrix;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    clientIDClashMatrix =
        transformListResponse(response.payload['clientIDClashMatrix']);
    actionMatrix = transformListResponse(response.payload['actionMatrix']);
  });

  void testMatrixEntry(
    Map<String, dynamic> entry, {
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
      final realtimeClientID = clashEntry['realtimeClientId'] as String?;
      final presenceClientID = clashEntry['presenceClientId'] as String?;

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
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> allMessages;
  late List<Map<String, dynamic>> enterMessages;
  late List<Map<String, dynamic>> enterUpdateMessages;
  late List<Map<String, dynamic>> partialMessages;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    allMessages = transformListResponse(response.payload['allMessages']);
    enterMessages = transformListResponse(response.payload['enterMessages']);
    enterUpdateMessages =
        transformListResponse(response.payload['enterUpdateMessages']);
    partialMessages =
        transformListResponse(response.payload['partialMessages']);
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
  },
      skip:
          'One message in allMessages gets `present` action, but should have been `enter`. See https://github.com/ably/ably-flutter/issues/150');

  test('filters messages with single action', () {
    expect(enterMessages.length, equals(1));
    _test(enterMessages);
  },
      skip:
          'expected 1 but got 0. See https://github.com/ably/ably-flutter/issues/150');

  test('filters messages with multiple actions', () {
    expect(enterUpdateMessages.length, equals(7));
    _test(enterUpdateMessages);
  },
      skip:
          'Got a length of 6 but expected 7. See https://github.com/ably/ably-flutter/issues/150');

  test('listens to messages only until subscription is active', () {
    expect(partialMessages.length, equals(7));
    expect(partialMessages, equals(enterUpdateMessages));
  },
      skip:
          'Expected a set of messages, but got the same set but with 1 unexpected extra message at the start, with `present` action. See https://github.com/ably/ably-flutter/issues/150');
}
