package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import java.util.HashMap;
import java.util.Map;

import io.ably.flutter.ably_test_flutter_oldskool_plugin.surface.Realtime;
import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;

class AblyLibrary {
    private boolean _disposed = false;
    private long _nextHandle = 1;
    private final Map<Long, Realtime> _realtimeInstances = new HashMap<>();

    private void assertNotDisposed() {
        if (_disposed) {
            throw new IllegalStateException("Instance disposed.");
        }
    }

    Long createRealtime(final ClientOptions clientOptions) throws AblyException {
        assertNotDisposed();

        final Realtime realtime = new Realtime(new AblyRealtime(clientOptions));
        final long handle = _nextHandle++;
        _realtimeInstances.put(handle, realtime);
        return handle;
    }

    Realtime getRealtime(final Long handle) {
        return _realtimeInstances.get(handle);
    }

    void dispose() {
        assertNotDisposed();

        _disposed = true;

        for (final Realtime r : _realtimeInstances.values()) {
            try {
                r.close();
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        _realtimeInstances.clear();
    }
}
