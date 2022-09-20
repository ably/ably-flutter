import 'dart:async';

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
abstract class EventEmitter<E, G> {
  /// BEGIN LEGACY DOCSTRING
  /// Create a listener, with which registrations may be made.
  /// END LEGACY DOCSTRING
  Stream<G> on([E? event]);
}
