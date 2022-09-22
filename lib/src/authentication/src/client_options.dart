import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Ably library options used when instancing a REST or Realtime client library
///
/// https://docs.ably.com/client-lib-development-guide/features/#TO1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Passes additional client-specific properties to the REST
/// [constructor()]{@link RestClient#constructor} or the Realtime
/// [constructor()]{@link RealtimeClient#constructor}.
/// END CANONICAL DOCSTRING
class ClientOptions extends AuthOptions {
  /// BEGIN LEGACY DOCSTRING
  /// Optional clientId that can be used to specify the identity for this client
  ///
  /// In most cases it is preferable to instead specific a clientId in the token
  /// issued to this client.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3a
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes. The clientId can be any non-empty string, except it
  /// cannot contain a *. This option is primarily intended to be used in
  /// situations where the library is instantiated with a key. Note that a
  /// clientId may also be implicit in a token used to instantiate the library.
  /// An error will be raised if a clientId specified here conflicts with the
  /// clientId implicit in the token.
  /// END CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// Custom log handler
  ///
  /// For discussion about removing this component see
  /// https://github.com/ably/ably-flutter/issues/238
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3c
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Controls the log output of the library. This is a function to handle each
  /// line of log output.
  /// END CANONICAL DOCSTRING
  @Deprecated(
    'Not used, as log messages are handled by the default mechanism '
    'in the underlying SDK. This instance variable will be removed '
    'in a future release.',
  )
  LogHandler? logHandler;

  /// BEGIN LEGACY DOCSTRING
  /// Controls the level of verbosity of log messages from the library
  ///
  /// Use constants from [LogLevel] to pass arguments
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Controls the verbosity of the logs output from the library. Levels include
  /// verbose, debug, info, warn and error.
  /// END CANONICAL DOCSTRING
  LogLevel logLevel = LogLevel.info;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enables a non-default Ably host to be specified. For development
  /// environments only. The default value is rest.ably.io.
  /// END CANONICAL DOCSTRING
  String? restHost;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enables a non-default Ably host to be specified for realtime connections.
  /// For development environments only. The default value is realtime.ably.io.
  /// END CANONICAL DOCSTRING
  String? realtimeHost;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k4
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enables a non-default Ably port to be specified. For development
  /// environments only. The default value is 80.
  /// END CANONICAL DOCSTRING
  int? port;

  /// BEGIN LEGACY DOCSTRING
  /// Use a non-secure connection connection.
  ///
  /// By default, a TLS connection is used to connect to Ably
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3d
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// When false, the client will use an insecure connection. The default is
  /// true, meaning a TLS connection will be used to connect to Ably.
  /// END CANONICAL DOCSTRING
  bool tls = true;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k5
  /// END LEGACY DOCSTRING
  int? tlsPort;

  /// BEGIN LEGACY DOCSTRING
  /// Automatically connect to Ably when client is instantiated.
  ///
  /// This is true by default. If false, will wait for an explicit
  /// [Connection.connect] to be called before connecting
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// When true, the client connects to Ably as soon as it is instantiated.
  /// You can set this to false and explicitly connect to Ably using the
  /// [connect()]{@link Connection#connect} method. The default is true.
  /// END CANONICAL DOCSTRING
  bool autoConnect = true;

  /// BEGIN LEGACY DOCSTRING
  /// Decides whether to use MsgPack binary encoding or JSON encoding.
  ///
  /// Defaults to true. If false, JSON encoding is used for REST and Realtime
  /// operations, instead of the default binary msgpack encoding.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3f
  /// END LEGACY DOCSTRING
  bool useBinaryProtocol = true;

  /// BEGIN LEGACY DOCSTRING
  /// When true, messages will be queued whilst the connection is disconnected.
  ///
  /// True by default.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3g
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// If false, this disables the default behavior whereby the library queues
  /// messages on a connection in the disconnected or connecting states. The
  /// default behavior enables applications to submit messages immediately upon
  /// instantiating the library without having to wait for the connection to be
  /// established. Applications may use this option to disable queueing if they
  /// wish to have application-level control over the queueing. The default is
  /// true.
  /// END CANONICAL DOCSTRING
  bool queueMessages = true;

  /// BEGIN LEGACY DOCSTRING
  /// When true, messages published on channels by this client will be
  /// echoed back to this client.
  ///
  /// This is true by default.
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3h
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// If false, prevents messages originating from this connection being echoed
  /// back on the same connection. The default is true.
  /// END CANONICAL DOCSTRING
  bool echoMessages = true;

