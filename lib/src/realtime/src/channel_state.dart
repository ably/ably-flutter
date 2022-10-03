import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// See Ably Realtime API documentation for more details.
/// https://docs.ably.com/client-lib-development-guide/features/#channel-states-operations
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the possible states of a [RestChannel] or [RealtimeChannel]
/// object.
/// END EDITED CANONICAL DOCSTRING
enum ChannelState {
  /// BEGIN LEGACY DOCSTRING
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel has been initialized but no attach has yet been attempted.
  /// END EDITED CANONICAL DOCSTRING
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// channel is attaching
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An attach has been initiated by sending a request to Ably. This is a
  /// transient state, followed either by a transition to `ATTACHED`,
  /// `SUSPENDED`, or `FAILED`.
  /// END EDITED CANONICAL DOCSTRING
  attaching,

  /// BEGIN LEGACY DOCSTRING
  /// channel is attached
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The attach has succeeded. In the `ATTACHED` state a client may publish and
  /// subscribe to messages, or be present on the channel.
  /// END EDITED CANONICAL DOCSTRING
  attached,

  /// BEGIN LEGACY DOCSTRING
  /// channel is detaching
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A detach has been initiated on an `ATTACHED` channel by sending a request
  /// to Ably. This is a transient state, followed either by a transition to
  /// `DETACHED` or `FAILED`.
  /// END EDITED CANONICAL DOCSTRING
  detaching,

  /// BEGIN LEGACY DOCSTRING
  /// channel is detached
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel, having previously been `ATTACHED`, has been detached by the
  /// user.
  /// END EDITED CANONICAL DOCSTRING
  detached,

  /// BEGIN LEGACY DOCSTRING
  /// channel is suspended
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel, having previously been `ATTACHED`, has lost continuity,
  /// usually due to the client being disconnected from Ably for longer than two
  /// minutes. It will automatically attempt to reattach as soon as connectivity
  /// is restored.
  /// END EDITED CANONICAL DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// channel failed to connect
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An indefinite failure condition. This state is entered if a channel
  /// error has been received from the Ably service, such as an attempt to
  /// attach without the necessary access rights.
  /// END EDITED CANONICAL DOCSTRING
  failed,
}
