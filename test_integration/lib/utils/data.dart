import 'dart:math';

final messagesToPublish = [
  [null, null], //name and message are both null
  [null, 'Ably'], //name is null
  ['name1', null], //message is null
  ['name1', 'Ably'], //message is a string
  [
    'name2',
    [1, 2, 3]
  ], //message is a numeric list
  [
    'name2',
    ['hello', 'ably']
  ], //message is a string list
  [
    'name3',
    {
      'hello': 'ably',
      'items': ['1', 2.2, true]
    }
  ], //message is a map
  [
    'name3',
    [
      {'hello': 'ably'},
      'ably',
      'realtime'
    ]
  ] //message is a complex list
];

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

/// get random alpha numeric string of given length
String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );

/// returns subsets of all entries in a list
List<List> getAllSubsets(List l) => l.fold<List<List>>(
      [[]],
      (subLists, element) => subLists
          .map((subList) => [
                subList,
                subList + [element]
              ])
          .expand((element) => element)
          .toList(),
    );

const pushPayload = <String, dynamic>{
  'push': {
    'notification': {
      'title': 'Hello from Ably!',
      'body': 'Example push notification from Ably'
    },
    'data': {'foo': 'bar'}
  }
};
