import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';

Future<Map<String, dynamic>> testCryptoEnsureSupportedKeyLength({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  Map<String, dynamic>? keyWithDefaultLengthException;
  Map<String, dynamic>? keyWith128BitLengthException;
  Map<String, dynamic>? keyWith256BitLengthException;
  Map<String, dynamic>? keyWith127BitLengthException;

  try {
    final keyWithDefaultLength = await Crypto.generateRandomKey();
    Crypto.ensureSupportedKeyLength(keyWithDefaultLength);
  } on AblyException catch (exception) {
    keyWithDefaultLengthException = encodeAblyException(exception);
  }

  try {
    final keyWith128BitLength = await Crypto.generateRandomKey(keyLength: 128);
    Crypto.ensureSupportedKeyLength(keyWith128BitLength);
  } on AblyException catch (exception) {
    keyWith128BitLengthException = encodeAblyException(exception);
  }

  try {
    final keyWith256BitLength = await Crypto.generateRandomKey(keyLength: 256);
    Crypto.ensureSupportedKeyLength(keyWith256BitLength);
  } on AblyException catch (exception) {
    keyWith256BitLengthException = encodeAblyException(exception);
  }

  try {
    final keyWith127BitLength =
        Uint8List.fromList(List.generate(127, (index) => index));
    Crypto.ensureSupportedKeyLength(keyWith127BitLength);
  } on AblyException catch (exception) {
    keyWith127BitLengthException = encodeAblyException(exception);
  }

  return {
    'keyWithDefaultLengthException': keyWithDefaultLengthException,
    'keyWith128BitLengthException': keyWith128BitLengthException,
    'keyWith256BitLengthException': keyWith256BitLengthException,
    'keyWith127BitLengthException': keyWith127BitLengthException,
  };
}
