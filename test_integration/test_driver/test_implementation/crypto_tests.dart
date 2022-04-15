import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_test/flutter_test.dart';

void testCryptoGenerateRandomKey(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.cryptoGenerateRandomKey);
  late TestControlResponseMessage response;
  late List<dynamic> keyWithDefaultLength;
  late List<dynamic> keyWith128BitLength;
  late List<dynamic> keyWith256BitLength;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    keyWithDefaultLength =
        response.payload['keyWithDefaultLength'] as List<dynamic>;
    keyWith128BitLength =
        response.payload['keyWith128BitLength'] as List<dynamic>;
    keyWith256BitLength =
        response.payload['keyWith256BitLength'] as List<dynamic>;
  });

  group('crypto#generateRandomKey', () {
    test('generates key with default length if length is not specified', () {
      const defaultKeyLength = Crypto.defaultKeyLengthInBits / 8;
      expect(keyWithDefaultLength.length, defaultKeyLength);
    });

    test('generates keys with specified length', () {
      const keyLength128Bit = 128 / 8;
      const keyLength256Bit = 256 / 8;
      expect(keyWith128BitLength.length, equals(keyLength128Bit));
      expect(keyWith256BitLength.length, equals(keyLength256Bit));
    });
  });
}
