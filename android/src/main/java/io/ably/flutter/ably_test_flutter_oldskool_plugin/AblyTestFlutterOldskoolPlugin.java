package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

/**
 * AblyTestFlutterOldskoolPlugin
 */
public class AblyTestFlutterOldskoolPlugin implements FlutterPlugin, MethodCallHandler {
    private final Listener _listener = new Listener();

    private static MethodCodec createCodec() {
        return new StandardMethodCodec(new AblyMessageCodec());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        System.out.println("Ably Plugin onAttachedToEngine");
        // TODO replace deprecated getFlutterEngine()
        // TODO work out whether this instance method should really be creating a new instance
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ably_test_flutter_oldskool_plugin", createCodec());
        flutterPluginBinding.getFlutterEngine().addEngineLifecycleListener(_listener);
        channel.setMethodCallHandler(new AblyTestFlutterOldskoolPlugin());
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "ably_test_flutter_oldskool_plugin", createCodec());
        channel.setMethodCallHandler(new AblyTestFlutterOldskoolPlugin());
    }

    private final HandlerMap _handlers = new HandlerMap();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        _handlers.handle(call, result);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("Ably Plugin onDetachedFromEngine");
    }

    private class HandlerMap {
        private final Map<String, BiConsumer<MethodCall, Result>> _map;
        private final Handlers _handlers = new Handlers();

        HandlerMap() {
            _map = new HashMap<>();
            _map.put("getPlatformVersion", _handlers::getPlatformVersion);
            _map.put("getVersion", _handlers::getVersion);
            _map.put("createRealtimeWithOptions", _handlers::createRealtimeWithOptions);
        }

        private void reset() {
            _handlers.reset();
        }

        public void handle(final @NonNull MethodCall call, final @NonNull Result result) {
            System.out.println("method: " + call.method);
            final BiConsumer<MethodCall, Result> handler = _map.get(call.method);
            if (null == handler) {
                // We don't have a handler for a method with this name so tell the caller.
                result.notImplemented();
            } else {
                // We have a handler for a method with this name so delegate to it.
                handler.accept(call, result);
            }
        }
    }

    private class Listener implements FlutterEngine.EngineLifecycleListener {
        @Override
        public void onPreEngineRestart() {
            // hot restart
            System.out.println("Ably Plugin onPreEngineRestart");
            _handlers.reset();
        }
    }

    private static class Handlers {
        private long _nextHandle = 1;
        private final Map<Long, AblyRealtime> _realtimeInstances= new HashMap<>();

        public void reset() {
            _realtimeInstances.clear();
        }

        private void getPlatformVersion(@NonNull MethodCall call, @NonNull Result result) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }

        private void getVersion(@NonNull MethodCall call, @NonNull Result result) {
            result.success(Defaults.ABLY_LIB_VERSION);
        }

        private void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull Result result) {
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
}
