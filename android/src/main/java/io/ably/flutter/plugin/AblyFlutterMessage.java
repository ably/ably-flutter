package io.ably.flutter.plugin;

class AblyFlutterMessage {
    final Long handle;
    final Object message;

    AblyFlutterMessage(final Long handle, final Object message) {
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
