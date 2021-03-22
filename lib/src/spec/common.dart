import 'dart:async';

import 'package:flutter/services.dart';

import '../../ably_flutter.dart';
import '../impl/realtime/connection.dart';
import 'auth.dart';
import 'enums.dart';
import 'spec.dart';

/// params to configure encryption for a channel
///
/// https://docs.ably.io/client-lib-development-guide/features/#TZ1
abstract class CipherParams {
  /// Specifies the algorithm to use for encryption
  ///
  /// Default is AES. Currently only AES is supported.
  /// https://docs.ably.io/client-lib-development-guide/features/#TZ2a
  String algorithm;

  /// private key used to encrypt and decrypt payloads
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TZ2d
  dynamic key;

  /// the length in bits of the key
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TZ2b
  int keyLength;

  /// Specify cipher mode
  ///
  /// Default is CBC. Currently only CBC is supported
  /// https://docs.ably.io/client-lib-development-guide/features/#TZ2c
  String mode;
}

/// An [AblyException] encapsulates [ErrorInfo] which carries details
/// about information related to Ably-specific error [code],
/// generic [statusCode], error [message],
/// link to error related documentation as [href],
/// [requestId] and [cause] of this exception
///
/// https://docs.ably.io/client-lib-development-guide/features/#TI1
class ErrorInfo {
  /// ably specific error code
  final int code;

  /// link to error related documentation as
  final String href;

  /// error message
  final String message;

  /// cause for the error
  final ErrorInfo cause;

  /// generic status code
  final int statusCode;

  /// request id which triggered this exception
  final String requestId;

  /// instantiates a [ErrorInfo] with provided values
  ErrorInfo({
    this.code,
    this.href,
    this.message,
    this.cause,
    this.statusCode,
    this.requestId,
  });

  @override
  String toString() => 'ErrorInfo'
      ' message=$message'
      ' code=$code'
      ' statusCode=$statusCode'
      ' href=$href';
}

/// MessageCount contains aggregate counts for messages and data transferred
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS5
abstract class StatsMessageCount {
  /// Count of all messages.
  int count;

  /// Total data transferred for all messages in bytes.
  int data;
}

/// MessageTypes contains a breakdown of summary stats data
/// for different (message vs presence) message types
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS6
abstract class StatsMessageTypes {
  /// All messages count (includes both presence & messages).
  StatsMessageCount all;

  /// Count of channel messages.
  StatsMessageCount messages;

  /// Count of presence messages.
  StatsMessageCount presence;
}

/// RequestCount contains aggregate counts for requests made
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS8
abstract class StatsRequestCount {
  /// Requests failed.
  int failed;

  /// Requests refused typically as a result of permissions
  /// or a limit being exceeded.
  int refused;

  /// Requests succeeded.
  int succeeded;
}

/// ResourceCount contains aggregate data for usage of a resource
/// in a specific scope
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS9
abstract class StatsResourceCount {
  /// Average resources of this type used for this period.
  int mean;

  /// Minimum total resources of this type used for this period.
  int min;

  /// Total resources of this type opened.
  int opened;

  /// Peak resources of this type used for this period.
  int peak;

  /// Resource requests refused within this period.
  int refused;
}

/// ConnectionTypes contains a breakdown of summary stats data
/// for different (TLS vs non-TLS) connection types
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS4
abstract class StatsConnectionTypes {
  /// All connection count (includes both TLS & non-TLS connections).
  StatsResourceCount all;

  /// Non-TLS connection count (unencrypted).
  StatsResourceCount plain;

  /// TLS connection count.
  StatsResourceCount tls;
}

/// MessageTraffic contains a breakdown of summary stats data
/// for traffic over various transport types
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS7
abstract class StatsMessageTraffic {
  /// All messages count (includes realtime, rest and webhook messages).
  StatsMessageTypes all;

  /// Count of messages transferred over a realtime transport
  /// such as WebSockets.
  StatsMessageTypes realtime;

  /// Count of messages transferred using REST.
  StatsMessageTypes rest;

  /// Count of messages delivered using WebHooks.
  StatsMessageTypes webhook;
}

/// A class providing parameters of a token request.
///
/// Parameters for a token request
///
/// [Auth.authorize], [Auth.requestToken] and [Auth.createTokenRequest]
/// accept an instance of TokenParams as a parameter
///
/// https://docs.ably.io/client-lib-development-guide/features/#TK1
class TokenParams {
  /// Capability of the token.
  ///
  /// If the token request is successful, the capability of the
  /// returned token will be the intersection of this [capability]
  /// with the capability of the issuing key.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TK2b
  String capability;

