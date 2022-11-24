import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:meta/meta.dart';

/// Contains any arbitrary key-value pairs, which may also contain other
/// primitive JSON types, JSON-encodable objects, or JSON-encodable arrays from
/// delta compression.
@immutable
class DeltaExtras with ObjectHash {
  /// The ID of the message the delta was generated from.
  final String? from;

  /// The delta compression format. Only vcdiff is supported.
  final String? format;

  /// @nodoc
  /// create instance from a map
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
