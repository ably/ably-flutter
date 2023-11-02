import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains the details of the push registration of a device.
@immutable
class DevicePushDetails {
  /// A [Map] object of key-value pairs that consists of the push transport and
  /// address.
  final Map<String, Object>? recipient;

  /// The current state of the push registration.
  final DevicePushState? state;

  /// An [ErrorInfo] object describing the most recent error when the `state` is
  /// `Failing` or `Failed`.
  final ErrorInfo? errorReason;

  /// @nodoc
  /// Initializes an instance without any defaults
  const DevicePushDetails({
    this.errorReason,
    this.recipient,
    this.state,
  });
}
