import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// Contains an individual message that is sent to, or received from, Ably.
@immutable
class Message with ObjectHash {
  /// A Unique ID assigned by Ably to this message.
  final String? id;

  /// Timestamp of when the message was received by Ably, as [DateTime].
  final DateTime? timestamp;

  /// The client ID of the publisher of this message.
  final String? clientId;

  /// The connection ID of the publisher of this message.
  final String? connectionId;

  /// This is typically empty, as all messages received from Ably are
  /// automatically decoded client-side using this value. However, if the
  /// message encoding cannot be processed, this attribute contains the
  /// remaining transformations not applied to the `data` payload.
  final String? encoding;

  final MessageData<dynamic>? _data;

  /// The message payload, if provided.
  Object? get data => _data?.data;

  /// The event name.
  final String? name;

  /// An object that may contain metadata, and/or ancillary payloads.
  final MessageExtras? extras;

  /// Construct a Message object with an event [name], [data] payload, and a
  /// unique [clientId].
  Message({
    this.clientId,
    this.connectionId,
    Object? data,
    this.encoding,
    this.extras,
    this.id,
    this.name,
    this.timestamp,
  }) : _data = MessageData.fromValue(data);

  @override
  bool operator ==(Object other) =>
      other is Message &&
      other.clientId == clientId &&
      other.connectionId == connectionId &&
      other.data == data &&
      other.encoding == encoding &&
      other.extras == extras &&
      other.id == id &&
      other.name == name &&
      other.timestamp == timestamp;

  @override
  int get hashCode => objectHash([
        id,
        name,
        encoding,
        clientId,
        timestamp,
        connectionId,
        data,
        extras,
      ]);

  // https://docs.ably.com/client-lib-development-guide/features/#TM3
  //
  // TODO(tiholic): decoding and decryption is not implemented as per
  // RSL6 and RLS6b as mentioned in TM3

  /// A static factory method to create a [Message] object from a deserialized
  /// Message-like object encoded using Ably's wire protocol, with a provided
  /// Message-like deserialized [jsonObject] and optionally a [channelOptions]
  /// object, which you can use to allow the library to decrypt the
  /// data if you have an encrypted channel.
  Message.fromEncoded(
    Map<String, dynamic> jsonObject, [
    RestChannelOptions? channelOptions,
  ])  : clientId = jsonObject['clientId'] as String?,
        connectionId = jsonObject['connectionId'] as String?,
        _data = MessageData.fromValue(jsonObject['data']),
        encoding = jsonObject['encoding'] as String?,
        extras = MessageExtras.fromMap(
          Map.castFrom<dynamic, dynamic, String, dynamic>(
            jsonObject['extras'] as Map,
          ),
        ),
        id = jsonObject['id'] as String?,
        name = jsonObject['name'] as String?,
        timestamp = jsonObject['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                jsonObject['timestamp'] as int,
              )
            : null;

  /// A static factory method to create an array of Message objects from an
  /// [jsonArray] of deserialized Message-like object encoded using Ably's wire
  /// protocol, and optionally a [channelOptions] object, which you can use to
  /// allow the library to decrypt the data if you have an encrypted channel.
  static List<Message> fromEncodedArray(
    List<Map<String, dynamic>> jsonArray, [
    RestChannelOptions? channelOptions,
  ]) =>
      jsonArray.map((e) => Message.fromEncoded(e, channelOptions)).toList();

  @override
  String toString() => 'Message'
      ' id=$id'
      ' name=$name'
      ' data=$data'
      ' extras=$extras'
      ' encoding=$encoding'
      ' clientId=$clientId'
      ' timestamp=$timestamp'
      ' connectionId=$connectionId';

// TODO(tiholic) add support for fromEncoded and fromEncodedArray (TM3)
}
