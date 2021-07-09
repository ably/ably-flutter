import '../../error/src/error_info.dart';

import 'device_push_state.dart';

/// Details of the push registration for a given device
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCP1
class DevicePushDetails {
  /// A map of string key/value pairs containing details of the push transport
  /// and address.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP3
  Map<String, String> recipient;

  /// The state of the push registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP4
  DevicePushState state;

  /// Any error information associated with the registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP2
  ErrorInfo? errorReason;

  DevicePushDetails(this.recipient, this.state, this.errorReason);
}
