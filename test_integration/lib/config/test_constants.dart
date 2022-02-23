import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class TestConstants {
  static const Duration publishToHistoryDelay = Duration(seconds: 2);
  static const String encryptedMessagePassword = 'test-password';
  static Uint8List get encryptedChannelKey {
    final data = utf8.encode(encryptedMessagePassword);
    final digest = sha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }
}
