enum ChannelState {
  initialized,
  attaching,
  attached,
  detaching,
  detached,
  suspended,
  failed
}

enum ChannelMode {
  // TB2d
  presence,
  publish,
  subscribe,
  presenceSubscribe
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

enum PresenceAction { absent, present, enter, leave, update }

enum StatsIntervalGranularity { minute, hour, day, month }

enum HTTPMethods { post, get }

/// Java: io.ably.lib.http.HttpAuth.Type
enum HttpAuthType {
  basic,
  digest,
  xAblyToken,
}

enum DevicePushState { active, failing, failed }

enum DevicePlatform { android, ios, browser }

enum FormFactor { phone, tablet, desktop, tv, watch, car, embedded, other }
