package io.ably.flutter.plugin;

class AblyEventMessage<T> {
  final String eventName;
  final T message;

  AblyEventMessage(final String eventName, final T message) {
    if (null == eventName) {
      throw new NullPointerException("eventName cannot be null.");
    }
    this.eventName = eventName;
    this.message = message;
  }
}
