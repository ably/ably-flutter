import 'dart:convert';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/common/src/object_hash.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Handles supported message extras types, their encoding and decoding
@immutable
class MessageExtras with ObjectHash {
  /// json-encodable map of extras
  final Map<String, dynamic>? map;

  /// configuration for delta compression extension
  final DeltaExtras? _delta;

  /// delta configuration received from channel message
  DeltaExtras? get delta => _delta;

  /// Creates an instance from given extras map
  const MessageExtras(this.map) : _delta = null;

  /// Creates an instance from given extras map and an instance of DeltaExtras
  const MessageExtras._withDelta(this.map, this._delta);

  /// initializes [MessageExtras] with given value and validates
  /// the data type, runtime
  static MessageExtras? fromMap(Map<String, dynamic>? extrasMap) {
    if (extrasMap == null) return null;
    extrasMap = Map.castFrom<dynamic, dynamic, String, dynamic>(
      json.decode(json.encode(extrasMap)) as Map,
    );
    final deltaMap = extrasMap.remove(TxMessageExtras.delta) as Map?;
    return MessageExtras._withDelta(
      extrasMap,
      (deltaMap == null) ? null : DeltaExtras.fromMap(deltaMap),
    );
  }

  @override
  String toString() => {'extras': map, 'delta': delta}.toString();

  @override
  bool operator ==(Object other) =>
      other is MessageExtras &&
      const MapEquality().equals(other.map, map) &&
      other.delta == delta;

  @override
  int get hashCode => objectHash([
        map,
        delta,
      ]);
}
