import '../../ably_flutter.dart';

/// An encapsulating object used to pass data to/from platform for method calls
class AblyMessage<T> {
  /// handle of rest/realtime instance
  final int? handle;

  /// type of message (same as the generated [CodecTypes])
  final int? type;

  /// message to be passed to platform / received from platform
  final T message;

  /// creates instance with a non-null [message]
  ///
  /// [handle] and [type] are optional
  ///
  /// Raises [AssertionError] if [message] is null
  AblyMessage(
    this.message, {
    this.handle,
    this.type,
  });

  /// Cast ably message from [G] to [T]
  static AblyMessage<T> castFrom<G, T>(AblyMessage<G> source) => AblyMessage(
        source.message as T,
        handle: source.handle,
        type: source.type,
      );
}

/// An encapsulating object used to pass data to platform for registering events
class AblyEventMessage {
  /// name of the event to register a listener for
  final String eventName;

  /// data to be passed for starting a listener
  final Object? message;

  /// creates an instance with non-nul [eventName]
  ///
  /// [message] is optional
  ///
  /// Raises [AssertionError] if [eventName] is null
  AblyEventMessage(this.eventName, [this.message]);
}
