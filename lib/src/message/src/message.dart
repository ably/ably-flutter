import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// An individual message to be sent/received by Ably
///
/// https://docs.ably.com/client-lib-development-guide/features/#TM1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains an individual message that is sent to, or received from, Ably.
/// END CANONICAL DOCSTRING
@immutable
class Message with ObjectHash {
  /// BEGIN LEGACY DOCSTRING
  /// A unique ID for this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2a
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A Unique ID assigned by Ably to this message.
  /// END CANONICAL DOCSTRING
  final String? id;

  /// BEGIN LEGACY DOCSTRING
  /// The timestamp for this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2f
  /// END LEGACY DOCSTRING
  final DateTime? timestamp;

  /// BEGIN LEGACY DOCSTRING
  /// The id of the publisher of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The client ID of the publisher of this message.
  /// END CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// The connection id of the publisher of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2c
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The connection ID of the publisher of this message.
  /// END CANONICAL DOCSTRING
  final String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// Any transformation applied to the data for this message
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// This is typically empty, as all messages received from Ably are
  /// automatically decoded client-side using this value. However, if the
  /// message encoding cannot be processed, this attribute contains the
  /// remaining transformations not applied to the data payload.
  /// END CANONICAL DOCSTRING
  final String? encoding;

  final MessageData<dynamic>? _data;

  /// BEGIN LEGACY DOCSTRING
  /// Message payload
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2d
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The message payload, if provided.
  /// END CANONICAL DOCSTRING
  Object? get data => _data?.data;

  ///BEGIN LEGACY DOCSTRING
  /// Name of the message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2g
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The event name.
  /// END CANONICAL DOCSTRING
  final String? name;

  /// BEGIN LEGACY DOCSTRING
  /// Message extras that may contain message metadata
  /// and/or ancillary payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2i
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A JSON object of arbitrary key-value pairs that may contain metadata,
  /// and/or ancillary payloads. Valid payloads include [push]{@link Push},
  /// [delta]{@link DeltaExtras}, [ref]{@link ReferenceExtras} and headers.
  /// END CANONICAL DOCSTRING
  final MessageExtras? extras;

  /// BEGIN LEGACY DOCSTRING
  /// Creates a message instance with [name], [data] and [clientId]
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Construct a Message object with an event name, payload, and a unique
  /// client ID.
  ///
  /// [name] - The event name.
  /// [data] - 	The message payload.
  /// [clientId] - The client ID of the publisher of this message.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
  ///
  /// TODO(tiholic): decoding and decryption is not implemented as per
  ///  RSL6 and RLS6b as mentioned in TM3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A static factory method to create a Message object from a deserialized
  /// Message-like object encoded using Ably's wire protocol.
  ///
  /// [JsonObject] - A Message-like deserialized object.
  /// [ChannelOptions] - A [ChannelOptions]{@link ChannelOptions} object. If you
  /// have an encrypted channel, use this to allow the library to decrypt the
  /// data.
  ///
  /// [Message] - A Message object.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A static factory method to create an array of Message objects from an
  /// array of deserialized Message-like object encoded using Ably's wire
  /// protocol.
  ///
  /// [JsonArray] - An array of Message-like deserialized objects.
  /// [ChannelOptions] - A [ChannelOptions]{@link ChannelOptions} object. If you
  /// have an encrypted channel, use this to allow the library to decrypt the
  /// data.
  /// END CANONICAL DOCSTRING
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
