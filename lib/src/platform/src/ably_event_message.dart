/// An encapsulating object used to pass data to platform for registering events
class AblyEventMessage {
  /// name of the event to register a listener for
  final String eventName;

  /// data to be passed for starting a listener
  final Object? message;

  /// creates an instance with non-nul [eventName]
  ///
  /// [message] is optional
  ///
  /// Raises [AssertionError] if [eventName] is null
  AblyEventMessage(this.eventName, [this.message]);
}
