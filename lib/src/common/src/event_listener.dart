/// BEGIN LEGACY DOCSTRING
/// Interface implemented by event listeners, returned by event emitters.
/// END LEGACY DOCSTRING
abstract class EventListener<E> {
  /// BEGIN LEGACY DOCSTRING
  /// Register for all events (no parameter), or a specific event.
  /// END LEGACY DOCSTRING
  Stream<E> on([E? event]);

  /// BEGIN LEGACY DOCSTRING
  /// Register for a single occurrence of any event (no parameter),
  /// or a specific event.
  /// END LEGACY DOCSTRING
  Future<E> once([E? event]);

  /// BEGIN LEGACY DOCSTRING
  /// Remove registrations for this listener, irrespective of type.
  /// END LEGACY DOCSTRING
  Future<void> off();
}
