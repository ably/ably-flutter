package io.ably.flutter.ably_test_flutter_oldskool_plugin.surface;

import io.ably.lib.realtime.AblyRealtime;

public class Realtime {
    private final AblyRealtime _instance;

    public Realtime(final AblyRealtime instance) {
        _instance = instance;
    }

    public void connect() {
        _instance.connect();
    }

    public void close() {
        _instance.close();
    }
}
