import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the details of the push registration of a device.
/// END EDITED CANONICAL DOCSTRING
@immutable
class DevicePushDetails {

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [Map] object of key-value pairs that consists of the push transport and
  /// address.
  /// END EDITED CANONICAL DOCSTRING
  final Map<String, String>? recipient;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The current state of the push registration.
  /// END EDITED CANONICAL DOCSTRING
  final DevicePushState? state;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An [ErrorInfo] object describing the most recent error when the `state` is
  /// `Failing` or `Failed`.
  /// END EDITED CANONICAL DOCSTRING
  final ErrorInfo? errorReason;

  /// @nodoc
  /// Initializes an instance without any defaults
  const DevicePushDetails({
    this.errorReason,
    this.recipient,
    this.state,
  });
}
