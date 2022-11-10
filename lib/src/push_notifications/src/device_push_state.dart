import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED DOCSTRING
/// The current state of the push registration in [DevicePushDetails]
/// END EDITED DOCSTRING
enum DevicePushState {

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `active`
  /// END EDITED DOCSTRING
  active,

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `failing`
  /// END EDITED DOCSTRING
  failing,

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `failed`
  /// END EDITED DOCSTRING
  failed,
}
