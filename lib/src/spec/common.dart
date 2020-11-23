import 'auth.dart';
import 'enums.dart';
import 'rest/ably_base.dart';
import 'spec.dart';

//==============================================================================
//==========================    ABSTRACT CLASSES    ============================
//==============================================================================
abstract class CipherParams {
  String algorithm;
  dynamic key;
  int keyLength;
  String mode;
}

///An [AblyException] encapsulates [ErrorInfo] which carries details
///about information related to Ably-specific error [code],
/// generic [statusCode], error [message],
/// link to error related documentation as [href],
/// [requestId] and [cause] of this exception
class ErrorInfo {
  final int code;
  final String href;
  final String message;
  final ErrorInfo cause;
  final int statusCode;
  final String requestId;

  ErrorInfo(
      {this.code,
      this.href,
      this.message,
      this.cause,
      this.statusCode,
      this.requestId});

  @override
  String toString() => 'ErrorInfo message=$message code=$code '
      'statusCode=$statusCode href=$href';
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

/// A class providing parameters of a token request.
///
/// Parameters for a token request
///
/// [Auth.authorize], [Auth.requestToken] and [Auth.createTokenRequest]
/// accept an instance of TokenParams as a parameter
///
/// spec: https://docs.ably.io/client-lib-development-guide/features/#TK1
class TokenParams {
  /// Capability of the token.
  ///
  /// If the token request is successful, the capability of the
  /// returned token will be the intersection of this [capability]
  /// with the capability of the issuing key.
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TK2b
  String capability;

  /// A clientId to associate with this token.
  ///
  /// The generated token may be used to authenticate as this clientId.
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TK2c
  String clientId;

  /// An opaque nonce string of at least 16 characters to ensure uniqueness.
  ///
  /// Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TK2d
  String nonce;

  /// The timestamp (in millis since the epoch) of this request.
  ///
  ///	Timestamps, in conjunction with the nonce, are used to prevent
  ///	token requests from being replayed.
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TK2d
  DateTime timestamp;

  /// Requested time to live for the token.
  ///
  /// If the token request is successful, the TTL of the returned
  /// token will be less than or equal to this value depending on
  /// application settings and the attributes of the issuing key.
  ///
  /// 0 means Ably will set it to the default value
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TK2a
  int ttl;

  TokenParams({
    this.capability,
    this.clientId,
    this.nonce,
    this.timestamp,
    this.ttl,
  });
}

/// Response to a `requestToken` request
///
/// spec: https://docs.ably.io/client-lib-development-guide/features/#TD1
class TokenDetails {
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TD2
  String token;

  /// Token expiry time in milliseconds
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TD3
  int expires;

  /// the time the token was issued in milliseconds
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TD4
  int issued;

  /// stringified capabilities JSON
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TD5
  String capability;

  /// Client ID assigned to the token.
  ///
  /// If [clientId] is not set (i.e. null), then the token is prohibited
  /// from assuming a clientId in any operations, however if clientId
  /// is a wildcard string '*', then the token is permitted to assume
  /// any clientId. Any other string value for clientId implies that the
  /// clientId is both enforced and assumed for all operations for this token
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TD6
  String clientId;

  TokenDetails(
    this.token, {
    this.expires,
    this.issued,
    this.capability,
    this.clientId,
  });

  /// TD7
  TokenDetails.fromMap(Map<String, dynamic> map) {
    token = map['token'] as String;
    expires = map['expires'] as int;
    issued = map['issued'] as int;
    capability = map['capability'] as String;
    clientId = map['clientId'] as String;
  }
}

/// spec: https://docs.ably.io/client-lib-development-guide/features/#TE1
class TokenRequest {
  /// [keyName] is the first part of Ably API Key.
  ///
  /// provided keyName will be used to authorize requests made to Ably.
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE2
  ///
  /// More details about Ably API Key:
  /// https://docs.ably.io/client-lib-development-guide/features/#RSA11
  String keyName;

  /// An opaque nonce string of at least 16 characters to ensure
  ///	uniqueness of this request. Any subsequent request using the
  ///	same nonce will be rejected.
  ///
  /// spec:
  /// https://docs.ably.io/client-lib-development-guide/features/#TE2
  /// https://docs.ably.io/client-lib-development-guide/features/#TE5
  String nonce;

  /// The "Message Authentication Code" for this request.
  ///
  /// See the Ably Authentication documentation for more details.
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE2
  String mac;

  /// stringified capabilities JSON
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE3
  String capability;

  /// TE2
  String clientId;

  /// timestamp long – The timestamp (in milliseconds since the epoch)
  /// of this request. Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE5
  DateTime timestamp;

  /// ttl attribute represents time to live (expiry)
  /// of this token in milliseconds
  ///
  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE4
  int ttl;

  TokenRequest({
    this.keyName,
    this.nonce,
    this.clientId,
    this.mac,
    this.capability,
    this.timestamp,
    this.ttl,
  });

  /// spec: https://docs.ably.io/client-lib-development-guide/features/#TE7
  TokenRequest.fromMap(Map<String, dynamic> map) {
    keyName = map['keyName'] as String;
    nonce = map['nonce'] as String;
    mac = map['mac'] as String;
    capability = map['capability'] as String;
    clientId = map['clientId'] as String;
    timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
    ttl = map['ttl'] as int;
  }
}

/// Params for rest history
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSL2b
class RestHistoryParams {
  /// [start] must be equal to or less than end and is unaffected
  /// by the request direction
  ///
  /// RLS2b1
  final DateTime start;

  /// [end] must be equal to or greater than start and is unaffected
  /// by the request direction
  ///
  /// RLS2b1
  final DateTime end;

  /// Sorting history backwards or forwards
  ///
  /// if omitted the direction defaults to the REST API default (backwards)
  /// RLS2b2
  final String direction;

