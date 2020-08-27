import 'dart:convert' show json;

/// Passed to `enableFlutterDriverExtension` to handle messages from the driving
/// tests.
class DriverDataHandler {
  Future<String> call(String message) async {
    if (callback != null) {
      return json.encode(await callback(TestControlMessage.fromJson(message)));
    }
    return Future.error('No callback registered.');
  }

  Future<TestControlMessage> Function(TestControlMessage message) callback;
}

/// Used to pass messages from driver test to the driven app and back.
class TestControlMessage {
  const TestControlMessage(
    this.testName,
    this.payload,
  ) : assert(testName != null && testName.length != null);

  static const testNameKey = 'testName';
  static const payloadKey = 'payload';
  static const errorKey = 'error';

  final String testName;
  final Map<String, dynamic> payload;

  factory TestControlMessage.fromJson(String jsonValue) {
    var value = json.decode(jsonValue);
    // TODO(zoechi) no idea why this is necessary (where it got encoded a 2nd time)
    // I'm sure it's my fault, but I need to investigate another time.
    if (value is String) {
      value = json.decode(value as String);
    }

    return TestControlMessage(
      value[testNameKey] as String,
      value[payloadKey] as Map<String, dynamic>,
    );
  }

  String toJson() => json.encode({
        testNameKey: testName,
        payloadKey: payload,
      });
}
