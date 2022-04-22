import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testCryptoGenerateRandomKey({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final keyWithDefaultLength = await Crypto.generateRandomKey();

  final keyWith128BitLength = await Crypto.generateRandomKey(keyLength: 128);

  final keyWith256BitLength = await Crypto.generateRandomKey(keyLength: 256);

  return {
    'keyWithDefaultLength': keyWithDefaultLength,
    'keyWith128BitLength': keyWith128BitLength,
    'keyWith256BitLength': keyWith256BitLength,
  };
}
