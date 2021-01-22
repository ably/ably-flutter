import 'package:test/test.dart';

void testAllPublishedMessages(Object messagesObject) {
  expect(messagesObject, isA<List<Map<String, dynamic>>>());

  final messages = messagesObject as List;
  expect(messages.length, equals(8));

  expect(messages[0]['name'], isNull);
  expect(messages[0]['data'], isNull);

  expect(messages[1]['name'], isNull);
  expect(messages[1]['data'], equals('Ably'));

  expect(messages[2]['name'], 'name1');
  expect(messages[2]['data'], isNull);

  expect(messages[3]['name'], 'name1');
  expect(messages[3]['data'], equals('Ably'));

  expect(messages[4]['name'], 'name2');
  expect(messages[4]['data'], equals([1, 2, 3]));

  expect(messages[5]['name'], 'name2');
  expect(messages[5]['data'], equals(['hello', 'ably']));

  expect(messages[6]['name'], 'name3');
  expect(
      messages[6]['data'],
      equals({
        'hello': 'ably',
        'items': ['1', 2.2, true]
      }));

  expect(messages[7]['name'], 'name3');
  expect(
      messages[7]['data'],
      equals([
        {'hello': 'ably'},
        'ably',
        'realtime'
      ]));
}

void testAllPresenceMembers(
  Object membersObject, {
  Map<String, dynamic> filters
}) {
  expect(membersObject, isA<List<Map<String, dynamic>>>());

  final members = membersObject as List;

  // TODO(tiholic) calculate length dynamically based on the filters
  expect(members.length, equals(0));
}
