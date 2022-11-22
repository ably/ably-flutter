import 'package:ably_flutter/ably_flutter.dart';

/// Describes the events emitted by a [RestChannel] or [RealtimeChannel] object.
///
/// An event is either an `UPDATE` or a [ChannelState].
enum ChannelEvent {
  /// The channel has been initialized but no attach has yet been attempted.
  initialized,

  /// An attach has been initiated by sending a request to Ably.
  ///
  /// This is a  transient state, followed either by a transition to `ATTACHED`,
  /// `SUSPENDED`, or `FAILED`.
  attaching,

  /// The attach has succeeded.
  ///
  /// In the `ATTACHED` state a client may publish and subscribe to messages, or
  /// be present on the channel.
  attached,

  /// A detach has been initiated on an `ATTACHED` channel by sending a request
  /// to Ably.
  ///
  /// This is a transient state, followed either by a transition to `DETACHED`
  /// or `FAILED`.
  detaching,

  /// The channel, having previously been `ATTACHED`, has been detached by the
  /// user.
  detached,

  /// The channel, having previously been `ATTACHED`, has lost continuity,
  /// usually due to the client being disconnected from Ably for longer than two
  /// minutes.
  ///
  /// It will automatically attempt to reattach as soon as connectivity
  /// is restored.
  suspended,

  /// An indefinite failure condition.
  ///
  /// This state is entered if a channel error
  /// has been received from the Ably service, such as an attempt to attach
  /// without the necessary access rights.
  failed,

  /// An event for changes to channel conditions that do not result in a change
  /// in [ChannelState].
  update,
}
