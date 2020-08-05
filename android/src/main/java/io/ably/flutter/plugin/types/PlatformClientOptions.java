package io.ably.flutter.plugin.types;

import io.ably.lib.types.ClientOptions;

public class PlatformClientOptions extends ClientOptions {

    /**
     * Whether dart side has authCallback.
     * If true, autCallback proxy will be added in methodCallHandler
     * while creating rest/realtime instances
     */
    public boolean hasAuthCallback;

}
