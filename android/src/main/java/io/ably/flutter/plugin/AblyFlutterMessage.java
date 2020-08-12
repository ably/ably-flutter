package io.ably.flutter.plugin;

import androidx.annotation.NonNull;

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

    @NonNull
    @Override
    public String toString() {
        return "{message=" + (message.toString()) + ", handle=" + (handle==null?"":handle.toString()) + "}";
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
