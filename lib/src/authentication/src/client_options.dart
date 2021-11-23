import 'package:ably_flutter/ably_flutter.dart';

/// Ably library options used when instancing a REST or Realtime client library
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO1
class ClientOptions extends AuthOptions {
  /// Set fields on [ClientOptions] to configure it.
  ClientOptions();

  /// initializes [ClientOptions] with a key and log level set to info
  ///
  /// See [AuthOptions.fromKey] for more details
  ClientOptions.fromKey(String key) : super.fromKey(key);

  /// Optional clientId that can be used to specify the identity for this client
  ///
  /// In most cases it is preferable to instead specific a clientId in the token
  /// issued to this client.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3a
  String? clientId;

  /// Custom log handler
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3c
  LogHandler? logHandler;

  /// Controls the level of verbosity of log messages from the library
  ///
  /// Use constants from [LogLevel] to pass arguments
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3b
  int logLevel = LogLevel.info;

  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k2
  String? restHost;

  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k3
  String? realtimeHost;

  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k4
  int? port;

  /// Use a non-secure connection connection.
  ///
  /// By default, a TLS connection is used to connect to Ably
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3d
  bool tls = true;

  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k5
  int? tlsPort;

  /// Automatically connect to Ably when client is instantiated.
  ///
  /// This is true by default. If false, will wait for an explicit
  /// [Connection.connect] to be called before connecting
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1b
  bool autoConnect = true;

  /// Decides whether to use MsgPack binary encoding or JSON encoding.
  ///
  /// Defaults to true. If false, JSON encoding is used for REST and Realtime
  /// operations, instead of the default binary msgpack encoding.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3f
  bool useBinaryProtocol = true;

  /// When true, messages will be queued whilst the connection is disconnected.
  ///
  /// True by default.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3g
  bool queueMessages = true;

  /// When true, messages published on channels by this client will be
  /// echoed back to this client.
  ///
  /// This is true by default.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3h
  bool echoMessages = true;

  /// Can be used to explicitly recover a connection.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3i
  /// Also see https://www.ably.com/documentation/realtime/connection#connection-state-recovery
  String? recover;

  /// for development environments only
  ///
  /// Use this only if you have been provided a dedicated environment by Ably
  String? environment;

  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k6
  List<String>? fallbackHosts;

  /// for development environments only;
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k7
  @Deprecated('no alternative to this')
  bool? fallbackHostsUseDefault;

  /// When a TokenParams object is provided, it will override
  /// the client library defaults described in TokenParams
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3j11
  TokenParams? defaultTokenParams;

  /// When the connection enters the [ConnectionState.disconnected] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.disconnected], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 15,000 (15 seconds)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l1
  int disconnectedRetryTimeout = 15000;

  /// When the connection enters the [ConnectionState.suspended] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.suspended], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 30,000 (30 seconds)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l2
  int suspendedRetryTimeout = 30000;

  /// https://docs.ably.com/client-lib-development-guide/features/#TO3n
  bool? idempotentRestPublishing;

  /// Additional parameters to be sent in the querystring when initiating
  /// a realtime connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1f
  Map<String, String>? transportParams;

  /// Timeout for opening the connection, available in the client library
  /// if supported by the transport
  ///
  /// default 4,000 (4s)
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1f
  int httpOpenTimeout = 4000;

  /// Timeout for any single HTTP request and response
  ///
  /// default 10,000 (10s)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l4
  int httpRequestTimeout = 10000;

  /// Max number of fallback hosts to use as a fallback when an HTTP request
  /// to the primary host is unreachable or indicates that it is unserviceable
  ///
  /// default 3
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l5
  int httpMaxRetryCount = 3;

  /// When a realtime client library is establishing a connection with Ably,
  /// or sending a HEARTBEAT, CONNECT, ATTACH, DETACH or CLOSE ProtocolMessage
  /// to Ably, this is the amount of time that the client library will wait
  /// before considering that request as failed and triggering a suitable
  /// failure condition
  ///
  /// default 10s
  /// https://docs.ably.com/client-lib-development-guide/features/#DF1b
  int? realtimeRequestTimeout;

  /// After a failed request to the default endpoint,
  /// followed by a successful request to a fallback endpoint,
  /// the period in milliseconds before HTTP requests are retried
  /// against the default endpoint
  ///
  /// default 600000 (10 minutes)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l10
  int fallbackRetryTimeout = 600000;

  /// When a channel becomes [ChannelState.suspended] following a server
  /// initiated [ChannelState.detached], after this delay in milliseconds,
  /// if the channel is still [ChannelState.suspended] and the connection
  /// is [ConnectionState.connected], the client library will attempt
  /// to re-attach the channel automatically
  ///
  /// default 15,000 (15s)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l7
  int channelRetryTimeout = 15000;

// TODO(tiholic) unimplemented:
//
//  (TO3m) logExceptionReportingUrl
//  (TO3l6) httpMaxRetryDuration
//  (TO3l8) maxMessageSize
//  (TO3l9) maxFrameSize
//  (TO3o) plugins
//  (TO3p) addRequestIds
//  (DF1a) connectionStateTtl
}
