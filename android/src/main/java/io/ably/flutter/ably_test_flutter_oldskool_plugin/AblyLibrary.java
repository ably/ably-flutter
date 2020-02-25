package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import java.util.HashMap;
import java.util.Map;

import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;

class AblyLibrary {
    private boolean _disposed = false;
    private long _nextHandle = 1;
    private final Map<Long, AblyRealtime> _realtimeInstances = new HashMap<>();
    private final Map<Long, AblyRealtimeConnectionListener> _connectionListeners = new HashMap<>();

    private void assertNotDisposed() {
        if (_disposed) {
            throw new IllegalStateException("Instance disposed.");
        }
    }

    long createRealtime(final ClientOptions clientOptions) throws AblyException {
        assertNotDisposed();

        final AblyRealtime realtime = new AblyRealtime(clientOptions);
        final long handle = _nextHandle++;
        _realtimeInstances.put(handle, realtime);
        return handle;
    }

    AblyRealtime getRealtime(final long handle) {
        assertNotDisposed();

        return _realtimeInstances.get(handle);
    }

    long createConnectionListener(final AblyRealtime realtime) {
        assertNotDisposed();

        final AblyRealtimeConnectionListener listener = new AblyRealtimeConnectionListener();
        realtime.connection.on(listener);
        final long handle = _nextHandle++;
        _connectionListeners.put(handle, listener);
        return handle;
    }

    AblyRealtimeConnectionListener getConnectionListener(final long handle) {
        assertNotDisposed();

        return _connectionListeners.get(handle);
    }

    void dispose() {
        assertNotDisposed();

        _disposed = true;

        for (final AblyRealtime r : _realtimeInstances.values()) {
            try {
                r.close();
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        _realtimeInstances.clear();
    }
}
