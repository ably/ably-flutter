import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// Contains an individual presence update sent to, or received from, Ably.
@immutable
class PresenceMessage with ObjectHash {
  /// A unique ID assigned to each `PresenceMessage` by Ably.
  final String? id;

  /// The type of [PresenceAction] the `PresenceMessage` is for.
  final PresenceAction? action;

  /// The ID of the client that published the `PresenceMessage`.
  final String? clientId;

  /// The ID of the connection associated with the client that published the
  /// `PresenceMessage`.
  final String? connectionId;

  final MessageData<dynamic>? _data;

  /// The payload of the `PresenceMessage`.
  Object? get data => _data?.data;

  /// This will typically be empty as all presence messages received from Ably
  /// are automatically decoded client-side using this value.
  ///
  /// However, if the message encoding cannot be processed, this attribute will
  /// contain the remaining transformations not applied to the data payload.
  final String? encoding;

  /// An object that may contain metadata and/or ancillary payloads.
  final MessageExtras? extras;

  /// The [DateTime] the PresenceMessage was received by Ably.
  final DateTime? timestamp;

  /// Combines `clientId` and `connectionId` to ensure that multiple connected
  /// clients with an identical `clientId` are uniquely identifiable. A string
  /// function that returns the combined `clientId` and `connectionId`.
  String get memberKey => '$connectionId:$clientId';

  /// @nodoc
  /// Constructs a [PresenceMessage] object.
  PresenceMessage({
    this.action,
    this.clientId,
    this.connectionId,
    Object? data,
    this.encoding,
    this.extras,
    this.id,
    this.timestamp,
  }) : _data = MessageData.fromValue(data);

  @override
  bool operator ==(Object other) =>
      other is PresenceMessage &&
      other.action == action &&
      other.clientId == clientId &&
      other.connectionId == connectionId &&
      other.data == data &&
      other.encoding == encoding &&
      other.extras == extras &&
      other.id == id &&
      other.timestamp == timestamp;

  @override
  int get hashCode => objectHash([
        id,
        encoding,
        clientId,
        timestamp,
        connectionId,
        data,
        action,
        extras,
      ]);

  // https://docs.ably.com/client-lib-development-guide/features/#TP4
  //
  // TODO(tiholic): decoding and decryption is not implemented as per
  //  RSL6 and RLS6b as mentioned in TP4

  /// Decodes and decrypts a deserialized PresenceMessage-like [jsonObject]
  /// using the cipher in [channelOptions].
  ///
  /// Any residual transforms that cannot be decoded or decrypted will be in the
  /// encoding property. Intended for users receiving messages from a source
  /// other than a REST or Realtime channel (for example a queue) to avoid
  /// having to parse the encoding string.
  PresenceMessage.fromEncoded(
    Map<String, dynamic> jsonObject, [
    RestChannelOptions? channelOptions,
  ])  : id = jsonObject['id'] as String?,
        action = PresenceAction.values.firstWhere((e) =>
            e.toString().split('.')[1] == jsonObject['action'] as String?),
        clientId = jsonObject['clientId'] as String?,
        connectionId = jsonObject['connectionId'] as String?,
        _data = MessageData.fromValue(jsonObject['data']),
        encoding = jsonObject['encoding'] as String?,
        extras = MessageExtras.fromMap(
          Map.castFrom<dynamic, dynamic, String, dynamic>(
            jsonObject['extras'] as Map,
          ),
        ),
        timestamp = jsonObject['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                jsonObject['timestamp'] as int,
              )
            : null;

  /// Decodes and decrypts a [jsonArray] of deserialized PresenceMessage-like
  /// object using the cipher in [channelOptions].
  ///
  /// Any residual transforms that cannot be decoded or decrypted will be in the
  /// encoding property. Intended for users receiving messages from a source
  /// other than a REST or Realtime channel (for example a queue) to avoid
  /// having to parse the encoding string.
  static List<PresenceMessage> fromEncodedArray(
    List<Map<String, dynamic>> jsonArray, [
    RestChannelOptions? channelOptions,
  ]) =>
      jsonArray
          .map((jsonObject) => PresenceMessage.fromEncoded(
                jsonObject,
                channelOptions,
              ))
          .toList();

  @override
  String toString() => 'PresenceMessage'
      ' id=$id'
      ' data=$data'
      ' action=$action'
      ' extras=$extras'
      ' encoding=$encoding'
      ' clientId=$clientId'
      ' timestamp=$timestamp'
      ' connectionId=$connectionId';
}
