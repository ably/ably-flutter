package io.ably.flutter.ably_test_flutter_oldskool_plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

/**
 * AblyTestFlutterOldskoolPlugin
 */
public class AblyTestFlutterOldskoolPlugin implements FlutterPlugin {
    private final Listener _listener = new Listener();

    private static int _nextId = 1;
    private final int _id = _nextId++;
    public AblyTestFlutterOldskoolPlugin() {
        System.out.println("New Ably Plugin " + _id);
    }

    private static MethodCodec createCodec() {
        return new StandardMethodCodec(new AblyMessageCodec());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        System.out.println("Ably Plugin " + _id + " onAttachedToEngine");
        // TODO replace deprecated getFlutterEngine()
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ably_test_flutter_oldskool_plugin", createCodec());
        flutterPluginBinding.getFlutterEngine().addEngineLifecycleListener(_listener);
        channel.setMethodCallHandler(AblyMethodCallHandler.getInstance());
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
        channel.setMethodCallHandler(AblyMethodCallHandler.getInstance());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("Ably Plugin " + _id + " onDetachedFromEngine");
    }

    private class Listener implements FlutterEngine.EngineLifecycleListener {
        @Override
        public void onPreEngineRestart() {
            // hot restart
            System.out.println("Ably Plugin " + _id + " onPreEngineRestart");
            AblyMethodCallHandler.getInstance().reset();
        }
    }
}
