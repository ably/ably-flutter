package io.ably.flutter.plugin;

class AblyFlutterMessage<T> {
    final Long handle;
    final T message;

    AblyFlutterMessage(final T message, final Long handle) {
        if (null == message) {
            throw new NullPointerException("message cannot be null.");
        }
        this.handle = handle;
        this.message = message;
    }
}


class AblyEventMessage<T> {
    final String eventName;
    final T message;

    AblyEventMessage(final String eventName, final T message) {
        if (null == eventName) {
            throw new NullPointerException("message cannot be null.");
        }
        this.eventName = eventName;
        this.message = message;
    }

}
