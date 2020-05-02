package io.ably.flutter.plugin;

import androidx.annotation.NonNull;

import app.loup.streams_channel.StreamsChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

public class AblyFlutterPlugin implements FlutterPlugin {
    private static MethodCodec createCodec() {
        return new StandardMethodCodec(new AblyMessageCodec());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        setupChannels(flutterPluginBinding.getBinaryMessenger());
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
        AblyFlutterPlugin.setupChannels(registrar.messenger());
    }

    private static void setupChannels(BinaryMessenger messenger){
        MethodCodec codec = createCodec();
        AblyMethodCallHandler methodCallHandler = AblyMethodCallHandler.getInstance();

        final MethodChannel channel = new MethodChannel(messenger, "io.ably.flutter.plugin", codec);
        channel.setMethodCallHandler(methodCallHandler);

        final StreamsChannel streamsChannel = new StreamsChannel(messenger, "io.ably.flutter.stream", codec);
        streamsChannel.setStreamHandlerFactory(arguments -> new AblyEventStreamHandler(methodCallHandler));

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("Ably Plugin onDetachedFromEngine");
    }
}
