import '../../ably_flutter.dart';

/// Set of flags that represent the capabilities of a channel for current client
///
/// See:
/// https://docs.ably.io/client-lib-development-guide/features/#TB2d
/// https://docs.ably.io/client-lib-development-guide/features/#RTL4m
enum ChannelMode {
  /// specifies that channel can check for presence
  presence,

  /// specifies that channel can publish
  publish,

  /// specifies that channel can subscribe to messages
  subscribe,

  /// specifies that channel can subscribe to presence events
  presenceSubscribe,
}

/// Connection state
///
/// See Ably Realtime API documentation for more details.
/// https://docs.ably.io/client-lib-development-guide/features/#connection-states-operations
enum ConnectionState {
  /// specifies that a connection is initialized
  initialized,

  /// specifies that a connection to ably is being established
  connecting,

  /// specifies that a connection to ably is established
  connected,

  /// specifies that a connection to ably is disconnected
  disconnected,

  /// specifies that a connection to ably is suspended
  suspended,

  /// specifies that a connection to ably is closing
  closing,

  /// specifies that a connection to ably is closed
  closed,

  /// specifies that a connection to ably is failed
  failed,
}

/// Connection event is same as [ConnectionState] except that it also handles
/// update operations on a connection
///
/// See Ably Realtime API documentation for more details.
enum ConnectionEvent {
  /// specifies that a connection is initialized
  initialized,

  /// specifies that a connection to ably is being established
  connecting,

  /// specifies that a connection to ably is established
  connected,

  /// specifies that a connection to ably is disconnected
  disconnected,

  /// specifies that a connection to ably is suspended
  suspended,

  /// specifies that a connection to ably is closing
  closing,

  /// specifies that a connection to ably is closed
  closed,

  /// specifies that a connection to ably is failed
  failed,

  /// specifies that a connection is updated
  update,
}

/// Channel states
///
/// See Ably Realtime API documentation for more details.
/// https://docs.ably.io/client-lib-development-guide/features/#channel-states-operations
enum ChannelState {
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  initialized,

  /// channel is attaching
  attaching,

  /// channel is attached
  attached,

  /// channel is detaching
  detaching,

  /// channel is detached
  detached,

  /// channel is suspended
  suspended,

  /// channel failed to connect
  failed,
}

/// Channel events
///
/// See Ably Realtime API documentation for more details.
enum ChannelEvent {
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  initialized,

  /// channel is attaching
  attaching,

  /// channel is attached
  attached,

  /// channel is detaching
  detaching,

  /// channel is detached
  detached,

  /// channel is suspended
  suspended,

  /// channel failed to connect
  failed,

  /// specifies that a channel state is updated
  update,
}

/// Status on a presence message
///
/// https://docs.ably.io/client-lib-development-guide/features/#TP2
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

/// https://docs.ably.io/client-lib-development-guide/features/#TS12c
enum StatsIntervalGranularity {
  /// indicates units in minutes
  minute,

  /// indicates units in hours
  hour,

  /// indicates units in days
  day,

  /// indicates units in months
  month,
}

/// Java: io.ably.lib.http.HttpAuth.Type
enum HttpAuthType {
  /// indicates basic authentication
  basic,

  /// digest authentication
  digest,

  /// Token auth
  xAblyToken,
}

/// To indicate Push State of a device in [DeviceDetails] via [DevicePushState]
/// while registering
enum DevicePushState {
  /// indicates active push state of the device
  active,

  /// indicates that push state is failing
  failing,

  /// indicates the device push state failed
  failed,
}

/// To indicate the operating system -or- platform of the client using SDK
/// in [DeviceDetails] while registering
enum DevicePlatform {
  /// indicates an android device
  android,

  /// indicates an iOS device
  ios,

  /// indicates a browser
  browser,
}

/// To indicate the type of device in [DeviceDetails] while registering
///
/// https://docs.ably.io/client-lib-development-guide/features/#PCD4
enum FormFactor {
  /// indicates the device is a mobile phone
  phone,

  /// indicates the device is a tablet
  tablet,

  /// indicates the device is a desktop
  desktop,

  /// indicates the device is a television
  tv,

  /// indicates the device is a smart watch
  watch,

  /// indicates the device is an automobile
  car,

  /// indicates the device is an embedded system / iOT device
  embedded,

  /// indicates the device belong to categories other than mentioned above
  other,
}
