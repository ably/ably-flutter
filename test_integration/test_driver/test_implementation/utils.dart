import 'package:test/test.dart';

void checkMessageData(int index, Object? data) {
  switch (index) {
    case 0:
      expect(data, isNull);
      break;
    case 1:
      expect(data, equals('Ably'));
      break;
    case 2:
      expect(data, isNull);
      break;
    case 3:
      expect(data, equals('Ably'));
      break;
    case 4:
      expect(data, equals([1, 2, 3]));
      break;
    case 5:
      expect(data, equals(['hello', 'ably']));
      break;
    case 6:
      expect(
        data,
        equals(
          {
            'hello': 'ably',
            'items': ['1', 2.2, true]
          },
        ),
      );
      break;
    case 7:
      expect(
        data,
        equals(
          [
            {'hello': 'ably'},
            'ably',
            'realtime'
          ],
        ),
      );
  }
}

void testAllPublishedMessages(Object messagesObject) {
  expect(messagesObject, isA<List<Map<String, dynamic>>>());

  final messages = messagesObject as List;
  expect(messages.length, equals(8));

  expect(messages[0]['name'], isNull);
  checkMessageData(0, messages[0]['data']);

  expect(messages[1]['name'], isNull);
  checkMessageData(1, messages[1]['data']);

  expect(messages[2]['name'], 'name1');
  checkMessageData(2, messages[2]['data']);

  expect(messages[3]['name'], 'name1');
  checkMessageData(3, messages[3]['data']);

  expect(messages[4]['name'], 'name2');
  checkMessageData(4, messages[4]['data']);

  expect(messages[5]['name'], 'name2');
  checkMessageData(5, messages[5]['data']);

  expect(messages[6]['name'], 'name3');
  checkMessageData(6, messages[6]['data']);

  expect(messages[7]['name'], 'name3');
  checkMessageData(7, messages[7]['data']);
}

void testAllPresenceMembers(Object membersObject) {
  expect(membersObject, isA<List<Map<String, dynamic>>>());
  final members = membersObject as List;
  for (var i = 0; i < members.length; i++) {
    expect(members[i]['clientId'], equals('client-$i'));
    checkMessageData(i, members[i]['data']);
  }
}

void testAllPresenceMessagesHistory(Object messagesHistory) {
  expect(messagesHistory, isA<List<Map<String, dynamic>>>());
  final history = messagesHistory as List;
  for (var i = 0; i < history.length; i++) {
    expect(history[i]['clientId'], equals('someClientId'));
    checkMessageData(i, history[i]['data']);
  }
}

int timestampSorter(Map a, Map b) {
  if (DateTime.parse(a['timestamp'] as String).millisecondsSinceEpoch >
      DateTime.parse(b['timestamp'] as String).millisecondsSinceEpoch) {
    return 1;
  } else {
    return -1;
  }
}

void checkMessageExtras(Map messageExtras) {
  expect(messageExtras['push']['notification']['title'], 'Hello from Ably!');
  expect(
    messageExtras['push']['notification']['body'],
    'Test push notification from Ably',
  );
  expect(messageExtras['push']['data']['foo'], 'bar');
}
