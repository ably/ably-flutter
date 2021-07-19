package io.ably.flutter.plugin;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

public class AblyFlutterPlugin implements FlutterPlugin {
    private Context applicationContext;

    private static MethodCodec createCodec() {
        return new StandardMethodCodec(new AblyMessageCodec());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        Log.d("Crap", applicationContext.toString());
        setupChannels(flutterPluginBinding.getBinaryMessenger(), applicationContext);
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
    public void registerWith(Registrar registrar) {
        AblyFlutterPlugin.setupChannels(registrar.messenger(), applicationContext);
    }

    private static void setupChannels(BinaryMessenger messenger, Context applicationContext) {
        final MethodCodec codec = createCodec();

        final StreamsChannel streamsChannel = new StreamsChannel(messenger, "io.ably.flutter.stream", codec);
        streamsChannel.setStreamHandlerFactory(arguments -> new AblyEventStreamHandler(applicationContext));

        final MethodChannel channel = new MethodChannel(messenger, "io.ably.flutter.plugin", codec);
        AblyMethodCallHandler methodCallHandler = AblyMethodCallHandler.getInstance(
                channel,
                // Streams channel will be reset on `register` method call
                // and also on every hot-reload
                streamsChannel::reset,
            applicationContext
        );
        channel.setMethodCallHandler(methodCallHandler);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("Ably Plugin onDetachedFromEngine");
    }
}
