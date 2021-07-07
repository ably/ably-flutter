import 'dart:typed_data';

/// Handles supported message data types, their encoding and decoding
class MessageData<T> {
  final T _data;

  /// Only Map, List, string and Buffer types are supported
  MessageData(this._data)
      : assert(T == Map || T == List || T == String || T == Uint8List);

  /// retrieve data
  T get data => _data;

  /// initializes [MessageData] with given value and asserts from input type
  static MessageData? fromValue(Object? value) {
    if (value == null) {
      return null;
    }
    assert(
    value is MessageData ||
        value is Map ||
        value is List ||
        value is String ||
        value is Uint8List,
    'Message data must be either `Map`, `List`, `String` or `Uint8List`.'
        ' Does not support $value ("${value.runtimeType}")',
    );
    if (value is MessageData) {
      return value;
    } else if (value is Map) {
      return MessageData<Map>(value);
    } else if (value is Uint8List) {
      return MessageData<Uint8List>(value);
    } else if (value is List) {
      return MessageData<List>(value);
    } else if (value is String) {
      return MessageData<String>(value);
    } else {
      throw AssertionError(
        'Message data must be either `Map`, `List`, `String` or `Uint8List`.'
            ' Does not support $value ("${value.runtimeType}")',
      );
    }
  }
}