  /// A clientId to associate with this token.
  ///
  /// The generated token may be used to authenticate as this clientId.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TK2c
  String clientId;

  /// An opaque nonce string of at least 16 characters to ensure uniqueness.
  ///
  /// Timestamps, in conjunction with the nonce,
  /// are used to prevent requests from being replayed
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TK2d
  String nonce;

  /// The timestamp (in millis since the epoch) of this request.
  ///
  ///	Timestamps, in conjunction with the nonce, are used to prevent
  ///	token requests from being replayed.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TK2d
  DateTime timestamp;

  /// Requested time to live for the token.
  ///
  /// If the token request is successful, the TTL of the returned
  /// token will be less than or equal to this value depending on
  /// application settings and the attributes of the issuing key.
  ///
  /// 0 means Ably will set it to the default value
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TK2a
  int ttl;

  /// instantiates a [TokenParams] with provided values
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
/// https://docs.ably.io/client-lib-development-guide/features/#TD1
class TokenDetails {
  /// https://docs.ably.io/client-lib-development-guide/features/#TD2
  String token;

  /// Token expiry time in milliseconds
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TD3
  int expires;

  /// the time the token was issued in milliseconds
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TD4
  int issued;

  /// stringified capabilities JSON
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TD5
  String capability;

  /// Client ID assigned to the token.
  ///
  /// If [clientId] is not set (i.e. null), then the token is prohibited
  /// from assuming a clientId in any operations, however if clientId
  /// is a wildcard string '*', then the token is permitted to assume
  /// any clientId. Any other string value for clientId implies that the
  /// clientId is both enforced and assumed for all operations for this token
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TD6
  String clientId;

  /// instantiates a [TokenDetails] with provided values
  TokenDetails(
    this.token, {
    this.expires,
    this.issued,
    this.capability,
    this.clientId,
  });

  /// Creates an instance from the map
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TD7
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
  /// https://docs.ably.io/client-lib-development-guide/features/#TE3
  String capability;

  ///  Client ID assigned to the tokenRequest.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TE2
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

  /// instantiates a [TokenRequest] with provided values
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

  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  RestHistoryParams({
    DateTime start,
    DateTime end,
    this.direction = 'backwards',
    this.limit = 100,
  })  : assert(direction == 'backwards' || direction == 'forwards'),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0),
        end = end ?? DateTime.now();

  @override
  String toString() => 'RestHistoryParams:'
      ' start=$start'
      ' end=$end'
      ' direction=$direction'
      ' limit=$limit';
}

/// https://docs.ably.io/client-lib-development-guide/features/#RTL10
class RealtimeHistoryParams extends RestHistoryParams {
  /// Decides whether to retrieve messages from earlier session.
  ///
  /// if true, will only retrieve messages prior to the moment that the channel
  /// was attached or emitted an UPDATE indicating loss of continuity.
  bool untilAttach;

  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  RealtimeHistoryParams({
    DateTime start,
    DateTime end,
    String direction = 'backwards',
    int limit = 100,
    this.untilAttach,
  }) : super(
          start: start,
          end: end,
          direction: direction,
          limit: limit,
        );
}

/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSP3a
class RestPresenceParams {
  /// number of records to fetch per page
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSP3a1
  int limit;

  /// filters members by the provided clientId
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSP3a2
  String clientId;

  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSP3a3
  String connectionId;

  /// initializes with default [limit] set to 100
  RestPresenceParams({
    this.limit = 100,
    this.clientId,
    this.connectionId,
  });
}

/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.io/client-lib-development-guide/features/#RTP11c
class RealtimePresenceParams {
  /// When true, [RealtimePresence.get] will wait until SYNC is complete
  /// before returning a list of members
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTP11c1
  bool waitForSync;

  /// filters members by the provided clientId
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTP11c2
  String clientId;

  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTP11c3
  String connectionId;

  /// initializes with [waitForSync] set to true by default
  RealtimePresenceParams({
    this.waitForSync = true,
    this.clientId,
    this.connectionId,
  });
}

/// An exception generated by the native client library called by this plugin
class AblyException implements Exception {
  /// platform error code
  ///
  /// Mostly used for storing [PlatformException.code]
  final String code;

