import 'dart:typed_data';

/// BEGIN LEGACY DOCSTRING
/// Handles supported message data types, their encoding and decoding
/// END LEGACY DOCSTRING
class MessageData<T> {
  final T _data;

  /// BEGIN LEGACY DOCSTRING
  /// Only Map, List, string and Buffer types are supported
  /// END LEGACY DOCSTRING
  MessageData(this._data)
      : assert(T == Map || T == List || T == String || T == Uint8List);

  /// BEGIN LEGACY DOCSTRING
  /// retrieve data
  /// END LEGACY DOCSTRING
  T get data => _data;

  /// BEGIN LEGACY DOCSTRING
  /// initializes [MessageData] with given value and asserts from input type
  /// END LEGACY DOCSTRING
  static MessageData<dynamic>? fromValue(Object? value) {
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
      return MessageData<Map<dynamic, dynamic>>(value);
    } else if (value is Uint8List) {
      return MessageData<Uint8List>(value);
    } else if (value is List) {
      return MessageData<List<dynamic>>(value);
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
