package io.ably.flutter.plugin;

import androidx.annotation.NonNull;

public class AblyFlutterMessage<T> {
    final Long handle;
    final T message;

    AblyFlutterMessage(final T message, final Long handle) {
        this.handle = handle;
        this.message = message;
    }

    @NonNull
    @Override
    public String toString() {
        return "{message=" + (message.toString()) + ", handle=" + (handle == null ? "" : handle.toString()) + "}";
    }

}
