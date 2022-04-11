import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Details of the push registration for a given device
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCP1
@immutable
class DevicePushDetails {
  /// A map of string key/value pairs containing details of the push transport
  /// and address.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP3
  final Map<String, String>? recipient;

  /// The state of the push registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP4
  final DevicePushState? state;

  /// Any error information associated with the registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP2
  final ErrorInfo? errorReason;

  /// Initializes an instance without any defaults
  const DevicePushDetails({
    this.errorReason,
    this.recipient,
    this.state,
  });
}
