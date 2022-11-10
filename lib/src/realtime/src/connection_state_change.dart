import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains [ConnectionState] change information emitted by the [Connection]
/// object.
/// END EDITED CANONICAL DOCSTRING
@immutable
class ConnectionStateChange {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The event that triggered this [ConnectionState] change.
  /// END EDITED CANONICAL DOCSTRING
  final ConnectionEvent event;

  /// BEGIN CANONICAL DOCSTRING
  /// The new [ConnectionState].
  /// END CANONICAL DOCSTRING
  final ConnectionState current;

  /// BEGIN CANONICAL DOCSTRING
  /// The previous [ConnectionState]. For the [ConnectionEvent.update] event,
  /// this is equal to the current [ConnectionState].
  /// END CANONICAL DOCSTRING
  final ConnectionState previous;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An [ErrorInfo object containing any information relating to the
  /// transition.
  /// END EDITED CANONICAL DOCSTRING
  final ErrorInfo? reason;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Duration in milliseconds, after which the client retries a connection
  /// where applicable.
  /// END EDITED CANONICAL DOCSTRING
  final int? retryIn;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// initializes without any defaults
  /// END LEGACY DOCSTRING
  const ConnectionStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.retryIn,
  });
}