  /// Number of items returned in one page
  ///
  /// [limit] supports up to 1,000 items.
  /// if omitted the direction defaults to the REST API default (100)
  /// RLS2b3
  final int limit;

  RestHistoryParams({
    DateTime start,
    DateTime end,
    this.direction = 'backwards',
    this.limit = 100,
  })  : assert(direction == 'backwards' || direction == 'forwards'),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0),
        end = end ?? DateTime.now();
}

/// https://docs.ably.io/client-lib-development-guide/features/#RTL10
class RealtimeHistoryParams extends RestHistoryParams {
  /// Decides whether to retrieve messages from earlier session.
  ///
  /// if true, will only retrieve messages prior to the moment that the channel
  /// was attached or emitted an UPDATE indicating loss of continuity.
  bool untilAttach;

  RealtimeHistoryParams({
    DateTime start,
    DateTime end,
    String direction,
    int limit,
    this.untilAttach,
  }) : super(
          start: start,
          end: end,
          direction: direction,
          limit: limit,
        );
}

class RestPresenceParams {
  int limit;
  String clientId;
  String connectionId;

  RestPresenceParams({
    this.limit,
    this.clientId,
    this.connectionId,
  });
}

class RealtimePresenceParams {
  bool waitForSync;
  String clientId;
  String connectionId;

  RealtimePresenceParams({
    this.waitForSync,
    this.clientId,
    this.connectionId,
  });
}

/// An exception generated by the client library SDK called by this plugin.
class AblyException implements Exception {
  final String code;
  final String message;
  final ErrorInfo errorInfo;

  AblyException([
    this.code,
    this.message,
    this.errorInfo,
  ]);

  @override
  String toString() {
    if (message == null) {
      return 'AblyException (${(code == null) ? "" : '$code '})';
    }
    return 'AblyException: $message (${(code == null) ? "" : '$code '})';
  }
}

class ChannelStateChange {
  final ChannelEvent event;
  final ChannelState current;
  final ChannelState previous;
  ErrorInfo reason;
  final bool resumed;

  ChannelStateChange(
    this.current,
    this.previous,
    this.event, {
    this.reason,
    this.resumed = false,
  });
}

class ConnectionStateChange {
  final ConnectionEvent event;
  final ConnectionState current;
  final ConnectionState previous;
  ErrorInfo reason;
  int retryIn;

  ConnectionStateChange(
    this.current,
    this.previous,
    this.event, {
    this.reason,
    this.retryIn,
  });
}

abstract class DevicePushDetails {
  dynamic recipient;
  DevicePushState state; //optional
  ErrorInfo errorReason; //optional
}

abstract class DeviceDetails {
  String id;
  String clientId; //optional
  DevicePlatform platform;
  FormFactor formFactor;
  dynamic metadata; //optional
  String deviceSecret; //optional
  DevicePushDetails push; //optional
}

abstract class PushChannelSubscription {
  String channel;
  String deviceId; //optional
  String clientId; //optional
}

abstract class DeviceRegistrationParams {
  String clientId; //optional
  String deviceId; //optional
  int limit; //optional
  DevicePushState state; //optional
}

abstract class PushChannelSubscriptionParams {
  String channel; //optional
  String clientId; //optional
  String deviceId; //optional
  int limit; //optional
}

abstract class PushChannelsParams {
  int limit; //optional
}

// Internal Classes
/// Interface implemented by event listeners, returned by event emitters.
abstract class EventListener<E> {
  /// Register for all events (no parameter), or a specific event.
  Stream<E> on([E event]);

  /// Register for a single occurrence of any event (no parameter),
  /// or a specific event.
  Future<E> once([E event]);

  /// Remove registrations for this listener, irrespective of type.
  Future<void> off();
}

/// Interface implemented by Ably classes that can emit events,
/// offering the capability to create listeners for those events.
/// [E] is type of event to listen for
/// [G] is the instance which will be passed back in streams
abstract class EventEmitter<E, G> {
  // Remove all listener registrations, irrespective of type.
  // Future<void> off();

  /// Create a listener, with which registrations may be made.
  Stream<G> on([E event]);
}

/// PaginatedResult [TG1](https://docs.ably.io/client-lib-development-guide/features/#TG1)
///
/// A type that represents page results from a paginated query.
/// The response is accompanied by metadata that indicates the
/// relative queries available.
abstract class PaginatedResultInterface<T> {
  /// items contain page of results (TG3)
  List<T> get items;

  /// returns a new PaginatedResult loaded with the next page of results. (TG4)
  ///
  /// If there are no further pages, then null is returned
  Future<PaginatedResultInterface<T>> next();

  /// returns a new PaginatedResult for the first page of results (TG5)
  Future<PaginatedResultInterface<T>> first();

  /// returns true if there are further pages (TG6)
  bool hasNext();

  /// returns true if this page is the last page (TG7)
  bool isLast();
}

abstract class HttpPaginatedResponse extends PaginatedResultInterface<String> {
  int statusCode;
  bool success;
  int errorCode;
  String errorMessage;
  Map<String, String> headers;
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

abstract class Channels<ChannelType> {
  Channels(this.ably);

  AblyBase ably;
  final _channels = <String, ChannelType>{};

  ChannelType createChannel(String name, ChannelOptions options);

  Iterable<ChannelType> get all => _channels.values;

  ChannelType get(String name) {
    //TODO add ChannelOptions as optional argument here,
    // and pass it on to createChannel
    if (_channels[name] == null) {
      _channels[name] = createChannel(name, null);
    }
    return _channels[name];
  }

  bool exists(String name) => _channels[name] != null;

  Iterable<ChannelType> iterate() => _channels.values;

  void release(String str) {
    throw UnimplementedError();
  }
}
