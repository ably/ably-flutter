import 'package:ably_flutter/ably_flutter.dart';

/// The current state of the push registration in [DevicePushDetails].
enum DevicePushState {
  /// Indicates that push state of the device is `active`.
  active,

  /// Indicates that push state of the device is `failing`.
  failing,

  /// Indicates that push state of the device is `failed`.
  failed,
}
