import 'dart:convert' show json;
import 'package:flutter_driver/flutter_driver.dart';

/// Send a message to run a widget test and receive a response.
///
/// Helper to minimize repeatedly used code in driver tests.
Future<TestControlMessage> getTestResponse(
    FlutterDriver driver, TestControlMessage message) async {
  final result = await driver.requestData(message.toJsonEncoded());
  return TestControlMessage.fromJsonEncoded(result);
}

/// Passed to `enableFlutterDriverExtension` to receive messages sent by the
/// driver tests.
class DriverDataHandler {
  /// Handler for a message sent from the driver test to the test widget.
  Future<String> call(String encodedMessage) async {
    if (callback != null) {
      final message = TestControlMessage.fromJson(json.decode(encodedMessage));
      final response = await callback(message);
      return json.encode(response);
    }

    return Future.error('No callback registered.');
  }

  /// The test dispacher can register a callback to get notified about messages.
  Future<TestControlMessage> Function(TestControlMessage message) callback;
}

/// Used to encode and decode messages between driver test and test widget.
class TestControlMessage {
  const TestControlMessage(
    this.testName,
    this.payload, {
    this.log,
  }) : assert(testName != null && testName.length != null);

  static const testNameKey = 'testName';
  static const payloadKey = 'payload';
  static const errorKey = 'error';
  static const logKey = 'log';

  final String testName;
  final Map<String, dynamic> payload;
  final List<dynamic> log;

  factory TestControlMessage.fromJsonEncoded(String encoded) {
    return TestControlMessage.fromJson(json.decode(encoded));
  }

  factory TestControlMessage.fromJson(Map jsonValue) => TestControlMessage(
        jsonValue[testNameKey] as String,
        jsonValue[payloadKey] as Map<String, dynamic>,
        log: jsonValue[logKey] as List<dynamic>,
      );

  Map<String, dynamic> toJson() => {
        testNameKey: testName,
        payloadKey: payload,
        logKey: log,
      };

  String toJsonEncoded() => json.encode(toJson());
}
