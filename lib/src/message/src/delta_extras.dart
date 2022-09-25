import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Delta extension configuration for [MessageExtras]
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains any arbitrary key-value pairs, which may also contain other
/// primitive JSON types, JSON-encodable objects, or JSON-encodable arrays from
/// delta compression.
/// END CANONICAL DOCSTRING
@immutable
class DeltaExtras with ObjectHash {
  /// BEGIN LEGACY DOCSTRING
  /// the id of the message the delta was generated from
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The ID of the message the delta was generated from.
  /// END CANONICAL DOCSTRING
  final String? from;

  /// BEGIN LEGACY DOCSTRING
  /// the delta format. Only "vcdiff" is supported currently
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The delta compression format. Only vcdiff is supported.
  /// END CANONICAL DOCSTRING
  final String? format;

  /// BEGIN LEGACY DOCSTRING
  /// create instance from a map
  /// END LEGACY DOCSTRING
  @protected
  DeltaExtras.fromMap(Map<String, dynamic> value)
      : format = value[TxDeltaExtras.format] as String?,
        from = value[TxDeltaExtras.from] as String?;

  @override
  bool operator ==(Object other) =>
      other is DeltaExtras && other.from == from && other.format == format;

  @override
  int get hashCode => objectHash([
        from,
        format,
      ]);
}
