package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AblyLibrary {
    private long _nextHandle = 1;
    private final Map<Long, AblyRealtime> _realtimeInstances= new HashMap<>();

    public void reset() {
        System.out.println("Ably Plugin reset - AblyRealtime count: " + _realtimeInstances.size() + " (next handle " + _nextHandle + ")");
        for (final AblyRealtime r : _realtimeInstances.values()) {
            try {
                r.close();
            } catch (Throwable t) {
                t.printStackTrace();
            }
        }
        _realtimeInstances.clear();
    }

    public void getPlatformVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    public void getVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success(Defaults.ABLY_LIB_VERSION);
    }

    public void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final ClientOptions clientOptions = (ClientOptions)call.arguments;

        final AblyRealtime realtime;
        try {
            realtime = new AblyRealtime(clientOptions);
        } catch (AblyException e) {
            result.error(Integer.toString(e.errorInfo.code), e.getMessage(), null);
            return;
        }

        final long handle = _nextHandle++;
        _realtimeInstances.put(handle, realtime);
        result.success(handle);
    }
}
