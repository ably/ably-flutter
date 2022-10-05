import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Interface implemented by Ably classes that can emit events,
/// offering the capability to create listeners for those events.
/// [E] is type of event to listen for
/// [G] is the instance which will be passed back in streams.
///
///
/// There is no `off` API as in other Ably client libraries as on returns a
/// [Stream] which can be subscribed for, and that subscription can be cancelled
/// using [StreamSubscription.cancel] API
/// END LEGACY DOCSTRING
///
/// BEGIN CANONICAL DOCSTRING
/// A generic interface for event registration and delivery used in a number of
/// the types in the Realtime client library. For example, the
/// [Connection] object emits events for connection state using the
/// EventEmitter pattern.
/// END CANONICAL DOCSTRING - NOTE: This class is not actually used anywhere.
/// Dead code.
abstract class EventEmitter<E, G> {
  /// BEGIN LEGACY DOCSTRING
  /// Create a listener, with which registrations may be made.
  /// END LEGACY DOCSTRING
  Stream<G> on([E? event]);
}
