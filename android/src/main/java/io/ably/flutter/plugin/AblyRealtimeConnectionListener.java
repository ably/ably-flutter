package io.ably.flutter.plugin;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import io.ably.lib.realtime.ConnectionStateListener;

/**
 * Not the most sophisticated of implementations but should be safe to call from multiple threads.
 */
public class AblyRealtimeConnectionListener implements ConnectionStateListener {
    private final List<CompletableFuture<ConnectionStateChange>> _once = new ArrayList<>();

    @Override
    public synchronized void onConnectionStateChanged(final ConnectionStateChange state) {
        System.out.println("AblyRealtimeConnectionListener onConnectionStateChanged: " + state);
        for (final CompletableFuture<ConnectionStateChange> future : _once) {
            future.complete(state);
        }
        _once.clear();
    }

    public synchronized CompletableFuture<ConnectionStateChange> listen() {
        final CompletableFuture<ConnectionStateChange> future = new CompletableFuture<>();
        _once.add(future);
        return future;
    }
}