  /// BEGIN LEGACY DOCSTRING
  /// Can be used to explicitly recover a connection.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3i
  /// Also see https://www.ably.com/documentation/realtime/connection#connection-state-recovery
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enables a connection to inherit the state of a previous connection that
  /// may have existed under a different instance of the Realtime library. This
  /// might typically be used by clients of the browser library to ensure
  /// connection state can be preserved when the user refreshes the page.
  /// A recovery key string can be explicitly provided, or alternatively if a
  /// callback function is provided, the client library will automatically
  /// persist the recovery key between page reloads and call the callback
  /// when the connection is recoverable. The callback is then responsible for
  /// confirming whether the connection should be recovered or not. See
  /// [connection state recovery](https://ably.com/docs/realtime/connection/#connection-state-recovery) for further information.
  /// END CANONICAL DOCSTRING
  String? recover;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// Use this only if you have been provided a dedicated environment by Ably
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enables a
  /// [custom environment](https://ably.com/docs/platform-customization) to be
  /// used with the Ably service.
  /// END CANONICAL DOCSTRING
  String? environment;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k6
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An array of fallback hosts to be used in the case of an error
  /// necessitating the use of an alternative host.
  /// If you have been provided a set of custom fallback hosts by Ably, please
  /// specify them here.
  /// END CANONICAL DOCSTRING
  List<String>? fallbackHosts;

  /// BEGIN LEGACY DOCSTRING
  /// for development environments only;
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3k7
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// DEPRECATED: this property is deprecated and will be removed in a future
  /// version. Enables default fallback hosts to be used.
  /// END CANONICAL DOCSTRING
  @Deprecated('no alternative to this')
  bool? fallbackHostsUseDefault;

  /// BEGIN LEGACY DOCSTRING
  /// When a TokenParams object is provided, it will override
  /// the client library defaults described in TokenParams
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3j11
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// When a [TokenParams]{@link TokenParams} object is provided, it overrides
  /// the client library defaults when issuing new Ably Tokens or Ably
  /// [TokenRequests]{@link TokenRequest}.
  /// END CANONICAL DOCSTRING
  TokenParams? defaultTokenParams;

  /// BEGIN LEGACY DOCSTRING
  /// When the connection enters the [ConnectionState.disconnected] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.disconnected], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 15,000 (15 seconds)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l1
  /// END LEGACY DOCSTRING
  int disconnectedRetryTimeout = 15000;

  /// BEGIN LEGACY DOCSTRING
  /// When the connection enters the [ConnectionState.suspended] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.suspended], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 30,000 (30 seconds)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l2
  /// END LEGACY DOCSTRING
  int suspendedRetryTimeout = 30000;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3n
  /// END LEGACY DOCSTRING
  bool? idempotentRestPublishing;

  /// BEGIN LEGACY DOCSTRING
  /// Additional parameters to be sent in the querystring when initiating
  /// a realtime connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1f
  /// END LEGACY DOCSTRING
  Map<String, String>? transportParams;

  /// BEGIN LEGACY DOCSTRING
  /// Timeout for opening the connection, available in the client library
  /// if supported by the transport
  ///
  /// default 4,000 (4s)
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1f
  /// END LEGACY DOCSTRING
  int httpOpenTimeout = 4000;

  /// BEGIN LEGACY DOCSTRING
  /// Timeout for any single HTTP request and response
  ///
  /// default 10,000 (10s)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l4
  /// END LEGACY DOCSTRING
  int httpRequestTimeout = 10000;

  /// BEGIN LEGACY DOCSTRING
  /// Max number of fallback hosts to use as a fallback when an HTTP request
  /// to the primary host is unreachable or indicates that it is unserviceable
  ///
  /// default 3
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l5
  /// END LEGACY DOCSTRING
  int httpMaxRetryCount = 3;

  /// BEGIN LEGACY DOCSTRING
  /// When a realtime client library is establishing a connection with Ably,
  /// or sending a HEARTBEAT, CONNECT, ATTACH, DETACH or CLOSE ProtocolMessage
  /// to Ably, this is the amount of time that the client library will wait
  /// before considering that request as failed and triggering a suitable
  /// failure condition
  ///
  /// default 10s
  /// https://docs.ably.com/client-lib-development-guide/features/#DF1b
  /// END LEGACY DOCSTRING
  int? realtimeRequestTimeout;

