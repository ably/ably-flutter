import 'package:flutter/foundation.dart';


//==============================================================================
//===============================    ENUM's    =================================
//==============================================================================
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


//==============================================================================
//==========================    ABSTRACT CLASSES    ============================
//==============================================================================
abstract class CipherParams {
  String algorithm;
  dynamic key;
  int keyLength;
  String mode;
}

abstract class ErrorInfo {
  int code;
  String message;
  int statusCode;
}

abstract class StatsMessageCount {
  int count;
  int data;
}

abstract class StatsMessageTypes {
  StatsMessageCount all;
  StatsMessageCount messages;
  StatsMessageCount presence;
}

abstract class StatsRequestCount {
  int failed;
  int refused;
  int succeeded;
}

abstract class StatsResourceCount {
  int mean;
  int min;
  int opened;
  int peak;
  int refused;
}

abstract class StatsConnectionTypes {
  StatsResourceCount all;
  StatsResourceCount plain;
  StatsResourceCount tls;
}

abstract class StatsMessageTraffic {
  StatsMessageTypes all;
  StatsMessageTypes realtime;
  StatsMessageTypes rest;
  StatsMessageTypes webhook;
}

abstract class TokenParams {
  String  capability;   //See below -v-
  Map<String, List<capabilityOp>> capabilityMap;	//?: { [key: String]: capabilityOp[]; } | String;
  String clientId;
  String nonce;
  int timestamp;
  int ttl;
}

abstract class TokenDetails {
  String capability;
  String clientId;
  int expires;
  int issued;
  String token;
}

abstract class TokenRequest {
  String capability;
  String clientId;
  String keyName;
  String mac;
  String nonce;
  int timestamp;
  int ttl;
}

abstract class ChannelOptions {
  dynamic cipher;
}

abstract class RestHistoryParams {
  int start;
  int end;
  String direction;
  int limit;
}

abstract class RestPresenceParams {
  int limit;
  String clientId;
  String connectionId;
}

abstract class RealtimePresenceParams {
  bool waitForSync; //waitForSync;	//?: bool;
  String clientId; //clientId;	//?: String;
  String connectionId; //;	//?: String;
}

abstract class RealtimeHistoryParams {
  int start; //  start;	//?: int;
  int end; //  end;	//?: int;
  int direction; //  direction;	//?: String;
  int limit; //  limit;	//?: int;
  bool untilAttach; //  untilAttach;	//?: bool;
}

typedef void LogHandler(String msg);
abstract class LogInfo {
  ///A int controlling the verbosity of the output.
  ///Valid values are: 0 (no logs), 1 (errors only),
  ///2 (errors plus connection and channel state changes), 3 (high-level debug output), and 4 (full debug output).
  LogLevel level;  //level?: int;

  /// A function to handle each line of log output. If handler is not specified, console.log is used.
  LogHandler handler; //handler?: (msg: String) => void;
}

abstract class ChannelStateChange {
  ChannelState current;
  ChannelState previous;
  ErrorInfo reason; //optional
  bool resumed;
}

abstract class ConnectionStateChange {
  ConnectionState current;
  ConnectionState previous;
  ErrorInfo reason; //optional
  int retryIn;      //optional
}

abstract class DevicePushDetails {
  dynamic recipient;
  DevicePushState state;  //optional
  ErrorInfo errorReason;  //optional
}

abstract class DeviceDetails {
  String id;
  String clientId;  //optional
  DevicePlatform platform;
  FormFactor formFactor;
  dynamic metadata; //optional
  String deviceSecret;  //optional
  DevicePushDetails push; //optional
}

abstract class PushChannelSubscription {
  String channel;
  String deviceId;  //optional
  String clientId;  //optional
}

abstract class DeviceRegistrationParams {
  String clientId;  //optional
  String deviceId;  //optional
  int limit;  //optional
  DevicePushState state;  //optional
}

abstract class PushChannelSubscriptionParams {
  String channel;  //optional
  String clientId;  //optional
  String deviceId;  //optional
  int limit;    //optional
}

abstract class PushChannelsParams {
  int limit;    //optional
}

