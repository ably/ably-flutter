import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// An individual message to be sent/received by Ably
///
/// https://docs.ably.com/client-lib-development-guide/features/#TM1
@immutable
class Message with ObjectHash {
  /// A unique ID for this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2a
  final String? id;

  /// The timestamp for this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2f
  final DateTime? timestamp;

  /// The id of the publisher of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2b
  final String? clientId;

  /// The connection id of the publisher of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2c
  final String? connectionId;

  /// Any transformation applied to the data for this message
  final String? encoding;

  final MessageData? _data;

  /// Message payload
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2d
  Object? get data => _data?.data;

  /// Name of the message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2g
  final String? name;

  /// Message extras that may contain message metadata
  /// and/or ancillary payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM2i
  final MessageExtras? extras;

  /// Creates a message instance with [name], [data] and [clientId]
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

  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
  ///
  /// TODO(tiholic): decoding and decryption is not implemented as per
  ///  RSL6 and RLS6b as mentioned in TM3
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

  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
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
