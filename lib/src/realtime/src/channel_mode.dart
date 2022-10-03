import 'package:ably_flutter/src/realtime/realtime.dart';
import 'package:ably_flutter/src/rest/rest.dart';

/// BEGIN LEGACY DOCSTRING
/// Set of flags that represent the capabilities of a channel for current client
///
/// See:
/// https://docs.ably.com/client-lib-development-guide/features/#TB2d
/// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the possible flags used to configure client capabilities, using
/// [RestChannelOptions] or [RealtimeChannelOptions].
/// END EDITED CANONICAL DOCSTRING
enum ChannelMode {
  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can check for presence
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can enter the presence set.
  /// END EDITED CANONICAL DOCSTRING
  presence,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can publish
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can publish messages.
  /// END EDITED CANONICAL DOCSTRING
  publish,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can subscribe to messages
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can subscribe to messages.
  /// END EIDTED CANONICAL DOCSTRING
  subscribe,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can subscribe to presence events
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can receive presence messages.
  /// END EDITED CANONICAL DOCSTRING
  presenceSubscribe,
}
