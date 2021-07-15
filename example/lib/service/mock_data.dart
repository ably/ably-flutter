class MockData {
  // TODO don't use object?
  static Object createMockPresenceData() {
    final currentTime = DateTime.now();
    // TODO just use a string?
    return [
      currentTime.toString()
    ];
  }

  //Storing different message types here to be publishable
  List<dynamic> messagesToPublish = [
    null,
    'A simple panda...',
    {
      'I am': null,
      'and': {
        'also': 'nested',
        'too': {'deep': true}
      }
    },
    [
      42,
      {'are': 'you'},
      'ok?',
      false,
      {
        'I am': null,
        'and': {
          'also': 'nested',
          'too': {'deep': true}
        }
      }
    ]
  ];
}