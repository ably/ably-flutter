import 'dart:typed_data';

import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'utils.dart';

void testRestPublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restPublish);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('rest instance has a valid handle on publish', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}

void testRestRequestTokenPublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restRequestToken);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test(
      'rest instance with token has a valid handle and successfully'
      ' publishes messages', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}

void testRestCreateTokenRequestPublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restCreateTokenRequest);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test(
      'rest instance with token has a valid handle and successfully '
      'publishes messages', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['log'], greaterThan(0));
  });
}

void testRestEncryptedPublish(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restEncryptedPublish);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('rest instance has a valid handle on encrypted publish', () {
    expect(response.payload['handle'], isA<int>());
    expect(response.payload['handle'], greaterThan(0));
  });
}

void testRestPublishSpec(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restPublishSpec);
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> messages;
  late List<Map<String, dynamic>> messages2;
  late List<Map<String, dynamic>> messages3;
  late List<Map<String, dynamic>> messagesWithExtras;
  Map<String, dynamic>? exception;
  Map<String, dynamic>? exception2;
  Map<String, dynamic>? exception3;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);

    messages = transformListResponse(response.payload['publishedMessages']);
    messages2 = transformListResponse(response.payload['publishedMessages2']);
    messages3 = transformListResponse(response.payload['publishedMessages3']);
    messagesWithExtras =
        transformListResponse(response.payload['publishedExtras']);
    exception = response.payload['exception'] as Map<String, dynamic>?;
    exception2 = response.payload['exception2'] as Map<String, dynamic>?;
    exception3 = response.payload['exception3'] as Map<String, dynamic>?;
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
    },
        skip:
            'Failing on Android, the clientId is null`. See https://github.com/ably/ably-flutter/issues/150');

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
        expect(response.payload['exception'], isA<Map<dynamic, dynamic>>());
        // TODO as error details are incompatible from both libraries,
        //  it makes no sense to include below expect's
        //
        // final exception = Map.castFrom<dynamic, dynamic, String, dynamic>(
        //   response.payload['exception'] as Map);
        // expect(exception['code'], '14'); //40012 from android and 14 from iOS
        // expect(
        //   exception['message'],
        //   'Error publishing rest message;'
        //   ' err = attempted to publish message with an invalid clientId',
        // );
        // expect(exception['errorInfo']['message'],
        //     'attempted to publish message with an invalid clientId');
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
      '(RSL1i) If the total size of the message or (if publishing an array)'
      ' messages, calculated per TO3l8, exceeds the maxMessageSize, then the'
      ' client library should reject the publish and indicate an error'
      ' with code 40009',
      () {
        // allows publishing messages length <= max allowed limit
        expect(exception2 == null, true);
        // errors out publishing messages length > max allowed limit
        expect(exception3 == null, false);
      },
    );

    test(
      'publishes non-ascii characters',
      () {
        expect(messages3[0]['name'], 'Ωπ');
        expect(messages3[0]['data'], 'ΨΔ');
      },
    );
  });

  test('RSL6a2 publishes message extras', () {
    expect(messagesWithExtras[0]['name'], 'name');
    expect(messagesWithExtras[0]['data'], 'data');
    checkMessageExtras(messagesWithExtras[0]['extras']['extras'] as Map);
    expect(messagesWithExtras[0]['extras']['delta'], null);
  });
}

void testRestEncryptedPublishSpec(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restEncryptedPublishSpec);
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

void testRestPublishWithAuthCallback(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restPublishWithAuthCallback);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('auth callback is invoked', () {
    expect(response.payload['authCallbackInvoked'], isTrue);
  });
}

void testRestHistory(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restHistory);
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

  group('rest#channels#channel#history', () {
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

void testRestHistoryWithAuthCallback(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restHistoryWithAuthCallback);
  late TestControlResponseMessage response;
  setUpAll(
      () async => response = await requestDataForTest(getDriver(), message));

  test('auth callback is invoked', () {
    expect(response.payload['authCallbackInvoked'], isTrue);
  });
}

void testRestTime(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restTime);
  late TestControlResponseMessage response;
  late DateTime restTime;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    restTime = DateTime.parse(response.payload['time'] as String);
  });

  group('rest#time', () {
    test('returns non-zero date and time', () {
      expect(restTime.millisecondsSinceEpoch, isNot(0));
    });
  });
}

void testRestPresenceGet(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restPresenceGet);
  late TestControlResponseMessage response;

  late List<Map<String, dynamic>> membersInitial;
  late List<Map<String, dynamic>> membersDefault;
  late List<Map<String, dynamic>> membersLimit4;
  late List<Map<String, dynamic>> membersLimit2;
  late List<Map<String, dynamic>> membersClientId;
  late List<Map<String, dynamic>> membersConnectionId;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    membersInitial = transformListResponse(response.payload['membersInitial']);
    membersDefault = transformListResponse(response.payload['membersDefault']);
    membersLimit4 = transformListResponse(response.payload['membersLimit4']);
    membersLimit2 = transformListResponse(response.payload['membersLimit2']);
    membersClientId =
        transformListResponse(response.payload['membersClientId']);
    membersConnectionId =
        transformListResponse(response.payload['membersConnectionId']);
  });

  group('rest#channels#channel#presence#get', () {
    test('has 0 members without any clients joined', () {
      expect(membersInitial.length, equals(0));
    });
    test('queries all entries by default', () {
      expect(membersDefault.length, equals(8));
      testAllPresenceMembers(membersDefault..sort(timestampSorter));
    });
    test('queries all entries by paginating with limit', () {
      expect(membersLimit4.length, equals(8));
      expect(membersLimit2.length, equals(8));
      testAllPresenceMembers(membersLimit4..sort(timestampSorter));
      testAllPresenceMembers(membersLimit2..sort(timestampSorter));
    });
    test('filters entries with clientId when specified', () {
      // there is only 1 client with clientId 'client-1
      expect(membersClientId.length, equals(1));
      expect(membersClientId[0]['clientId'], equals('client-1'));
      checkMessageData(1, membersClientId[0]['data']);
    });
    test('filters entries with clientId when specified', () {
      // TODO similarly (like clientId) check for membersConnectionId
      //  after implementing connection id (sync from platform)
      //  on realtime connection
      expect(membersConnectionId.length, equals(0));
    });
  });
}

void testRestPresenceHistory(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restPresenceHistory);
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

  group('rest#channels#channel#presence#history', () {
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
  });
}

void testCapabilityMatrix(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.restCapabilities);
  late TestControlResponseMessage response;
  late List<Map<String, dynamic>> capabilityMatrix;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    capabilityMatrix = transformListResponse(response.payload['matrix']);
  });

  test('capabilitySpec', () {
    for (final entry in capabilityMatrix) {
      final capabilities = entry['channelCapabilities'] as List;
      final publishEnabled = capabilities.contains('publish');
      final historyEnabled = capabilities.contains('history');
      final subscribeEnabled = capabilities.contains('subscribe');

      final publishException = entry['publishException'];
      final historyException = entry['historyException'];
      final presenceException = entry['presenceException'];
      final presenceHistoryException = entry['presenceHistoryException'];

      if (publishEnabled) {
        expect(publishException == null, true);
      } else {
        expect(publishException['code'], '40160');
      }
      if (historyEnabled) {
        expect(historyException == null, true);
        expect(presenceHistoryException == null, true);
      } else {
        expect(historyException['code'], '40160');
        expect(presenceHistoryException['code'], '40160');
      }
      if (subscribeEnabled) {
        expect(presenceException == null, subscribeEnabled);
      } else {
        expect(presenceException['code'], '40160');
      }
    }
  });
}
