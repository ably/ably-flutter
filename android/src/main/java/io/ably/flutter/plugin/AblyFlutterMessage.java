package io.ably.flutter.plugin;

class AblyFlutterMessage<T> {
    final Long handle;
    final T message;

    AblyFlutterMessage(final Long handle, final T message) {
        if (null == handle) {
            throw new NullPointerException("handle cannot be null.");
        }
        if (null == message) {
            throw new NullPointerException("message cannot be null.");
        }
        this.handle = handle;
        this.message = message;
    }
}
