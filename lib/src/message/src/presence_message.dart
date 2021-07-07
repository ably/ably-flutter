import 'package:meta/meta.dart';

import '../../rest/rest.dart';
import 'message_data.dart';
import 'message_extras.dart';
import 'presence_action.dart';

/// An individual presence message sent or received via realtime
///
/// https://docs.ably.com/client-lib-development-guide/features/#TP1
@immutable
class PresenceMessage {
  /// unique ID for this presence message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3a
  final String? id;

  /// presence action - to update presence status of current client,
  /// or to understand presence state of another client
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3b
  final PresenceAction? action;

  /// https://docs.ably.com/client-lib-development-guide/features/#TP3c
  final String? clientId;

  /// connection id of the source of this message
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3d
  final String? connectionId;

  final MessageData? _data;

  /// Message payload
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3e
  Object? get data => _data?.data;

  /// https://docs.ably.com/client-lib-development-guide/features/#TP3f
  final String? encoding;

  /// Message extras that may contain message metadata
  /// and/or ancillary payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TP3i
  final MessageExtras? extras;

  /// https://docs.ably.com/client-lib-development-guide/features/#TP3g
  final DateTime? timestamp;

  /// https://docs.ably.com/client-lib-development-guide/features/#TP3h
  String get memberKey => '$connectionId:$clientId';

  /// instantiates presence message with
  PresenceMessage({
    this.id,
    this.action,
    this.clientId,
    this.connectionId,
    Object? data,
    this.encoding,
    this.extras,
    this.timestamp,
  }) : _data = MessageData.fromValue(data);

  @override
  bool operator ==(Object other) =>
      other is PresenceMessage &&
          other.id == id &&
          other.action == action &&
          other.clientId == clientId &&
          other.connectionId == connectionId &&
          other.data == data &&
          other.encoding == encoding &&
          other.extras == extras &&
          other.timestamp == timestamp;

  @override
  int get hashCode => '$id:'
      '$encoding:'
      '$clientId:'
      '$timestamp:'
      '$connectionId:'
      '${data?.toString()}:'
      '${action.toString()}:'
      '${extras?.toString()}:'
      .hashCode;

  /// https://docs.ably.com/client-lib-development-guide/features/#TP4
  ///
  /// TODO(tiholic): decoding and decryption is not implemented as per
  ///  RSL6 and RLS6b as mentioned in TP4
  PresenceMessage.fromEncoded(
      Map<String, dynamic> jsonObject, [
        ChannelOptions? channelOptions,
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

  /// https://docs.ably.com/client-lib-development-guide/features/#TP4
  static List<PresenceMessage> fromEncodedArray(
      List<Map<String, dynamic>> jsonArray, [
        ChannelOptions? channelOptions,
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
