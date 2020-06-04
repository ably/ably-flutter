import 'package:ably_flutter_plugin/ably.dart';

import '../enums.dart';
import '../common.dart';


/// Function-type alias implemented by a function that provides either tokens,
/// or signed token requests, in response to a request with given token params.
///
/// Java: io.ably.lib.rest.Auth.TokenCallback.getTokenRequest(TokenParams)
/// returns either [TokenDetails] or [TokenRequest]
typedef dynamic AuthCallback(TokenParams params);
abstract class AuthOptions {

  AuthOptions();

  /// Convenience constructor, to create an AuthOptions based
  /// on the key string obtained from the application dashboard.
  /// param [key]: the full key string as obtained from the dashboard
  AuthOptions.fromKey(String key){
    assert(key!=null);
    if (key.contains(':')) {
      this.key = key;
    } else {
      this.tokenDetails = TokenDetails(key);
    }
  }

  ///A function which is called when a new token is required.
  ///The role of the callback is to either generate
  /// a signed TokenRequest which may then be submitted automatically
  ///by the library to the Ably REST API requestToken;
  /// or to provide a valid token in as a TokenDetails object.
  AuthCallback authCallback;

  ///A URL that the library may use to obtain a
  /// token String (in plain text format),
  /// or a signed TokenRequest or TokenDetails (in JSON format).
  String authUrl;	//optional
  HTTPMethods authMethod;	//optional
  String key;	//optional

  TokenDetails tokenDetails;	//optional

  Map<String, String> authHeaders;	//optional
  Map<String, String> authParams;	//optional

  bool queryTime;	//optional
  bool useTokenAuth;	//optional
}

typedef void LogHandler({String msg, AblyException exception});
class ClientOptions extends AuthOptions {

  ClientOptions(){
    logLevel = LogLevel.info;
  }

  ClientOptions.fromKey(String key): super.fromKey(key){
    logLevel = LogLevel.info;
  }

  ///Optional clientId that can be used to specify the identity for this client.
  /// In most cases it is preferable to instead specific a clientId in the token
  /// issued to this client.
  String clientId;	//optional

  ///Logger configuration
  LogHandler logHandler;  //optional
  int logLevel;  //optional

  String restHost;	//optional
  String realtimeHost;	//optional
  int port;	//optional

  ///Use a non-secure connection connection. By default,
  /// a TLS connection is used to connect to Ably
  bool tls;	//optional
  int tlsPort;	//optional

  ///When true will automatically connect to Ably when library is instanced.
  /// This is true by default
  bool autoConnect;	//optional

  /// When true, the more efficient MsgPack binary encoding is used.
  /// When false, JSON text encoding is used.
  bool useBinaryProtocol;	//optional

  ///When true, messages will be queued whilst the connection is disconnected.
  /// True by default.
  bool queueMessages;	//optional

  ///When true, messages published on channels by this client will be
  /// echoed back to this client. This is true by default
  bool echoMessages;  //optional;

  ///Can be used to explicitly recover a connection.
  ///See https://www.ably.io/documentation/realtime/connection#connection-state-recovery
  String recover;

  ///Use this only if you have been provided a dedicated environment by Ably
  String environment;	//optional

  // Fallbacks
  List<String> fallbackHosts;	//optional
  bool fallbackHostsUseDefault;	//optional

  TokenParams defaultTokenParams; //optional

  int disconnectedRetryTimeout;	//optional
  int suspendedRetryTimeout;	//optional
  bool idempotentRestPublishing;	//optional
  Map<String, String> transportParams;	//optional

  int httpOpenTimeout;
  int httpRequestTimeout;

  int httpMaxRetryCount;
  int realtimeRequestTimeout;
  int fallbackRetryTimeout;
  int channelRetryTimeout;
}