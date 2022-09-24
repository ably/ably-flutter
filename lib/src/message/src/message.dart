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
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// The connection id of the publisher of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2c
  /// END LEGACY DOCSTRING
  final String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// Any transformation applied to the data for this message
  /// END LEGACY DOCSTRING
  final String? encoding;

  final MessageData<dynamic>? _data;

  /// BEGIN LEGACY DOCSTRING
  /// Message payload
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2d
  /// END LEGACY DOCSTRING
  Object? get data => _data?.data;

  /// Name of the message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2g
  final String? name;

  /// BEGIN LEGACY DOCSTRING
  /// Message extras that may contain message metadata
  /// and/or ancillary payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2i
  /// END LEGACY DOCSTRING
  final MessageExtras? extras;

  /// BEGIN LEGACY DOCSTRING
  /// Creates a message instance with [name], [data] and [clientId]
  /// END LEGACY DOCSTRING
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