  /// platform error message
  ///
  /// Mostly used for storing [PlatformException.message]
  final String message;

  /// error message from ably native sdk
  final ErrorInfo errorInfo;

  /// initializes with no defaults
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

/// Whenever the channel state changes, a ChannelStateChange object
/// is emitted on the Channel object
///
/// https://docs.ably.io/client-lib-development-guide/features/#TH1
class ChannelStateChange {
  /// the event that generated the channel state change
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TH5
  final ChannelEvent event;

  /// current state of the channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TH2
  final ChannelState current;

  /// previous state of the channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TH2
  final ChannelState previous;

  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TH3
  ErrorInfo reason;

  /// https://docs.ably.io/client-lib-development-guide/features/#TH4
  final bool resumed;

  /// initializes with [resumed] set to false
  ChannelStateChange(
    this.current,
    this.previous,
    this.event, {
    this.reason,
    this.resumed = false,
  });
}

/// Whenever the connection state changes,
/// a ConnectionStateChange object is emitted on the [Connection] object
///
/// https://docs.ably.io/client-lib-development-guide/features/#TA1
class ConnectionStateChange {
  /// https://docs.ably.io/client-lib-development-guide/features/#TA2
  final ConnectionEvent event;

  /// current state of the channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TA2
  final ConnectionState current;

  /// previous state of the channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TA2
  final ConnectionState previous;

  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TA3
  ErrorInfo reason;

  /// when the client is not connected, a connection attempt will be made
  /// automatically by the library after the number of milliseconds
  /// specified by [retryIn]
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TA2
  int retryIn;

  /// initializes without any defaults
  ConnectionStateChange(
    this.current,
    this.previous,
    this.event, {
    this.reason,
    this.retryIn,
  });
}

/// Details of the push registration for a given device
///
/// https://docs.ably.io/client-lib-development-guide/features/#PCP1
abstract class DevicePushDetails {
  /// A map of string key/value pairs containing details of the push transport
  /// and address.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCP3
  Map<String, String> recipient;

  /// The state of the push registration.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCP4
  DevicePushState state;

  /// Any error information associated with the registration.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCP2
  ErrorInfo errorReason;
}

/// Details of a registered device.
///
/// https://docs.ably.io/client-lib-development-guide/features/#PCD1
abstract class DeviceDetails {
  /// The id of the device registration.
  ///
  /// Generated locally if not available
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD2
  String id;

  /// populated for device registrations associated with a clientId (optional)
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD3
  String clientId;

  /// The device platform.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD6
  DevicePlatform platform;

  /// the device form factor.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD4
  FormFactor formFactor;

  /// a map of string key/value pairs containing any other registered
  /// metadata associated with the device registration
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD5
  Map<String, String> metadata;

  /// Device token. Generated locally, if not available.
  String deviceSecret;

  /// Details of the push registration for this device.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCD7
  DevicePushDetails push;
}

/// Details of a push subscription to a channel.
///
/// https://docs.ably.io/client-lib-development-guide/features/#PCS1
abstract class PushChannelSubscription {
  /// the channel name associated with this subscription
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCS4
  String channel;

  /// populated for subscriptions made for a specific device registration
  /// (optional)
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCS2
  String deviceId;

  /// populated for subscriptions made for a specific clientId (optional)
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#PCS3
  String clientId;
}

/// Params to filter push device registrations.
///
/// see: [PushDeviceRegistrations.list], [PushDeviceRegistrations.removeWhere]
/// https://docs.ably.io/client-lib-development-guide/features/#RSH1b2
abstract class DeviceRegistrationParams {
  /// filter by client id
  String clientId;

  /// filter by device id
  String deviceId;

  /// limit results for each page
  int limit;

  /// filter by device state
  DevicePushState state;
}

/// Params to filter push channel subscriptions.
///
/// See [PushChannelSubscriptions.list], [PushChannelSubscriptions.removeWhere]
/// https://docs.ably.io/client-lib-development-guide/features/#RSH1c1
abstract class PushChannelSubscriptionParams {
  /// filter by channel
  String channel;

  /// filter by clientId
  String clientId;

  /// filter by deviceId
  String deviceId;

