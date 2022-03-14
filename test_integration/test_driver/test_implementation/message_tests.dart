import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:ably_flutter_integration_test/utils/encrypted_message_data.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void testMessageEncoding(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.messageFromEncrypted);
  late TestControlResponseMessage response;
  final messageCount = EncryptedMessageData.crypto128.length;
  late List decodedMessages;
  late List decryptedMessages;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    decodedMessages = response.payload['decodedMessages'] as List;
    decryptedMessages = response.payload['decryptedMessages'] as List;
  });

  test('decodes and decrypts all 128-bit messages', () {
    expect(decodedMessages.length, equals(messageCount));
    expect(decryptedMessages.length, equals(messageCount));
  });

  test('decodes and decrypted messages are the same', () {
    for (var i = 0; i < messageCount; i++) {
      expect(decodedMessages[i], equals(messageCount));
      expect(decryptedMessages[i], equals(messageCount));
    }
  });
}
