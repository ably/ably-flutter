package io.ably.flutter.plugin.dto;

import io.ably.lib.realtime.ConnectionStateListener;

public class EnrichedConnectionStateChange {
    public final ConnectionStateListener.ConnectionStateChange stateChange;
    public final String connectionId;
    public final String connectionKey;

    public EnrichedConnectionStateChange(ConnectionStateListener.ConnectionStateChange stateChange, String connectionId, String connectionKey) {
        this.stateChange = stateChange;
        this.connectionId = connectionId;
        this.connectionKey = connectionKey;
    }
}
