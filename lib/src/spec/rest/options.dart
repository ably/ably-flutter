import '../../../ably_flutter.dart';
import '../common.dart';

/// Function-type alias implemented by a function that provides either tokens,
/// or signed token requests, in response to a request with given token params.
///
/// Java: io.ably.lib.rest.Auth.TokenCallback.getTokenRequest(TokenParams)
/// returns either a [String] token or [TokenDetails] or [TokenRequest]
typedef AuthCallback = Future<dynamic> Function(TokenParams params);

/// A class providing configurable authentication options used when
/// authenticating or issuing tokens explicitly.
///
/// These options are used when invoking Auth#authorize, Auth#requestToken,
/// Auth#createTokenRequest and Auth#authorize.
///
/// https://docs.ably.io/client-lib-development-guide/features/#AO1
abstract class AuthOptions {
  /// initializes an instance without any defaults
  AuthOptions();

  /// Convenience constructor, to create an AuthOptions based
  /// on the key string obtained from the application dashboard.
  /// param [key]: the full key string as obtained from the dashboard
  AuthOptions.fromKey(String key) : assert(key != null) {
    if (key.contains(':')) {
      this.key = key;
    } else {
      tokenDetails = TokenDetails(key);
    }
  }

  /// A function which is called when a new token is required.
  ///
  /// The role of the callback is to either generate a signed [TokenRequest]
  /// which may then be submitted automatically by the library to
  /// the Ably REST API requestToken; or to provide a valid token
  /// as a [TokenDetails] object.
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2b
  AuthCallback authCallback;

  /// A URL that the library may use to obtain
  /// a token String (in plain text format),
  /// or a signed [TokenRequest] or [TokenDetails] (in JSON format).
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2c
  String authUrl;

  /// HTTP Method used when a request is made using authURL
  ///
  /// defaults to 'GET', supports 'GET' and 'POST'
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2d
  String authMethod;

  /// Full Ably key string, as obtained from dashboard,
  /// used when signing token requests locally
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2a
  String key;

  /// An authentication token issued for this application
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2i
  TokenDetails tokenDetails;

  /// Headers to be included in any request made to the [authUrl]
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2e
  Map<String, String> authHeaders;

  /// Additional params to be included in any request made to the [authUrl]
  ///
  /// As query params in the case of GET
  /// and as form-encoded in the body in the case of POST
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2f
  Map<String, String> authParams;

  /// If true, the library will when issuing a token request query
  /// the Ably system for the current time instead of relying on a
  /// locally-available time of day.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#AO2g
  bool queryTime;

  /// Token Auth is used if useTokenAuth is set to true
  ///
  /// or if useTokenAuth is unspecified and any one of
  /// [authUrl], [authCallback], token, or [TokenDetails] is provided
  /// https://docs.ably.io/client-lib-development-guide/features/#RSA4
  bool useTokenAuth;

// TODO(tiholic) missing token attribute here
//  see: https://docs.ably.io/client-lib-development-guide/features/#AO2h
}

/// Custom handler to handle SDK log messages
///
/// https://docs.ably.io/client-lib-development-guide/features/#TO3c
typedef LogHandler = void Function({
  String msg,
  AblyException exception,
});

/// Ably library options used when instancing a REST or Realtime client library
///
/// https://docs.ably.io/client-lib-development-guide/features/#TO1
class ClientOptions extends AuthOptions {
  /// initializes [ClientOptions] with log level set to info
  ClientOptions() {
    logLevel = LogLevel.info;
  }

  /// initializes [ClientOptions] with a key and log level set to info
  ///
  /// See [AuthOptions.fromKey] for more details
  ClientOptions.fromKey(String key) : super.fromKey(key) {
    logLevel = LogLevel.info;
  }

  /// Optional clientId that can be used to specify the identity for this client
  ///
  /// In most cases it is preferable to instead specific a clientId in the token
  /// issued to this client.
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3a
  String clientId;

  /// Custom log handler
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3c
  LogHandler logHandler;

  /// Controls the level of verbosity of log messages from the library
  ///
  /// Use constants from [LogLevel] to pass arguments
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3b
  int logLevel;

  /// for development environments only
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k2
  String restHost;

