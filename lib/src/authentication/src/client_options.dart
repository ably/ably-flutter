import 'package:ably_flutter/ably_flutter.dart';

/// Passes additional client-specific properties to the REST
/// [Rest.new] or the Realtime [Realtime.new]
class ClientOptions extends AuthOptions {
  /// A client ID, used for identifying this client when publishing messages or
  /// for presence purposes.
  ///
  /// The `clientId` can be any non-empty string, except
  /// it cannot contain a `*`. This option is primarily intended to be used in
  /// situations where the library is instantiated with a key. Note that a
  /// `clientId` may also be implicit in a token used to instantiate the
  /// library. An error will be raised if a `clientId` specified here conflicts
  /// with the `clientId` implicit in the token.
  String? clientId;

  /// Controls the log output of the library. This is a function to handle each
  /// line of log output.
  @Deprecated(
    'Not used, as log messages are handled by the default mechanism '
    'in the underlying SDK. This instance variable will be removed '
    'in a future release.',
  )
  LogHandler? logHandler;

  /// Controls the verbosity of the logs output from the library. Levels include
  /// `verbose`, `debug`, `info`, `warn` and `error`.
  LogLevel logLevel = LogLevel.info;

  /// Enables a non-default Ably host to be specified. For development
  /// environments only.
  String? restHost;

  /// Enables a non-default Ably host to be specified for realtime connections.
  /// For development environments only.
  String? realtimeHost;

  /// Enables a non-default Ably port to be specified. For development
  /// environments only.
  int? port;

  /// Whether the client will use a secure connection. The default is
  /// `true`, meaning a TLS connection will be used to connect to Ably.
  bool tls = true;

  /// Enables a non-default Ably TLS port to be specified. For development
  /// environments only.
  int? tlsPort;

  /// Whether the client connects to Ably as soon as it is instantiated.
  /// You can set this to `false` and explicitly connect to Ably using the
  /// [Connection.connect] method. The default is `true`.
  bool autoConnect = true;

  /// Whether the more efficient MsgPack binary encoding is used. When `false`,
  /// JSON text encoding is used. The default is `true`.
  bool useBinaryProtocol = true;

  /// Whether the default behavior whereby the library queues messages on a
  /// connection in the disconnected or connecting states is used.
  ///
  /// The default behavior enables applications to submit messages immediately
  /// upon instantiating the library without having to wait for the connection
  /// to be established. Applications may use this option to disable queueing if
  /// they wish to have application-level control over the queueing. The default
  /// is `true`.
  bool queueMessages = true;

  /// Whether messages originating from this connection should be echoed back on
  /// the same connection. The default is `true`.
  bool echoMessages = true;

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
  String? recover;

  /// Enables a [custom environment](https://ably.com/docs/platform-customization)
  /// to be used with the Ably service.
  String? environment;

  /// A list of fallback hosts to be used in the case of an error necessitating
  /// the use of an alternative host.
  ///
  /// If you have been provided a set of custom fallback hosts by Ably, please
  /// specify them here.
  List<String>? fallbackHosts;

  /// DEPRECATED: this property is deprecated and will be removed in a future
  /// version. Enables default fallback hosts to be used.
  @Deprecated('no alternative to this')
  bool? fallbackHostsUseDefault;

  /// When a [TokenParams] object is provided, it overrides the client library
  /// defaults when issuing new Ably Tokens or Ably [TokenRequest]s.
  TokenParams? defaultTokenParams;

  /// If the connection is still in the [ConnectionState.disconnected] state
  /// after this delay, the client library will attempt to reconnect
  /// automatically. The default is 15000 miliseconds (15s).
  int disconnectedRetryTimeout = 15000;

  /// When the connection enters the [ConnectionState.suspended] state, after
  /// this delay, if the state is still [ConnectionState.suspended], the client
  /// library attempts to reconnect automatically. The default is 30000
  /// miliseconds (30s).
  int suspendedRetryTimeout = 30000;

  /// Whether idempotent publishing should be enabled.
  ///
  /// Assigning a unique message ID client-side allows the Ably servers to
  /// discard automatic publish retries following a failure such as a network
  /// fault.
  bool? idempotentRestPublishing;

  /// A set of key-value pairs that can be used to pass in arbitrary connection
  /// parameters, such as [heartbeatInterval](https://ably.com/docs/realtime/connection#heartbeats)
  /// or [remainPresentFor](https://ably.com/docs/realtime/presence#unstable-connections).
  Map<String, String>? transportParams;

  /// Timeout for opening a connection to Ably to initiate an HTTP request.
  /// The default is 4000 miliseconds (4s).
  int httpOpenTimeout = 4000;

  /// Timeout for a client performing a complete HTTP request to Ably,
  /// including the connection phase. The default is 10000 miliseconds (10s).
  int httpRequestTimeout = 10000;

  /// The maximum number of fallback hosts to use as a fallback when an HTTP
  /// request to the primary host is unreachable or indicates that it is
  /// unserviceable. The default value is 3.
  int httpMaxRetryCount = 3;

  /// Timeout for the wait of acknowledgement for operations performed via a
  /// realtime connection, before the client library considers a request failed
  /// and triggers a failure condition.
  ///
  /// Operations include establishing a connection with Ably, or sending a
  /// `HEARTBEAT`, `CONNECT`, `ATTACH`, `DETACH` or `CLOSE` request. It is the
  /// equivalent of `httpRequestTimeout` but for realtime operations, rather
  /// than REST.
  int? realtimeRequestTimeout;

  /// The maximum time before HTTP requests are retried against the default
  /// endpoint. The default is 600000 miliseconds (600s).
  int fallbackRetryTimeout = 600000;

  /// When a channel becomes [ChannelState.suspended] following a server
  /// initiated [ChannelState.detached], after this delay, if the channel is
  /// still [ChannelState.suspended] and the connection is
  /// [ConnectionState.connected], the client library will attempt to re-attach
  /// the channel automatically. The default is 15000 miliseconds (15s).
  int channelRetryTimeout = 15000;

  /// @nodoc
  /// Initializes an instance with defaults
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
    /// @nodoc
    /// These default value assignments are only required until
    /// [ClientOptions.fromKey] is removed, because then defaults can be set
    /// directly in the constructor invocation
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

  /// @nodoc
  /// initializes [ClientOptions] with a key and log level set to info
  ///
  /// See [AuthOptions.fromKey] for more details
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