// Interfaces
typedef void AuthOptionsAuthCallbackCallback({
  ErrorInfo errorInfo,
  String error, //TODO one of error or errorInfo are required
  TokenDetails tokenDetails,
  TokenRequest tokenRequest,
  String token  //TODO one of tokenDetails, tokenRequest or token are required
});
typedef void AuthOptionsAuthCallback(TokenParams data, AuthOptionsAuthCallbackCallback callback);
abstract class AuthOptions {

  ///A function which is called when a new token is required.
  ///The role of the callback is to either generate a signed TokenRequest which may then be submitted automatically
  ///by the library to the Ably REST API requestToken; or to provide a valid token in as a TokenDetails object.
  AuthOptionsAuthCallback authCallback;
  Map<String, String> authHeaders;	//?: { [index: String]: String };
  HTTPMethods authMethod;	//optional
  Map<String, String> authParams;	//?: { [index: String]: String };


  ///A URL that the library may use to obtain a token String (in plain text format), or a signed TokenRequest or TokenDetails (in JSON format).

  String authUrl;	//optional
  String key;	//optional
  bool queryTime;	//optional
  TokenDetails token;	//?: TokenDetails | String;
  String tokenString; //TODO see above line ^

  TokenDetails tokenDetails;	//optional
  bool useTokenAuth;	//optional

  ///Optional clientId that can be used to specify the identity for this client. In most cases
  ///it is preferable to instead specift a clientId in the token issued to this client.
  String clientId;	//optional
}


abstract class ClientOptions extends AuthOptions {

  ///When true will automatically connect to Ably when library is instanced. This is true by default
  bool autoConnect;	//optional

  TokenParams defaultTokenParams; //optional

  ///When true, messages published on channels by this client will be echoed back to this client.
  ///This is true by default
  bool echoMessages;  //optional;

  ///Use this only if you have been provided a dedicated environment by Ably
  String environment;	//optional

  ///Logger configuration
  LogInfo log;	//optional
  int port;	//optional

  ///When true, messages will be queued whilst the connection is disconnected. True by default.
  bool queueMessages;	//optional

  String restHost;	//optional
  String realtimeHost;	//optional
  String fallbackHosts;	//optional
  bool fallbackHostsUseDefault;	//optional

  ///Can be used to explicitly recover a connection.
  ///See https://www.ably.io/documentation/realtime/connection#connection-state-recovery
  standardCallback recover;	//?: standardCallback | String;
  String recoverString; //TODO refer to above line ^

  ///Use a non-secure connection connection. By default, a TLS connection is used to connect to Ably
  bool tls;	//optional
  int tlsPort;	//optional

  /// When true, the more efficient MsgPack binary encoding is used.
  /// When false, JSON text encoding is used.
  bool useBinaryProtocol;	//?: bool;

  int disconnectedRetryTimeout;	//?: int;
  int suspendedRetryTimeout;	//?: int;
  bool closeOnUnload;	//?: bool;
  bool idempotentRestPublishing;	//?: bool;
  Map<String, String> transportParams;	//?: {[k: String]: String};
  List<Transport> transports;	//?: Transport[];
}


// Common Listeners
typedef void paginatedResultCallback<T>(ErrorInfo error, PaginatedResult<T> results);
typedef void standardCallback(ErrorInfo error, dynamic results);
typedef void messageCallback<T>(T message);
typedef void errorCallback(ErrorInfo error);
typedef void channelEventCallback(ChannelStateChange channelStateChange);

typedef void connectionEventCallback(ConnectionStateChange connectionStateChange);
typedef void timeCallback(ErrorInfo error, int time);
typedef void realtimePresenceGetCallback(ErrorInfo error, List<PresenceMessage> messages);
typedef void tokenDetailsCallback(ErrorInfo error, TokenDetails results);
typedef void tokenRequestCallback(ErrorInfo error, TokenRequest results);
typedef void FromEncoded<T>(dynamic jsonObject, ChannelOptions channelOptions);
typedef void FromEncodedArray<T>(dynamic jsonArray, ChannelOptions channelOptions);
typedef void StringVoidCallback(String str);
typedef Future<int> DelayedIntCallback();
typedef Future DelayedVoidCallback();



