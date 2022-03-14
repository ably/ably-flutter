import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';
import 'package:ably_flutter_integration_test/utils/encrypted_message_data.dart';

Future<Map<String, dynamic>> testMessageEncoding({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final cipherParams =
      await Crypto.getDefaultParams(key: EncryptedMessageData.key128bit);

  final channelOptions = RestChannelOptions(cipherParams: cipherParams);

  final decodedMessages = <Message>[];
  final decryptedMessages = <Message>[];

  for (final messagePair in EncryptedMessageData.crypto128) {
    print(messagePair);
    final decodedMessage =
        await Message.fromEncoded(messagePair.encoded, channelOptions);
    final decryptedMessage =
        await Message.fromEncoded(messagePair.encrypted, channelOptions);
    decodedMessages.add(decodedMessage);
    decryptedMessages.add(decryptedMessage);
  }

  return {
    'decodedMessages': encodeList(decodedMessages, encodeMessage),
    'decryptedMessages': encodeList(decryptedMessages, encodeMessage)
  };
}
