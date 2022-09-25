import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Details of the push registration for a given device
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCP1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains the details of the push registration of a device.
/// END CANONICAL DOCSTRING
@immutable
class DevicePushDetails {
  /// BEGIN LEGACY DOCSTRING
  /// A map of string key/value pairs containing details of the push transport
  /// and address.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A JSON object of key-value pairs that contains of the push transport and
  /// address.
  /// END CANONICAL DOCSTRING
  final Map<String, String>? recipient;

  /// BEGIN LEGACY DOCSTRING
  /// The state of the push registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP4
  /// END LEGACY DOCSTRING
  final DevicePushState? state;

  /// BEGIN LEGACY DOCSTRING
  /// Any error information associated with the registration.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCP2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An [ErrorInfo]{@link ErrorInfo} object describing the most recent error
  /// when the state is Failing or Failed.
  /// END CANONICAL DOCSTRING
  final ErrorInfo? errorReason;

  /// BEGIN LEGACY DOCSTRING
  /// Initializes an instance without any defaults
  /// END LEGACY DOCSTRING
  const DevicePushDetails({
    this.errorReason,
    this.recipient,
    this.state,
  });
}
