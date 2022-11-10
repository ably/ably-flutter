import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains an individual message that is sent to, or received from, Ably.
/// END EDITED CANONICAL DOCSTRING
@immutable
class Message with ObjectHash {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A Unique ID assigned by Ably to this message.
  /// END EDITED CANONICAL DOCSTRING
  final String? id;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Timestamp of when the message was received by Ably, as [DateTime].
  /// END EDITED CANONICAL DOCSTRING
  final DateTime? timestamp;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The client ID of the publisher of this message.
  /// END EDITED CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The connection ID of the publisher of this message.
  /// END EDITED CANONICAL DOCSTRING
  final String? connectionId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// This is typically empty, as all messages received from Ably are
  /// automatically decoded client-side using this value. However, if the
  /// message encoding cannot be processed, this attribute contains the
  /// remaining transformations not applied to the `data` payload.
  /// END EDITED CANONICAL DOCSTRING
  final String? encoding;

  final MessageData<dynamic>? _data;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The message payload, if provided.
  /// END EDITED CANONICAL DOCSTRING
  Object? get data => _data?.data;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The event name.
  /// END EDITED CANONICAL DOCSTRING
  final String? name;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An object that may contain metadata, and/or ancillary payloads.
  /// END EDITED CANONICAL DOCSTRING
  final MessageExtras? extras;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Construct a Message object with an event [name], [data] payload, and a unique
  /// [clientId].
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A static factory method to create a [Message] object from a deserialized
  /// Message-like object encoded using Ably's wire protocol, with a provided
  /// Message-like deserialized [jsonObject] and optionally a [channelOptions]
  /// object, which you can use to allow the library to decrypt the
  /// data if you have an encrypted channel.
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A static factory method to create an array of Message objects from an
  /// [jsonArray] of deserialized Message-like object encoded using Ably's wire
  /// protocol, and optionally a [channelOptions] object, which you can use to
  /// allow the library to decrypt the data if you have an encrypted channel.
  /// END EDITED CANONICAL DOCSTRING
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
