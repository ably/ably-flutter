import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Status on a presence message
///
/// https://docs.ably.com/client-lib-development-guide/features/#TP2
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the possible actions members in the presence set can emit.
/// END EDITED CANONICAL DOCSTRING
enum PresenceAction {
  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client is absent for incoming [PresenceMessage]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A member is not present in the channel.
  /// END EDITED CANONICAL DOCSTRING
  absent,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client is present for incoming [PresenceMessage]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// When subscribing to presence events on a channel that already has members
  /// present, this event is emitted for every member already present on the
  /// channel before the subscribe listener was registered.
  /// END EDITED CANONICAL DOCSTRING
  present,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client wants to enter a channel presence via
  /// outgoing [PresenceMessage]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A new member has entered the channel.
  /// END EDITED CANONICAL DOCSTRING
  enter,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client wants to leave a channel presence via
  /// outgoing [PresenceMessage]
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A member who was present has now left the channel. This may be a result of
  /// an explicit request to leave or implicitly when detaching from the
  /// channel. Alternatively, if a member's connection is abruptly disconnected
  /// and they do not resume their connection within a minute, Ably treats this
  /// as a leave event as the client is no longer present.
  /// END EDITED CANONICAL DOCSTRING
  leave,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that presence status of a client in presence member map
  /// needs to be updated
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An already present member has updated their member data. Being notified of
  /// member data updates can be very useful, for example, it can be used to
  /// update the status of a user when they are typing a message.
  /// END EDITED CANONICAL DOCSTRING
  update,
}
