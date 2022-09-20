import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Handles supported message extras types, their encoding and decoding
/// END LEGACY DOCSTRING
@immutable
class MessageExtras with ObjectHash {
  /// BEGIN LEGACY DOCSTRING
  /// json-encodable map of extras
  /// END LEGACY DOCSTRING
  final Map<String, dynamic>? map;

  /// BEGIN LEGACY DOCSTRING
  /// configuration for delta compression extension
  /// END LEGACY DOCSTRING
  final DeltaExtras? _delta;

  /// BEGIN LEGACY DOCSTRING
  /// delta configuration received from channel message
  /// END LEGACY DOCSTRING
  DeltaExtras? get delta => _delta;

  /// BEGIN LEGACY DOCSTRING
  /// Creates an instance from given extras map
  /// END LEGACY DOCSTRING
  const MessageExtras(this.map) : _delta = null;

  /// BEGIN LEGACY DOCSTRING
  /// Creates an instance from given extras map and an instance of DeltaExtras
  /// END LEGACY DOCSTRING
  const MessageExtras._withDelta(this.map, this._delta);

  /// BEGIN LEGACY DOCSTRING
  /// initializes [MessageExtras] with given value and validates
  /// the data type, runtime
  /// END LEGACY DOCSTRING
  static MessageExtras? fromMap(Map<String, dynamic>? extrasMap) {
    if (extrasMap == null) return null;
    // In some cases, extrasMap may not be a mutable map
    // for example, when it's a CastMap, so we need to create a mutable
    // instance from the existing extras map
    final mutableExtrasMap = Map<String, dynamic>.from(extrasMap);
    final deltaMap =
        mutableExtrasMap.remove(TxMessageExtras.delta) as Map<String, dynamic>?;
    return MessageExtras._withDelta(
      mutableExtrasMap,
      (deltaMap == null) ? null : DeltaExtras.fromMap(deltaMap),
    );
  }

  @override
  String toString() => {'extras': map, 'delta': delta}.toString();

  @override
  bool operator ==(Object other) =>
      other is MessageExtras &&
      const MapEquality<String, dynamic>().equals(other.map, map) &&
      other.delta == delta;

  @override
  int get hashCode => objectHash([
        map,
        delta,
      ]);
}
