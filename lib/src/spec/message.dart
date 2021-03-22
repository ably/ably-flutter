import 'enums.dart';
import 'rest/channels.dart';

/// An individual message to be sent/received by Ably
///
/// https://docs.ably.io/client-lib-development-guide/features/#TM1
class Message {
  /// A unique ID for this message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2a
  String id;

  /// The timestamp for this message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2f
  DateTime timestamp;

  /// The id of the publisher of this message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2b
  String clientId;

  /// The connection id of the publisher of this message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2c
  String connectionId;

  /// Any transformation applied to the data for this message
  String encoding;

  /// Message payload
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2d
  Object data;

  /// Name of the message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TM2g
  String name;

  /// Extras, if available
  Map extras;

  /// Creates a message instance with [name], [data] and [clientId]
  Message({this.name, this.data, this.clientId});

  @override
  String toString() => 'Message id=$id timestamp=$timestamp clientId=$clientId'
      ' connectionId=$connectionId encoding=$encoding name=$name'
      ' data=$data extras=$extras';

// TODO(tiholic) add support for fromEncoded and fromEncodedArray (TM3)
}

/// An individual presence message sent or received via realtime
///
/// https://docs.ably.io/client-lib-development-guide/features/#TP1
abstract class PresenceMessage {
  /// unique ID for this presence message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TP3a
  String id;

  /// presence action - to update presence status of current client,
  /// or to understand presence state of another client
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TP3b
  PresenceAction action;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3c
  String clientId;

  /// connection id of the source of this message
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#TP3d
  String connectionId;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3e
  dynamic data;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3f
  String encoding;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3i
  Map<String, dynamic> extras;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3g
  DateTime timestamp;

  /// https://docs.ably.io/client-lib-development-guide/features/#TP3h
  String get memberKey => '$connectionId:$clientId';

  /// instantiates a presence message with no defaults
  PresenceMessage();

  /// https://docs.ably.io/client-lib-development-guide/features/#TP4
  PresenceMessage.fromEncoded(Map jsonObject, ChannelOptions channelOptions);

  /// https://docs.ably.io/client-lib-development-guide/features/#TP4
  PresenceMessage.fromEncodedArray(
      List jsonArray, ChannelOptions channelOptions);
}
