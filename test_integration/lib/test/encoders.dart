import 'package:ably_flutter_plugin/ably_flutter_plugin.dart';

Map<String, dynamic> encodeMessage(Message message) => {
      'id': message.id,
      'timestamp': message.timestamp.toIso8601String(),
      'clientId': message.clientId,
      'connectionId': message.connectionId,
      'encoding': message.encoding,
      'data': message.data,
      'name': message.name,
      'extras': message.extras,
    };

String enumValueToString(Object value) =>
    value.toString().substring(value.toString().indexOf('.') + 1);

Map<String, dynamic> encodeChannelEvent(ChannelStateChange e) => {
      'event': enumValueToString(e.event),
      'current': enumValueToString(e.current),
      'previous': enumValueToString(e.previous),
      'reason': e.reason.toString(),
      'resumed': e.resumed,
    };

Map<String, dynamic> encodeConnectionEvent(ConnectionStateChange e) => {
      'event': enumValueToString(e.event),
      'current': enumValueToString(e.current),
      'previous': enumValueToString(e.previous),
      'reason': e.reason.toString(),
      'retryIn': e.retryIn,
    };
