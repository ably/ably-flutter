import 'enums.dart';
import 'rest/channels.dart';

class Message {

  /// A unique ID for this message
  String id;

  /// The timestamp for this message
  DateTime timestamp;

  /// The id of the publisher of this message
  String clientId;

  /// The connection id of the publisher of this message
  String connectionId;

  /// Any transformation applied to the data for this message
  String encoding;

  /// The message payload
  dynamic data;

  /// The event name, if available
  String name;

  /// Extras, if available
  Map extras;

  Message({this.name, this.data, this.clientId});  // TM2

  @override
  String toString() {
    return 'Message id=$id timestamp=$timestamp clientId=$clientId'
      ' connectionId=$connectionId encoding=$encoding name=$name'
      ' data=$data extras=$extras';
  }

}

abstract class MessageStatic {  //TODO why is this class required?
  MessageStatic.fromEncoded(Map jsonObject, ChannelOptions channelOptions);
  MessageStatic.fromEncodedArray(List jsonArray, ChannelOptions channelOptions);
}

abstract class PresenceMessage {
  PresenceMessage.fromEncoded(Map jsonObject, ChannelOptions channelOptions);
  PresenceMessage.fromEncodedArray(List jsonArray, ChannelOptions channelOptions);
  PresenceAction action;
  String clientId;
  String connectionId;
  dynamic data;
  String encoding;
  Map<String, dynamic> extras;
  String id;
  DateTime timestamp;
  String memberKey();
}

abstract class PresenceMessageStatic {  //TODO why is this class required?
  PresenceMessageStatic.fromEncoded(Map jsonObject, ChannelOptions channelOptions);
  PresenceMessageStatic.fromEncodedArray(List jsonArray, ChannelOptions channelOptions);
}
