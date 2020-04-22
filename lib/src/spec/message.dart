import 'enums.dart';
import 'rest/channels.dart';

class Message {
  Message.fromEncoded(Map jsonObject, ChannelOptions channelOptions);
  Message.fromEncodedArray(List<Map> jsonArray, ChannelOptions channelOptions);
  String clientId;
  String connectionId;
  dynamic data;
  String encoding;
  dynamic extras;
  String id;
  String name;
  DateTime timestamp;
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