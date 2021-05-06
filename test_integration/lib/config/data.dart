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
