import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains any arbitrary key-value pairs, which may also contain other
/// primitive JSON types, JSON-encodable objects, or JSON-encodable arrays from
/// delta compression.
/// END EDITED CANONICAL DOCSTRING
@immutable
class DeltaExtras with ObjectHash {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The ID of the message the delta was generated from.
  /// END EDITED CANONICAL DOCSTRING
  final String? from;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The delta compression format. Only vcdiff is supported.
  /// END EDITED CANONICAL DOCSTRING
  final String? format;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
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
