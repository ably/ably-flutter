package io.ably.flutter.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.RemoteMessage;

import io.ably.flutter.plugin.push.PushActivationEventHandlers;
import io.ably.flutter.plugin.push.PushMessagingEventHandlers;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

public class AblyFlutterPlugin implements FlutterPlugin, ActivityAware {
    private Context applicationContext;
    private AblyMethodCallHandler methodCallHandler;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
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
        setupChannels(registrar.messenger(), applicationContext);
    }

    private void setupChannels(BinaryMessenger messenger, Context applicationContext) {
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
        PushActivationEventHandlers.instantiate(applicationContext, methodChannel);
        PushMessagingEventHandlers.instantiate(applicationContext, methodChannel);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        System.out.println("Ably Plugin onDetachedFromEngine");
    }

    private static MethodCodec createCodec() {
        return new StandardMethodCodec(new AblyMessageCodec());
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Activity activity = binding.getActivity();
        Intent intent = activity.getIntent();
        Bundle extras = intent.getExtras();
        if (extras != null) {
            RemoteMessage message = new RemoteMessage(extras);
            if (message.getData().size() > 0 || message.getNotification() != null) {
                // Only send the RemoteMessage to the dart side if it was actually a RemoteMessage.
                methodCallHandler.setRemoteMessageFromUserTapLaunchesApp(message);
            }
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    // This method does not get called when the app goes into the background
    @Override
    public void onDetachedFromActivity() {
    }
}
