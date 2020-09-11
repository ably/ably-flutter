package io.ably.flutter.plugin.types;

import io.ably.lib.types.ClientOptions;

public class PlatformClientOptions {

    /**
     * Whether dart side has authCallback.
     * If true, autCallback proxy will be added in methodCallHandler
     * while creating rest/realtime instances
     */
    public final boolean hasAuthCallback;
    public final ClientOptions options;

    public PlatformClientOptions(ClientOptions options, boolean hasAuthCallback) {
        this.options = options;
        this.hasAuthCallback = hasAuthCallback;
    }

}
