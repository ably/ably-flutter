import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains [ConnectionState] change information emitted by the [Connection]
/// object.
@immutable
class ConnectionStateChange {
  /// The event that triggered this [ConnectionState] change.
  final ConnectionEvent event;

  /// The new [ConnectionState].
  final ConnectionState current;

  /// The previous [ConnectionState].
  ///
  /// For the [ConnectionEvent.update] event, this is equal to the current
  /// [ConnectionState].
  final ConnectionState previous;

  /// An [ErrorInfo object containing any information relating to the
  /// transition.
  final ErrorInfo? reason;

  /// Duration in milliseconds, after which the client retries a connection
  /// where applicable.
  final int? retryIn;

  /// @nodoc
  /// initializes without any defaults
  const ConnectionStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.retryIn,
  });
}