// Internal Classes

class Event{
//  TODO define attributes here
}

typedef void EventOnType<EventType, CallbackType>({
  Event event, List<EventType> eventType,
  @required CallbackType callback
  //  (eventOrCallback: Event| EventType[] | CallbackType, CallbackType callback): void
});
typedef Future<ResultType> EventOnceType<EventType, CallbackType, ResultType>({
  EventType event,
  @required CallbackType callback
});
typedef void EventOffType<EventType, CallbackType>({
  EventType event,
  @required CallbackType callback
});
typedef List<CallbackType> EventListenersType<EventType, CallbackType>({
  EventType eventName
});


class EventEmitter<CallbackType, ResultType, EventType, StateType> {
  EventOnType<EventType, CallbackType> on;
  EventOnceType<EventType, CallbackType, ResultType> once;
  EventOffType<EventType, CallbackType> off;
  EventListenersType<EventType, CallbackType> listeners;
}

// Classes
typedef Future<PushChannelSubscription> OnPushChannelSubscriptionSave(PushChannelSubscription subscription);
typedef Future<PaginatedResult<PushChannelSubscription>> OnPushChannelSubscriptionList(PushChannelsParams params);
typedef Future<PaginatedResult<String>> OnPushChannelSubscriptionListChannels(PushChannelsParams params);
typedef Future<void> OnPushChannelSubscriptionRemove(PushChannelsParams params);
typedef Future<void> OnPushChannelSubscriptionRemoveWhere(PushChannelSubscriptionParams params);

class PushChannelSubscriptionsPromise {
  OnPushChannelSubscriptionSave save; //: (subscription: PushChannelSubscription) => Future<PushChannelSubscription>;
  OnPushChannelSubscriptionList list; //: (params: PushChannelSubscriptionParams) => Future<PaginatedResult<PushChannelSubscription>>;
  OnPushChannelSubscriptionListChannels listChannels; //: (params: PushChannelsParams) => Future<PaginatedResult<String>>;
  OnPushChannelSubscriptionRemove remove;  //: (subscription: PushChannelSubscription) => Future<void>;
  OnPushChannelSubscriptionRemoveWhere removeWhere; //: (params: PushChannelSubscriptionParams) => Future<void>;
}

typedef Future<DeviceDetails> PushDeviceRegistrationsSave(DeviceDetails deviceDetails);
typedef Future<DeviceDetails> PushDeviceRegistrationsGet({
  DeviceDetails deviceDetails, String deviceId
});
typedef Future<PaginatedResult<DeviceDetails>> PushDeviceRegistrationsList(DeviceRegistrationParams params);
typedef Future<void> PushDeviceRegistrationsRemove({
  DeviceDetails deviceDetails, String deviceId
});
typedef Future<void> PushDeviceRegistrationsRemoveWhere(DeviceRegistrationParams params);
class PushDeviceRegistrationsPromise {
  PushDeviceRegistrationsSave save;
  PushDeviceRegistrationsGet get;
  PushDeviceRegistrationsList list;
  PushDeviceRegistrationsRemove remove;
  PushDeviceRegistrationsRemoveWhere removeWhere;
}

typedef Future<void> PushAdminPublishCallback(dynamic recipient, dynamic payload);
class PushAdminPromise {
  PushDeviceRegistrationsPromise deviceRegistrations;
  PushChannelSubscriptionsPromise channelSubscriptions;
  PushAdminPublishCallback publish; //: (recipient: dynamic, payload: dynamic) => Future<void>;
}

class PushPromise {
  PushAdminPromise admin;
}

class Stats {
  StatsMessageTypes all;
  StatsRequestCount apiRequests;
  StatsResourceCount channels;
  StatsConnectionTypes connections;
  StatsMessageTraffic inbound;
  String intervalId;
  StatsMessageTraffic outbound;
  StatsMessageTypes persisted;
  StatsRequestCount tokenRequests;
}

