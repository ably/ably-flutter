import 'package:ably_flutter/src/realtime/realtime.dart';
import 'package:ably_flutter/src/rest/rest.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the possible flags used to configure client capabilities, using
/// [RestChannelOptions] or [RealtimeChannelOptions].
/// END EDITED CANONICAL DOCSTRING
enum ChannelMode {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can enter the presence set.
  /// END EDITED CANONICAL DOCSTRING
  presence,

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can publish messages.
  /// END EDITED CANONICAL DOCSTRING
  publish,

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can subscribe to messages.
  /// END EIDTED CANONICAL DOCSTRING
  subscribe,
  
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client can receive presence messages.
  /// END EDITED CANONICAL DOCSTRING
  presenceSubscribe,
}