  /// BEGIN LEGACY DOCSTRING
  /// After a failed request to the default endpoint,
  /// followed by a successful request to a fallback endpoint,
  /// the period in milliseconds before HTTP requests are retried
  /// against the default endpoint
  ///
  /// default 600000 (10 minutes)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l10
  /// END LEGACY DOCSTRING
  int fallbackRetryTimeout = 600000;

  /// BEGIN LEGACY DOCSTRING
  /// When a channel becomes [ChannelState.suspended] following a server
  /// initiated [ChannelState.detached], after this delay in milliseconds,
  /// if the channel is still [ChannelState.suspended] and the connection
  /// is [ConnectionState.connected], the client library will attempt
  /// to re-attach the channel automatically
  ///
  /// default 15,000 (15s)
  /// https://docs.ably.com/client-lib-development-guide/features/#TO3l7
  /// END LEGACY DOCSTRING
  int channelRetryTimeout = 15000;

  /// BEGIN LEGACY DOCSTRING
  /// Initializes an instance with defaults
  /// END LEGACY DOCSTRING
  ClientOptions({
    AuthCallback? authCallback,
    Map<String, String>? authHeaders,
    String? authMethod,
    Map<String, String>? authParams,
    String? authUrl,
    bool? autoConnect,
    int? channelRetryTimeout,
    this.clientId,
    this.defaultTokenParams,
    int? disconnectedRetryTimeout,
    bool? echoMessages,
    this.environment,
    this.fallbackHosts,
    int? fallbackRetryTimeout,
    this.fallbackHostsUseDefault,
    int? httpMaxRetryCount,
    int? httpOpenTimeout,
    int? httpRequestTimeout,
    this.idempotentRestPublishing,
    String? key,
    this.logHandler,
    LogLevel? logLevel,
    this.port,
    bool? queryTime,
    bool? queueMessages,
    this.realtimeHost,
    this.realtimeRequestTimeout,
    this.recover,
    this.restHost,
    int? suspendedRetryTimeout,
    bool? tls,
    this.tlsPort,
    this.transportParams,
    TokenDetails? tokenDetails,
    bool? useBinaryProtocol,
    bool? useTokenAuth,
  }) : super(
          authCallback: authCallback,
          authUrl: authUrl,
          authMethod: authMethod,
          key: key,
          tokenDetails: tokenDetails,
          authHeaders: authHeaders,
          authParams: authParams,
          queryTime: queryTime,
          useTokenAuth: useTokenAuth,
        ) {
    /// BEGIN LEGACY DOCSTRING
    /// These default value assignments are only required until
    /// [ClientOptions.fromKey] is removed, because then defaults can be set
    /// directly in the constructor invocation
    /// END LEGACY DOCSTRING
    this.autoConnect = autoConnect ?? this.autoConnect;
    this.channelRetryTimeout = channelRetryTimeout ?? this.channelRetryTimeout;
    this.disconnectedRetryTimeout =
        disconnectedRetryTimeout ?? this.disconnectedRetryTimeout;
    this.echoMessages = echoMessages ?? this.echoMessages;
    this.fallbackRetryTimeout =
        fallbackRetryTimeout ?? this.fallbackRetryTimeout;
    this.httpMaxRetryCount = httpMaxRetryCount ?? this.httpMaxRetryCount;
    this.httpOpenTimeout = httpOpenTimeout ?? this.httpOpenTimeout;
    this.httpRequestTimeout = httpRequestTimeout ?? this.httpRequestTimeout;
    this.logLevel = logLevel ?? this.logLevel;
    this.queueMessages = queueMessages ?? this.queueMessages;
    this.suspendedRetryTimeout =
        suspendedRetryTimeout ?? this.suspendedRetryTimeout;
    this.tls = tls ?? this.tls;
    this.useBinaryProtocol = useBinaryProtocol ?? this.useBinaryProtocol;
  }

  /// BEGIN LEGACY DOCSTRING
  /// initializes [ClientOptions] with a key and log level set to info
  ///
  /// See [AuthOptions.fromKey] for more details
  /// END LEGACY DOCSTRING
  @Deprecated(
      "Use ClientOptions constructor with named 'key' parameter instead")
  ClientOptions.fromKey(String key) : super.fromKey(key);

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
