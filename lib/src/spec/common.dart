import 'enums.dart';
import 'rest/ably_base.dart';

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

  ErrorInfo({
    this.code, this.href, this.message,
    this.cause, this.statusCode, this.requestId
  });

  @override
  String toString() {
    return 'ErrorInfo message=$message code=$code statusCode=$statusCode href=$href';
  }

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

class TokenParams {
  String  capability;
  String clientId;
  String nonce;
  DateTime timestamp;
  int ttl;
}

/// TokenDetails is a type containing the token request
/// response from the REST requestToken endpoint
///
/// spec: https://docs.ably.io/client-lib-development-guide/features/#TD1
class TokenDetails {
  TokenDetails(this.token);
  String capability;

  /// clientId assigned to the token. If clientId is not set (i.e. null),
  /// then the token is prohibited from assuming a clientId in any operations,
  /// however if clientId is a wildcard string '*', then the token is
  /// permitted to assume any clientId. Any other string value for clientId
  /// implies that the clientId is both enforced and assumed
  /// for all operations for this token
  ///
  /// TD6
  String clientId;

  TokenDetails(this.token, {
    this.expires,
    this.issued,
    this.capability,
    this.clientId
  });

  /// TD7
  TokenDetails.fromMap(Map<String, dynamic> map){
    this.token = map['token'] as String;
    this.expires = map['expires'] as int;
    this.issued = map['issued'] as int;
    this.capability = map['capability'] as String;
    this.clientId = map['clientId'] as String;
  }

}

/// TokenRequest is a type containing the token request
/// details sent to the REST requestToken endpoint
///
/// spec: https://docs.ably.io/client-lib-development-guide/features/#TE1
class TokenRequest {

  /// The keyName of the key against which this request is made.
  ///
  /// TE2
  String keyName;

  /// An opaque nonce string of at least 16 characters to ensure
  ///	uniqueness of this request. Any subsequent request using the
  ///	same nonce will be rejected.
  ///
  /// TE2, TE5
  String nonce;

  /// The Message Authentication Code for this request. See the Ably
  ///	Authentication documentation for more details.
  ///
  /// TE2
  String mac;

  /// stringified capabilities JSON
  ///
  /// TE3
  String capability;

  /// TE2
  String clientId;

  /// timestamp long – The timestamp (in milliseconds since the epoch)
  /// of this request. Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// TE5
  DateTime timestamp;

  /// ttl attribute represents time to live (expiry)
  /// of this token in milliseconds
  ///
  /// TE4
  int ttl;

  TokenRequest({
    this.keyName,
    this.nonce,
    this.clientId,
    this.mac,
    this.capability,
    this.timestamp,
    this.ttl
  });

  /// TE7
  TokenRequest.fromMap(Map<String, dynamic> map){
    this.keyName = map["keyName"] as String;
    this.nonce = map["nonce"] as String;
    this.mac = map["mac"] as String;
    this.capability = map["capability"] as String;
    this.clientId = map["clientId"] as String;
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(map["timestamp"] as int);
    this.ttl = map["ttl"] as int;
  }

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

class RealtimePresenceParams {
  bool waitForSync;
  String clientId;
  String connectionId;
  RealtimePresenceParams({this.waitForSync, this.clientId, this.connectionId});
}

class RealtimeHistoryParams {
  int start; //  start;	//?: int;
  int end; //  end;	//?: int;
  int direction; //  direction;	//?: String;
  int limit; //  limit;	//?: int;
  bool untilAttach; //  untilAttach;	//?: bool;
  RealtimeHistoryParams({this.start, this.end, this.direction, this.limit, this.untilAttach});
}


/// An exception generated by the client library SDK called by this plugin.
class AblyException implements Exception {

  final String code;
  final String message;
  final ErrorInfo errorInfo;

  AblyException([this.code, this.message, this.errorInfo]);

  String toString() {
    if (message == null) return "AblyException";
    return "AblyException: $message (${(code==null)?"":'$code '})";
  }

}

class ChannelStateChange {
  final ChannelEvent event;
  final ChannelState current;
  final ChannelState previous;
  ErrorInfo reason;
  final bool resumed;
  ChannelStateChange(this.current, this.previous, this.event, {
    this.reason,
    this.resumed=false
  });
}

class ConnectionStateChange {
  final ConnectionEvent event;
  final ConnectionState current;
  final ConnectionState previous;
  ErrorInfo reason;
  int retryIn;
  ConnectionStateChange(this.current, this.previous, this.event, {
    this.reason,
    this.retryIn
  });
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


// Internal Classes
/// Interface implemented by event listeners, returned by event emitters.
abstract class EventListener<E> {
  /// Register for all events (no parameter), or a specific event.
  Stream<E> on([E event]);

  /// Register for a single occurrence of any event (no parameter), or a specific event.
  Future<E> once([E event]);

  /// Remove registrations for this listener, irrespective of type.
  Future<void> off();
}

/// Interface implemented by Ably classes that can emit events, offering the capability
/// to create listeners for those events.
/// [E] is type of event to listen for
/// [G] is the instance which will be passed back in streams
abstract class EventEmitter<E, G> {

  // Remove all listener registrations, irrespective of type.
  // Future<void> off();

  /// Create a listener, with which registrations may be made.
  Stream<G> on([E event]);
}

abstract class PaginatedResult<T> {
  List<T> items();
  Future<PaginatedResult<T>> first();
  Future<PaginatedResult<T>> next();
  Future<PaginatedResult<T>> current();
  bool hasNext();
  bool isLast();
}

abstract class HttpPaginatedResponse extends PaginatedResult<String> {
  List<String> items();
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
  Map<String, ChannelType> _channels = {};

  ChannelType createChannel(name, options);

  ChannelType get(String name) {  //TODO add ChannelOptions as optional argument here, and pass it on to createChannel
    if (_channels[name]==null) {
      _channels[name] = createChannel(name, null);
    }
    return _channels[name];
  }

  bool exists(String name){
    return _channels[name] != null;
  }

  Iterable<ChannelType> iterate(){
    return _channels.values;
  }

  void release(String str) {
    // TODO: implement release
  }

}
