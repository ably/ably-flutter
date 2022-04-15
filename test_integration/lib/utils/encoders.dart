import 'package:ably_flutter/ably_flutter.dart';

Map<String, dynamic>? encodeMessageExtras(MessageExtras? extras) =>
    extras == null
        ? null
        : {
            'extras': extras.map,
            'delta': (extras.delta == null)
                ? null
                : {
                    'from': extras.delta!.from,
                    'format': extras.delta!.format,
                  },
          };

Map<String, dynamic> encodeMessage(Message message) => {
      'id': message.id,
      'timestamp': message.timestamp?.toIso8601String(),
      'clientId': message.clientId,
      'connectionId': message.connectionId,
      'encoding': message.encoding,
      'data': message.data,
      'name': message.name,
      'extras': encodeMessageExtras(message.extras),
    };

Map<String, dynamic> encodePresenceMessage(PresenceMessage message) => {
      'id': message.id,
      'action': enumValueToString(message.action!),
      'clientId': message.clientId,
      'connectionId': message.connectionId,
      'data': message.data,
      'encoding': message.encoding,
      'extras': encodeMessageExtras(message.extras),
      'timestamp': message.timestamp?.toIso8601String(),
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

Map<String, dynamic> encodeAblyException<T>(AblyException exception) => {
      'code': exception.code,
      'message': exception.message,
      'errorInfo': {
        'code': exception.errorInfo?.code,
        'href': exception.errorInfo?.href,
        'message': exception.errorInfo?.message,
        'cause': exception.errorInfo?.cause,
        'statusCode': exception.errorInfo?.statusCode,
        'requestId': exception.errorInfo?.requestId,
      }
    };
