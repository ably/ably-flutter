import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:meta/meta.dart';

/// An individual message to be sent/received by Ably
///
/// https://docs.ably.com/client-lib-development-guide/features/#TM1
@immutable
class Message {
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
    this.id,
    this.name,
    Object? data,
    this.clientId,
    this.connectionId,
    this.timestamp,
    this.encoding,
    this.extras,
  }) : _data = MessageData.fromValue(data);

  @override
  bool operator ==(Object other) =>
      other is Message &&
      other.id == id &&
      other.name == name &&
      other.data == data &&
      other.extras == extras &&
      other.encoding == encoding &&
      other.clientId == clientId &&
      other.timestamp == timestamp &&
      other.connectionId == connectionId;

  @override
  int get hashCode => '$id:'
          '$name:'
          '$encoding:'
          '$clientId:'
          '$timestamp:'
          '$connectionId:'
          '${data?.hashCode}:'
          '${extras?.hashCode}:'
      .hashCode;

  /// Decodes message from JSON format. For encrypted messages, [channelOptions]
  /// param can be provided, to decrypt then during the decoding process
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
  static Future<Message> fromEncoded(
    String jsonObject, [
    RestChannelOptions? channelOptions,
  ]) async =>
      Platform().invokePlatformMethodNonNull<Message>(
          PlatformMethod.messageFromEncoded, {
        TxTransportKeys.message: jsonObject,
        TxTransportKeys.options: channelOptions,
      });

  /// https://docs.ably.com/client-lib-development-guide/features/#TM3
  static Future<List<Message>> fromEncodedArray(
    List<String> jsonObjects, [
    RestChannelOptions? channelOptions,
  ]) async {
    final decodedMessages = List<Message>.empty();

    for (final jsonObject in jsonObjects) {
      final decodedMessage =
          await Message.fromEncoded(jsonObject, channelOptions);
      decodedMessages.add(decodedMessage);
    }

    return decodedMessages;
  }

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
}
