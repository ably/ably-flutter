package io.ably.flutter.plugin;

class AblyFlutterMessage<T> {
    final Long handle;
    final T message;

    AblyFlutterMessage(final T message, final Long handle) {
        assert message != null : "message cannot be null";
        this.handle = handle;
        this.message = message;
    }
}


class AblyEventMessage<T> {
    final String eventName;
    final T message;

    AblyEventMessage(final String eventName, final T message) {
        assert eventName != null : "eventName cannot be null";
        this.eventName = eventName;
        this.message = message;
    }

}