  /// limit results for each page
  int limit;
}

/// params to filter channels on a [PushChannelSubscriptions]
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSH1c2
abstract class PushChannelsParams {
  /// limit results for each page
  int limit;
}

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
/// [G] is the instance which will be passed back in streams.
///
///
/// There is no `off` API as in other Ably client libraries as on returns a
/// [Stream] which can be subscribed for, and that subscription can be cancelled
/// using [StreamSubscription.cancel] API
abstract class EventEmitter<E, G> {
  /// Create a listener, with which registrations may be made.
  Stream<G> on([E event]);
}

/// PaginatedResult [TG1](https://docs.ably.io/client-lib-development-guide/features/#TG1)
///
/// A type that represents page results from a paginated query.
/// The response is accompanied by metadata that indicates the
/// relative queries available.
abstract class PaginatedResultInterface<T> {
  /// items contain page of results
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TG3
  List<T> get items;

  /// returns a new PaginatedResult loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.io/client-lib-development-guide/features/#TG4
  Future<PaginatedResultInterface<T>> next();

  /// returns a new PaginatedResult with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.io/client-lib-development-guide/features/#TG5
  Future<PaginatedResultInterface<T>> first();

  /// returns true if there are further pages
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TG6
  bool hasNext();

  /// returns true if this page is the last page
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TG7
  bool isLast();
}

/// The response from an HTTP request containing an empty or
/// JSON-encodable object response
///
/// [T] can be a [Map] or [List]
///
/// https://docs.ably.io/client-lib-development-guide/features/#HP1
abstract class HttpPaginatedResponse<T> extends PaginatedResultInterface<T> {
  /// HTTP status code for the response
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#HP4
  int statusCode;

  /// indicates whether the request is successful
  ///
  /// true when 200 <= [statusCode] < 300
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#HP5
  bool success;

  /// Value from X-Ably-Errorcode HTTP header, if available in response
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#HP6
  int errorCode;

  /// Value from X-Ably-Errormessage HTTP header, if available in response
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#HP7
  String errorMessage;

  /// Array of key value pairs of each response header
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#HP8
  List<Map<String, String>> headers;

  /// returns a new HttpPaginatedResponse loaded with the next page of results.
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.io/client-lib-development-guide/features/#HP2
  @override
  Future<HttpPaginatedResponse<T>> next();

  /// returns a new HttpPaginatedResponse with the first page of results
  ///
  /// If there are no further pages, then null is returned.
  /// https://docs.ably.io/client-lib-development-guide/features/#HP2
  @override
  Future<HttpPaginatedResponse<T>> first();
}

/// A class representing an individual statistic for a specified [intervalId]
///
/// https://docs.ably.io/client-lib-development-guide/features/#TS1
class Stats {
  /// Aggregates inbound and outbound messages.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12e
  StatsMessageTypes all;

  /// Breakdown of API requests received via the REST API.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12e
  StatsRequestCount apiRequests;

  /// Breakdown of channels stats.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12e
  StatsResourceCount channels;

  /// Breakdown of connection stats data for different (TLS vs non-TLS)
  /// connection types.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12i
  StatsConnectionTypes connections;

  /// All inbound messages i.e.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12f
  StatsMessageTraffic inbound;

  /// The interval that this statistic applies to,
  /// see GRANULARITY and INTERVAL_FORMAT_STRING.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12a
  String intervalId;

  /// All outbound messages i.e.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12g
  StatsMessageTraffic outbound;

  /// Messages persisted for later retrieval via the history API.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12h
  StatsMessageTypes persisted;

  /// Breakdown of Token requests received via the REST API.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TS12l
  StatsRequestCount tokenRequests;
}

/// A collection of Channel objects accessible
/// through [Rest.channels] or [Realtime.channels]
abstract class Channels<ChannelType> {
  /// stores channel name vs instance of [ChannelType]
  final _channels = <String, ChannelType>{};

  /// creates a channel with provided name and options
  ChannelType createChannel(String name, ChannelOptions options);

  /// returns all channels
  Iterable<ChannelType> get all => _channels.values;

  /// creates a channel with [name].
  ///
  /// Doesn't create a channel instance on platform side yet.
  ChannelType get(String name) {
    //TODO add ChannelOptions as optional argument here,
    // and pass it on to createChannel
    if (_channels[name] == null) {
      _channels[name] = createChannel(name, null);
    }
    return _channels[name];
  }

  /// returns true if a channel exists [name]
  bool exists(String name) => _channels[name] != null;

  /// releases channel with [name]
  void release(String name) {
    throw UnimplementedError();
  }
}
