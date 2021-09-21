package io.ably.flutter.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.messaging.RemoteMessage;

import java.nio.channels.CompletionHandler;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.push.CompletionHandlerWithRemoteMessage;
import io.ably.flutter.plugin.push.PushActivationEventHandlers;
import io.ably.flutter.plugin.push.PushMessagingEventHandlers;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMethodCodec;

public class AblyFlutterPlugin implements FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
    public static Boolean isActivityRunning = false;
    private Context applicationContext;
    private AblyMethodCallHandler methodCallHandler;
    private Activity mainActivity;
    private MethodChannel methodChannel;

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
    public static void registerWith(Registrar registrar) {
        Context applicationContext = registrar.context().getApplicationContext();
        final AblyFlutterPlugin ably = new AblyFlutterPlugin();
        registrar.addNewIntentListener(ably);
        ably.setupChannels(registrar.messenger(), applicationContext);
    }

    private void setupChannels(BinaryMessenger messenger, Context applicationContext) {
        final MethodCodec codec = createCodec();

        final StreamsChannel streamsChannel = new StreamsChannel(messenger, "io.ably.flutter.stream", codec);
        streamsChannel.setStreamHandlerFactory(arguments -> new AblyEventStreamHandler(applicationContext));

        methodChannel = new MethodChannel(messenger, "io.ably.flutter.plugin", codec);
        methodCallHandler = new AblyMethodCallHandler(
            methodChannel,
            // Called when `registerAbly` platform method is call
            // (usually when app restarts or hot-restart, but not hot-reload)
            streamsChannel::reset,
            applicationContext
        );
        methodChannel.setMethodCallHandler(methodCallHandler);
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
        isActivityRunning = true;
        mainActivity = binding.getActivity();
        binding.addOnNewIntentListener(this);
        Intent intent = mainActivity.getIntent();
        doIfIntentContainsRemoteMessage(intent, (message) -> {
            // Only send the RemoteMessage to the dart side if it was actually a RemoteMessage.
            methodCallHandler.setRemoteMessageFromUserTapLaunchesApp(message);
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        mainActivity = binding.getActivity();
        binding.addOnNewIntentListener(this);
    }

    // This method does not get called when the app goes into the background
    @Override
    public void onDetachedFromActivity() {
        isActivityRunning = false;
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        mainActivity.setIntent(intent);
        doIfIntentContainsRemoteMessage(intent, (message) -> {
            methodChannel.invokeMethod(PlatformConstants.PlatformMethod.pushOnNotificationTap, message);
        });
        return false;
    }

    private Boolean doIfIntentContainsRemoteMessage(Intent intent, CompletionHandlerWithRemoteMessage completionHandler) {
        Bundle extras = intent.getExtras();
        if (extras == null) {
            return false;
        }
        RemoteMessage message = new RemoteMessage(intent.getExtras());
        if (message.getData().size() > 0) {
            completionHandler.call(message);
            return true;
        }
        return false;
    }
}
