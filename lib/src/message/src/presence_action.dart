import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Status on a presence message
///
/// https://docs.ably.com/client-lib-development-guide/features/#TP2
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the possible actions members in the presence set can emit.
/// END CANONICAL DOCSTRING
enum PresenceAction {
  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client is absent for incoming [PresenceMessage]
  /// END LEGACY DOCSTRING
  absent,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client is present for incoming [PresenceMessage]
  /// END LEGACY DOCSTRING
  present,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client wants to enter a channel presence via
  /// outgoing [PresenceMessage]
  /// END LEGACY DOCSTRING
  enter,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that a client wants to leave a channel presence via
  /// outgoing [PresenceMessage]
  /// END LEGACY DOCSTRING
  leave,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that presence status of a client in presence member map
  /// needs to be updated
  /// END LEGACY DOCSTRING
  update,
}
