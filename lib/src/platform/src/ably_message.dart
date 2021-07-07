import '../../generated/platform_constants.dart';

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