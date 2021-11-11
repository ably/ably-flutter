package io.ably.flutter.plugin;

class AblyEventMessage<T> {
    final String eventName;
    final T message;
    final Integer handle;

    AblyEventMessage(final String eventName, final T message, final Integer handle) {
        if (null == eventName) {
            throw new NullPointerException("eventName cannot be null.");
        }
        this.eventName = eventName;
        this.message = message;
        this.handle = handle;
    }
}
