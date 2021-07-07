/// Interface implemented by event listeners, returned by event emitters.
abstract class EventListener<E> {
  /// Register for all events (no parameter), or a specific event.
  Stream<E> on([E? event]);

  /// Register for a single occurrence of any event (no parameter),
  /// or a specific event.
  Future<E> once([E? event]);

  /// Remove registrations for this listener, irrespective of type.
  Future<void> off();
}