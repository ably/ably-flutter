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
