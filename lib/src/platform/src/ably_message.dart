import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// An encapsulating object used to pass data to/from platform for method calls
/// END LEGACY DOCSTRING
@immutable
class AblyMessage<T> {
  /// BEGIN LEGACY DOCSTRING
  /// handle of rest/realtime instance
  /// END LEGACY DOCSTRING
  final int? handle;

  /// BEGIN LEGACY DOCSTRING
  /// type of message (same as the generated [CodecTypes])
  /// END LEGACY DOCSTRING
  final int? type;

  /// BEGIN LEGACY DOCSTRING
  /// message to be passed to platform / received from platform
  /// END LEGACY DOCSTRING
  final T message;

  /// BEGIN LEGACY DOCSTRING
  /// creates instance with a non-null [message]
  ///
  /// [handle] and [type] are optional
  /// END LEGACY DOCSTRING
  const AblyMessage({
    required this.message,
    this.handle,
    this.type,
  });

  /// BEGIN LEGACY DOCSTRING
  /// creates instance with [message] set to empty map
  ///
  /// [handle] and [type] are optional
  /// END LEGACY DOCSTRING
  static AblyMessage<Map<String, dynamic>> empty({
    int? handle,
    int? type,
  }) =>
      AblyMessage(
        message: const {},
        handle: handle,
        type: type,
      );

  /// BEGIN LEGACY DOCSTRING
  /// Cast ably message from [G] to [T]
  /// END LEGACY DOCSTRING
  static AblyMessage<T> castFrom<G, T>(AblyMessage<G> source) => AblyMessage(
        message: source.message as T,
        handle: source.handle,
        type: source.type,
      );
}
