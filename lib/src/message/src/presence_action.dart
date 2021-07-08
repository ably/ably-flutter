import '../message.dart';

/// Status on a presence message
///
/// https://docs.ably.com/client-lib-development-guide/features/#TP2
enum PresenceAction {
  /// indicates that a client is absent for incoming [PresenceMessage]
  absent,

  /// indicates that a client is present for incoming [PresenceMessage]
  present,

  /// indicates that a client wants to enter a channel presence via
  /// outgoing [PresenceMessage]
  enter,

  /// indicates that a client wants to leave a channel presence via
  /// outgoing [PresenceMessage]
  leave,

  /// indicates that presence status of a client in presence member map
  /// needs to be updated
  update,
}