typedef Future<PaginatedResult<T>> PaginatedResultFirst<T>({paginatedResultCallback<T> results});
typedef Future<PaginatedResult<T>> PaginatedResultNext<T>({paginatedResultCallback<T> results});
typedef Future<PaginatedResult<T>> PaginatedResultCurrent<T>({paginatedResultCallback<T> results});
typedef bool PaginatedResultBoolCallback();
class PaginatedResult<T> {
  List<T> items;
  PaginatedResultFirst<T> first;
  PaginatedResultNext<T> next;
  PaginatedResultCurrent<T> current;
  PaginatedResultBoolCallback hasNext;
  PaginatedResultBoolCallback isLast;
}

class HttpPaginatedResponse extends PaginatedResult<String> {
  List<String> items; // TODO resolve below signature match to this definiton
  // class HttpPaginatedResponse extends PaginatedResult<dynamic> {
  //    items: String[];
  //    .....
  int statusCode;
  bool success;
  int errorCode;
  String errorMessage;
  dynamic headers;  //TODO change to Map<String, dynamic> ??
}

abstract class PresenceMessageStatic {
  FromEncoded<PresenceMessage> fromEncoded;
  FromEncodedArray<PresenceMessage> fromEncodedArray;
}

typedef void CryptoGenerateRandomKeyCallback(ErrorInfo error, String key);
typedef void CryptoGenerateRandomKey(CryptoGenerateRandomKeyCallback callback);
abstract class Crypto {
  CryptoGenerateRandomKey generateRandomKey;
}


class ConnectionBase extends EventEmitter<connectionEventCallback, ConnectionStateChange, ConnectionEvent, ConnectionState> {
  ErrorInfo errorReason;
  String id;
  String key;
  String recoveryKey;
  int serial;
  ConnectionState state;
  VoidCallback close;
  VoidCallback connect;
}


typedef Future<ConnectionStateChange> ConnectionPromiseWhenState(ConnectionState targetState);
class ConnectionPromise extends ConnectionBase {
  DelayedIntCallback ping;
  ConnectionPromiseWhenState whenState;
}


//REST BASE
typedef Future<HttpPaginatedResponse> RestRequest({
  @required String method,
  @required String path,
  Map params, //TODO decide if this needs to be a map
  dynamic body, //?: dynamic[] | dynamic,
  Map headers //TODO decide if this needs to be a map?: dynamic
});
typedef Future<PaginatedResult<Stats>> StatsResultSetFromParams([Map params]);  //params?: dynamic

abstract class RestBase {
  constructor({
    ClientOptions options, String StringOptions //options: ClientOptions | String
  });
  static Crypto crypto;
  static MessageStatic message;
  static PresenceMessageStatic presenceMessage;
}

class Rest implements RestBase { //TODO check if this should be abstract!
  constructor({
    ClientOptions options, String StringOptions //options: ClientOptions | String
  }){
    // TODO
  }
  static Rest rest; //todo factory?
  Auth auth;
  Channels<Channel> channels;
  RestRequest request;
  StatsResultSetFromParams stats;
  DelayedIntCallback time;
  PushPromise push;
}

abstract class RealtimeBase extends RestBase {
  static Realtime realtime; //todo factory?
  String clientId;
  VoidCallback close;
  VoidCallback connect;
}

class Realtime extends RealtimeBase {
  constructor({
    ClientOptions options, String StringOptions //options: ClientOptions | String
  }){
    // TODO
  }
  Auth auth;
  Channels<RealtimeChannel> channels;
  ConnectionPromise connection;
  RestRequest request;
  StatsResultSetFromParams stats;
  DelayedIntCallback time;
  PushPromise push;
}

class AuthBase {
  String clientId;
}

typedef Future<TokenDetails> TokenDetailsAuthFuture({
  TokenParams tokenParams,
  AuthOptions authOptions
});
typedef Future<TokenRequest> TokenRequestAuthFuture({
  TokenParams tokenParams,
  AuthOptions authOptions
});
class Auth extends AuthBase {
  TokenDetailsAuthFuture authorize;
  TokenRequestAuthFuture createTokenRequest;
  TokenDetailsAuthFuture requestToken;
}

