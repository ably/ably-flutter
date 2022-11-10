import 'package:meta/meta.dart';

/// @nodoc
/// An encapsulating object used to pass data to platform for registering events
@immutable
class AblyEventMessage {
  /// @nodoc
  /// name of the event to register a listener for
  final String eventName;

  /// @nodoc
  /// data to be passed for starting a listener
  final Object? message;

  /// @nodoc
  /// creates an instance with non-nul [eventName]
  ///
  /// [message] is optional
  const AblyEventMessage({
    required this.eventName,
    this.message,
  });
}
