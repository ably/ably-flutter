import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Connection event is same as [ConnectionStateChange] except that it also
/// handles update operations on a connection
///
/// See Ably Realtime API documentation for more details.
/// END LEGACY DOCSTRING
enum ConnectionEvent {
  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection is initialized
  /// END LEGACY DOCSTRING
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is being established
  /// END LEGACY DOCSTRING
  connecting,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is established
  /// END LEGACY DOCSTRING
  connected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is disconnected
  /// END LEGACY DOCSTRING
  disconnected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is suspended
  /// END LEGACY DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closing
  /// END LEGACY DOCSTRING
  closing,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closed
  /// END LEGACY DOCSTRING
  closed,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is failed
  /// END LEGACY DOCSTRING
  failed,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection is updated
  /// END LEGACY DOCSTRING
  update,
}
