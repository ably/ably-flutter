import 'package:meta/meta.dart';

import '../../generated/platform_constants.dart';
import '../message.dart';

/// Delta extension configuration for [MessageExtras]
@immutable
class DeltaExtras {
  /// the id of the message the delta was generated from
  final String? from;

  /// the delta format. Only "vcdiff" is supported currently
  final String? format;

  /// create instance from a map
  @protected
  DeltaExtras.fromMap(Map value)
      : from = value[TxDeltaExtras.from] as String?,
        format = value[TxDeltaExtras.format] as String?;

  @override
  bool operator ==(Object other) =>
      other is DeltaExtras && other.from == from && other.format == format;

  @override
  int get hashCode => '$from:$format'.hashCode;
}