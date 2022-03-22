import 'dart:io' as io show Platform;
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';

/// The internal (non-public) representation of CipherParams.
///
/// On Android, most fields are either private or package-private, and cannot
/// be accessed. Therefore, ably-flutter stores the instance of CipherParams
/// and only gives a references to the dart side. When another method is passed
/// a reference to the instance, we use the reference to get back the instance.
///
/// On iOS, ARTCipherParams fields are public. Therefore, ably-flutter can
/// instantiate a new one using algorithm and key when needed, without
/// needing to store instances on the Android side and pass references/handles
/// to the dart side.
class CipherParamsInternal implements CipherParams {
  int? androidHandle;
  Uint8List? key;

  String? algorithm;

  String? mode = 'cbc';

  /// Create a Dart side representation of CipherParams
  CipherParamsInternal.forIOS({
    required this.algorithm,
    required this.key,
  }) {
    if (!io.Platform.isIOS) {
      throw AblyException(
        message: 'This method is for iOS platforms only',
      );
    }
    if (key == null) {
      throw AblyException(
        message: 'CipherParamsNative on iOS must have a key, as '
            'this key is used to regenerate the ARTCipherParams on the '
            'iOS side.',
      );
    }
  }

  CipherParamsInternal.forAndroid({
    required this.androidHandle,
  }) {
    if (!io.Platform.isAndroid) {
      throw AblyException(message: 'This method is for Android platforms only');
    }
    if (androidHandle == null) {
      throw AblyException(
        message: 'CipherParamsNative on Android must have a handle, '
            'as this key is used to get the previously generated '
            'CipherParams on the Android side',
      );
    }
  }

  static CipherParamsInternal fromCipherParams(CipherParams cipherParams) =>
      cipherParams as CipherParamsInternal;

  /// Explicitly cast the [CipherParamsInternal] to [CipherParams] so users do not
  /// see implementation details (e.g. [androidHandle]).
  CipherParams toCipherParams() => this;
}
