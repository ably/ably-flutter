enum ChannelState {
  initialized,
  attaching,
  attached,
  detaching,
  detached,
  suspended,
  failed
}

enum ChannelEvent {
  initialized,
  attaching,
  attached,
  detaching,
  detached,
  suspended,
  failed,
  update
}

enum ConnectionState {
  initialized,
  connecting,
  connected,
  disconnected,
  suspended,
  closing,
  closed,
  failed
}

enum ConnectionEvent {
  initialized,
  connecting,
  connected,
  disconnected,
  suspended,
  closing,
  closed,
  failed,
  update
}

enum PresenceAction {
  absent,
  present,
  enter,
  leave,
  update
}

enum StatsIntervalGranularity {
  minute,
  hour,
  day,
  month
}

enum HTTPMethods {
  POST,
  GET
}

/// Java: io.ably.lib.http.HttpAuth.Type
enum HttpAuthType {
  BASIC,
  DIGEST,
  X_ABLY_TOKEN,
}

enum Transport{
  web_socket,
  xhr_streaming,
  xhr_polling,
  jsonp,
  comet
}

enum capabilityOp{
  publish,
  subscribe,
  presence,
  history,
  stats,
  channel_metadata,
  push_subscribe,
  push_admin
}

enum LogLevel{
  none,   //no logs
  errors, //errors only
  info,   //errors and channel state changes
  debug,  //high-level debug output
  verbose //full debug output
}

enum DevicePushState{
  active,
  failing,
  failed
}

enum DevicePlatform{
  android,
  ios,
  browser
}

enum FormFactor{
  phone,
  tablet,
  desktop,
  tv,
  watch,
  car,
  embedded,
  other
}