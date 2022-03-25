import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// An encapsulating object used to pass data to/from platform for method calls
@immutable
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
  const AblyMessage({
    required this.message,
    this.handle,
    this.type,
  });

  /// creates instance with [message] set to empty map
  ///
  /// [handle] and [type] are optional
  static AblyMessage<Map<String, dynamic>> empty({
    int? handle,
    int? type,
  }) =>
      AblyMessage(
        message: const {},
        handle: handle,
        type: type,
      );

  /// Cast ably message from [G] to [T]
  static AblyMessage<T> castFrom<G, T>(AblyMessage<G> source) => AblyMessage(
        message: source.message as T,
        handle: source.handle,
        type: source.type,
      );
}
