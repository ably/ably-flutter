import 'dart:io';
import 'dart:typed_data';

import '../../error/src/ably_exception.dart';
import 'cipher_params.dart';

/// On Android, most fields are either private or package-private, and cannot
/// be accessed. Therefore, Ably Flutter stores the instance of CipherParams
/// and only gives a references to the dart side. When another method want
/// to use this instance, we use the reference to get back the instance.
class CipherParamsNative implements CipherParams {
  int? androidHandle;

  /// On iOS, ARTCipherParams fields are public.
  /// Therefore, Ably Flutter can instantiate a new one when needed, without
  /// needing to store instances on the Android side and pass
  /// references/handles to the dart side.
  Uint8List? key;

  String? algorithm;

  String? mode = "cbc";

  /// Create a Dart side representation of CipherParams
  CipherParamsNative.forIOS({
    required this.algorithm,
    required this.key,
  }) {
    if (!Platform.isIOS) {
      throw AblyException('This method is for iOS platforms only');
    }
    if (key == null) {
      throw AblyException('CipherParamsNative on iOS must have a key, as '
          'this key is used to regenerate the ARTCipherParams on the '
          'iOS side.');
    }
  }

  CipherParamsNative.forAndroid({
    required this.androidHandle,
  }) {
    if (!Platform.isAndroid) {
      throw AblyException('This method is for Android platforms only');
    }
    if (androidHandle == null) {
      throw AblyException('CipherParamsNative on Android must have a handle, '
          'as this key is used to get the previously generated '
          'CipherParams on the Android side');
    }
  }

  static fromCipherParams(CipherParams cipherParams) => cipherParams as CipherParamsNative;

  /// Explicitly cast the [CipherParamsNative] to [CipherParams] so users do not
  /// see implementation details (e.g. [androidHandle]).
  CipherParams toCipherParams() => this;
}