typedef Future<PaginatedResult<PresenceMessage>> PresenceGet([RestPresenceParams params]);
typedef Future<PaginatedResult<PresenceMessage>> PresenceHistory([RestHistoryParams params]);
class Presence {
  PresenceGet get;
  PresenceHistory history;
}

typedef void RealtimePresenceUnSubscribe({
  PresenceAction action,
  List<PresenceAction> actions,
  messageCallback<PresenceMessage> listener
});
class RealtimePresenceBase {
  bool syncComplete;
  RealtimePresenceUnSubscribe unsubscribe;
}

typedef Future<List<PresenceMessage>> RealtimePresenceGet([RealtimePresenceParams params]);
typedef Future<PaginatedResult<PresenceMessage>> RealtimePresenceHistory([RealtimeHistoryParams params]);
typedef Future<void> RealtimePresenceSubscribe({
  PresenceAction action,
  List<PresenceAction> actions,
  messageCallback<PresenceMessage> listener
});
typedef Future<void> DelayedDynamicDataVoidCallback([dynamic data]);
typedef Future<void> DelayedDynamicClientDataVoidCallback({
  String clientId,
  dynamic data
});
class RealtimePresence extends RealtimePresenceBase {
  RealtimePresenceGet get;
  RealtimePresenceHistory history;
  RealtimePresenceSubscribe subscribe;
  DelayedDynamicDataVoidCallback enter;
  DelayedDynamicDataVoidCallback update;
  DelayedDynamicDataVoidCallback leave;
  DelayedDynamicClientDataVoidCallback enterClient;
  DelayedDynamicClientDataVoidCallback updateClient;
  DelayedDynamicClientDataVoidCallback leaveClient;
}

class ChannelBase {
  String name;
}

typedef Future<PaginatedResult<Message>> ChannelHistory([RestHistoryParams params]);
typedef Future<void> ChannelPublish({String name, dynamic messageData});
class Channel extends ChannelBase {
  Presence presence;
  ChannelHistory history;
  ChannelPublish publish;
}

typedef void RealtimeChannelBaseSetOptions(dynamic options);  //TODO check if to be set as Map
typedef void RealtimeChannelBaseUnsubscribe({
  String event,
  List<String> events,
  messageCallback<Message> listener
});
class RealtimeChannelBase extends EventEmitter<channelEventCallback, ChannelStateChange, ChannelEvent, ChannelState> {
  String name;
  ErrorInfo errorReason;
  ChannelState state;
  RealtimeChannelBaseSetOptions setOptions;
  RealtimeChannelBaseUnsubscribe unsubscribe;
}

typedef Future<PaginatedResult<Message>> RealtimeChannelHistory([RealtimeHistoryParams params]);
typedef Future<void> RealtimeChannelSubscribe({
  String event,
  List<String> events,
  messageCallback<Message> listener
});
typedef Future<ChannelStateChange> RealtimeChannelWhenState(ChannelState targetState);
class RealtimeChannel extends RealtimeChannelBase {
  RealtimePresence presence;
  DelayedVoidCallback attach;
  DelayedVoidCallback detach;
  RealtimeChannelHistory history;
  RealtimeChannelSubscribe subscribe;
  ChannelPublish publish;
  RealtimeChannelWhenState whenState;
}

typedef T ChannelsGet<T>(String name, [ChannelOptions channelOptions]);
typedef void ChannelsRelease(String name);
class Channels<T> {
  ChannelsGet<T> get;
  StringVoidCallback release;
}

class Message {
  static FromEncoded<Message> fromEncoded;
  static FromEncodedArray<Message> fromEncodedArray;
  String clientId;
  String connectionId;
  dynamic data;
  dynamic encoding;
  dynamic extras;
  String id;
  String name;
  int timestamp;
}

abstract class MessageStatic {
  FromEncoded<Message> fromEncoded;
  FromEncodedArray<Message> fromEncodedArray;
}

class PresenceMessage {
  static FromEncoded<PresenceMessage> fromEncoded;
  static FromEncodedArray<PresenceMessage> fromEncodedArray;
  PresenceAction action;
  String clientId;
  String connectionId;
  dynamic data;
  String encoding;
  String id;
  int timestamp;
}
