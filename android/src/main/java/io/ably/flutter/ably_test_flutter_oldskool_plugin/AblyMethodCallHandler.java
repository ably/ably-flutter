package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
    private static AblyMethodCallHandler _instance;

    public static synchronized AblyMethodCallHandler getInstance() {
        if (null == _instance) {
            _instance = new AblyMethodCallHandler();
        }
        return _instance;
    }

    private final Map<String, BiConsumer<MethodCall, MethodChannel.Result>> _map;
    private final AblyLibrary _library = new AblyLibrary();

    private AblyMethodCallHandler() {
        _map = new HashMap<>();
        _map.put("getPlatformVersion", _library::getPlatformVersion);
        _map.put("getVersion", _library::getVersion);
        _map.put("createRealtimeWithOptions", _library::createRealtimeWithOptions);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        System.out.println("Ably Plugin handle: " + call.method);
        final BiConsumer<MethodCall, MethodChannel.Result> handler = _map.get(call.method);
        if (null == handler) {
            // We don't have a handler for a method with this name so tell the caller.
            result.notImplemented();
        } else {
            // We have a handler for a method with this name so delegate to it.
            handler.accept(call, result);
        }
    }

    public void reset() {
        _library.reset();
    }
}