  /// for development environments only
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k3
  String realtimeHost;

  /// for development environments only
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k4
  int port;

  /// Use a non-secure connection connection.
  ///
  /// By default, a TLS connection is used to connect to Ably
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3d
  bool tls;

  /// for development environments only
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k5
  int tlsPort;

  /// When true will automatically connect to Ably when library is instanced.
  ///
  /// This is true by default. If false, will wait for an explicit
  /// [ConnectionInterface]#connect to be called before connecting
  /// https://docs.ably.io/client-lib-development-guide/features/#RTC1b
  bool autoConnect;

  /// Decides whether to use MsgPack binary encoding or JSON encoding.
  ///
  /// Defaults to true. If false, JSON encoding is used for REST and Realtime
  /// operations, instead of the default binary msgpack encoding.
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3f
  bool useBinaryProtocol;

  /// When true, messages will be queued whilst the connection is disconnected.
  ///
  /// True by default.
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3g
  bool queueMessages;

  /// When true, messages published on channels by this client will be
  /// echoed back to this client.
  ///
  /// This is true by default.
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3h
  bool echoMessages;

  /// Can be used to explicitly recover a connection.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3i
  /// Also see https://www.ably.io/documentation/realtime/connection#connection-state-recovery
  String recover;

  /// for development environments only
  ///
  /// Use this only if you have been provided a dedicated environment by Ably
  String environment;

  /// for development environments only
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k6
  List<String> fallbackHosts;

  /// for development environments only;
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3k7
  @Deprecated('no alternative to this')
  bool fallbackHostsUseDefault;

  /// When a TokenParams object is provided, it will override
  /// the client library defaults described in TokenParams
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3j11
  TokenParams defaultTokenParams;

  /// When the connection enters the [ConnectionState.disconnected] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.disconnected], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 15,000 (15 seconds)
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l1
  int disconnectedRetryTimeout;

  /// When the connection enters the [ConnectionState.suspended] state,
  /// after this delay in milliseconds, if the state is still
  /// [ConnectionState.suspended], the client library will
  /// attempt to reconnect automatically
  ///
  /// default 30,000 (30 seconds)
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l2
  int suspendedRetryTimeout;

  /// https://docs.ably.io/client-lib-development-guide/features/#TO3n
  bool idempotentRestPublishing;

  /// Additional parameters to be sent in the querystring when initiating
  /// a realtime connection
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTC1f
  Map<String, String> transportParams;

  /// Timeout for opening the connection, available in the client library
  /// if supported by the transport
  ///
  /// default 4,000 (4s)
  /// https://docs.ably.io/client-lib-development-guide/features/#RTC1f
  int httpOpenTimeout;

  /// Timeout for any single HTTP request and response
  ///
  /// default 10,000 (10s)
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l4
  int httpRequestTimeout;

  /// Max number of fallback hosts to use as a fallback when an HTTP request
  /// to the primary host is unreachable or indicates that it is unserviceable
  ///
  /// default 3
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l5
  int httpMaxRetryCount;

  /// When a realtime client library is establishing a connection with Ably,
  /// or sending a HEARTBEAT, CONNECT, ATTACH, DETACH or CLOSE ProtocolMessage
  /// to Ably, this is the amount of time that the client library will wait
  /// before considering that request as failed and triggering a suitable
  /// failure condition
  ///
  /// default 10s
  /// https://docs.ably.io/client-lib-development-guide/features/#DF1b
  int realtimeRequestTimeout;

  /// After a failed request to the default endpoint,
  /// followed by a successful request to a fallback endpoint,
  /// the period in milliseconds before HTTP requests are retried
  /// against the default endpoint
  ///
  /// default 600000 (10 minutes)
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l10
  int fallbackRetryTimeout;

  /// When a channel becomes [ChannelState.suspended] following a server
  /// initiated [ChannelState.detached], after this delay in milliseconds,
  /// if the channel is still [ChannelState.suspended] and the connection
  /// is [ConnectionState.connected], the client library will attempt
  /// to re-attach the channel automatically
  ///
  /// default 15,000 (15s)
  /// https://docs.ably.io/client-lib-development-guide/features/#TO3l7
  int channelRetryTimeout;

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
