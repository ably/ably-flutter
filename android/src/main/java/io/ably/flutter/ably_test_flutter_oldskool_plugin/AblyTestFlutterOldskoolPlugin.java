package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

import io.ably.lib.transport.Defaults;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AblyTestFlutterOldskoolPlugin
 */
public class AblyTestFlutterOldskoolPlugin implements FlutterPlugin, MethodCallHandler {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        // TODO replace deprecated getFlutterEngine()
        // TODO work out whether this instance method should really be creating a new instance
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ably_test_flutter_oldskool_plugin");
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
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "ably_test_flutter_oldskool_plugin");
        channel.setMethodCallHandler(new AblyTestFlutterOldskoolPlugin());
    }

    private final HandlerMap _handlers = new HandlerMap();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        _handlers.handle(call, result);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    private class HandlerMap {
        private final Map<String, BiConsumer<MethodCall, Result>> _map;
        private final Handlers _handlers = new Handlers();

        HandlerMap() {
            _map = new HashMap<>();
            _map.put("getPlatformVersion", _handlers::getPlatformVersion);
            _map.put("getAblyVersion", _handlers::getAblyVersion);
        }

        public void handle(final @NonNull MethodCall call, final @NonNull Result result) {
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

    private class Handlers {
        private void getPlatformVersion(@NonNull MethodCall call, @NonNull Result result) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }

        private void getAblyVersion(@NonNull MethodCall call, @NonNull Result result) {
            result.success(Defaults.ABLY_LIB_VERSION);
        }
    }
}
