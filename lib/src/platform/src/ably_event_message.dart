import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// @nodoc
/// An encapsulating object used to pass data to platform for registering events
/// END LEGACY DOCSTRING
@immutable
class AblyEventMessage {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// name of the event to register a listener for
  /// END LEGACY DOCSTRING
  final String eventName;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// data to be passed for starting a listener
  /// END LEGACY DOCSTRING
  final Object? message;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// creates an instance with non-nul [eventName]
  ///
  /// [message] is optional
  /// END LEGACY DOCSTRING
  const AblyEventMessage({
    required this.eventName,
    this.message,
  });
}
