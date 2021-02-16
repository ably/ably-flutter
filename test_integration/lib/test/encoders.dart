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

List<Map<String, dynamic>> encodeList<T>(
  List<T> items,
  Map<String, dynamic> Function(T) typeEncoder,
) =>
    List<T>.from(items).map<Map<String, dynamic>>(typeEncoder).toList();

Map<String, dynamic> encodePaginatedResult<T>(
  PaginatedResult<T> paginatedResult,
  Map<String, dynamic> Function(T) typeEncoder,
) =>
    {
      'items': encodeList<T>(paginatedResult.items, typeEncoder),
      'hasNext': paginatedResult.hasNext(),
      'isLast': paginatedResult.isLast(),
    };
