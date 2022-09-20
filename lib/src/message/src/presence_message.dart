import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// An individual presence message sent or received via realtime
///
/// https://docs.ably.com/client-lib-development-guide/features/#TP1
/// END LEGACY DOCSTRING
@immutable
class PresenceMessage with ObjectHash {
  /// BEGIN LEGACY DOCSTRING
  /// unique ID for this presence message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3a
  /// END LEGACY DOCSTRING
  final String? id;

  /// BEGIN LEGACY DOCSTRING
  /// presence action - to update presence status of current client,
  /// or to understand presence state of another client
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3b
  /// END LEGACY DOCSTRING
  final PresenceAction? action;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3c
  /// END LEGACY DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// connection id of the source of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3d
  /// END LEGACY DOCSTRING
  final String? connectionId;

  final MessageData<dynamic>? _data;

  /// BEGIN LEGACY DOCSTRING
  /// Message payload
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3e
  /// END LEGACY DOCSTRING
  Object? get data => _data?.data;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3f
  /// END LEGACY DOCSTRING
  final String? encoding;

  /// BEGIN LEGACY DOCSTRING
  /// Message extras that may contain message metadata
  /// and/or ancillary payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3i
  /// END LEGACY DOCSTRING
  final MessageExtras? extras;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3g
  /// END LEGACY DOCSTRING
  final DateTime? timestamp;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3h
  /// END LEGACY DOCSTRING
  String get memberKey => '$connectionId:$clientId';

  /// BEGIN LEGACY DOCSTRING
  /// instantiates presence message with
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP4
  ///
  /// TODO(tiholic): decoding and decryption is not implemented as per
  ///  RSL6 and RLS6b as mentioned in TP4
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TP4
  /// END LEGACY DOCSTRING
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
