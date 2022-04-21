import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';

Future<Map<String, dynamic>> testCryptoGetDefaultParams({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  Map<String, dynamic>? keyWith127BitLengthException;
  bool? didFetchDefaultParams;

  final keyWithDefaultLength = await Crypto.generateRandomKey();

  final keyWith127BitLength =
      Uint8List.fromList(List.generate(127, (index) => index));

  try {
    await Crypto.getDefaultParams(key: keyWith127BitLength);
  } on AblyException catch (exception) {
    keyWith127BitLengthException = encodeAblyException(exception);
  }

  try {
    await Crypto.getDefaultParams(key: keyWithDefaultLength);
    didFetchDefaultParams = true;
  } on AblyException {
    didFetchDefaultParams = false;
  }

  return {
    'keyWith127BitLengthException': keyWith127BitLengthException,
    'didFetchDefaultParams': didFetchDefaultParams,
  };
}
