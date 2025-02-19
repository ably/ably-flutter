package io.ably.flutter.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.RemoteMessage;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.push.RemoteMessageCallback;
import io.ably.flutter.plugin.push.PushActivationEventHandlers;
import io.ably.flutter.plugin.push.PushMessagingEventHandlers;
import io.ably.flutter.plugin.util.CipherParamsStorage;
import io.ably.lib.util.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.StandardMethodCodec;

public class AblyFlutter implements FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {
    private static final String TAG = AblyFlutter.class.getName();
    private Context applicationContext;
    private AblyMethodCallHandler methodCallHandler;
    private Activity mainActivity;
    public static Boolean isMainActivityRunning = false;
    private MethodChannel methodChannel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        setupChannels(flutterPluginBinding.getBinaryMessenger(), applicationContext);
        PushActivationEventHandlers.getInstance().registerReceiver();
    }

    private void setupChannels(BinaryMessenger messenger, Context applicationContext) {
        final MethodCodec codec = createCodec(new CipherParamsStorage());

        final StreamsChannel streamsChannel = new StreamsChannel(messenger, "io.ably.flutter.stream", codec);
        streamsChannel.setStreamHandlerFactory(arguments -> new AblyEventStreamHandler());

        methodChannel = new MethodChannel(messenger, "io.ably.flutter.plugin", codec);
        methodCallHandler = new AblyMethodCallHandler(methodChannel, streamsChannel, applicationContext);
        new BackgroundMethodCallHandler(messenger, codec);
        methodChannel.setMethodCallHandler(methodCallHandler);
        PushActivationEventHandlers.instantiate(applicationContext, methodChannel);
        PushMessagingEventHandlers.reset(applicationContext, methodChannel);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        PushActivationEventHandlers.getInstance().unregisterReceiver();
    }

    private static MethodCodec createCodec(CipherParamsStorage cipherParamsStorage) {
        return new StandardMethodCodec(new AblyMessageCodec(cipherParamsStorage));
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.v(TAG, "ActivityAware#onAttachedToActivity called");
        isMainActivityRunning = true;
        mainActivity = binding.getActivity();
        binding.addOnNewIntentListener(this);
        Intent intent = mainActivity.getIntent();
        handleRemoteMessageIntent(intent, (message) -> {
            // Only send the RemoteMessage to the dart side if it was actually a RemoteMessage.
            // Application is not yet running when notification is tapped
            methodCallHandler.setRemoteMessageFromUserTapLaunchesApp(message);
        });
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.v(TAG, "ActivityAware#onDetachedFromActivityForConfigChanges called");
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.v(TAG, "ActivityAware#onReattachedToActivityForConfigChanges called");
        mainActivity = binding.getActivity();
        binding.addOnNewIntentListener(this);
    }

    // This method gets called when an Activity is detached from the FlutterEngine, either when
    // 1. when a different Activity is being attached to the FlutterEngine, or 2. the Activity is
    // being destroyed. It does not get called when the app goes into the background.
    @Override
    public void onDetachedFromActivity() {
        Log.v(TAG, "ActivityAware#onDetachedFromActivity called");
        mainActivity = null;
        isMainActivityRunning = false;
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        if (mainActivity != null) {
          mainActivity.setIntent(intent);
        }
        handleRemoteMessageIntent(intent, (message) -> {
            // Application already running when notification is tapped
            methodChannel.invokeMethod(PlatformConstants.PlatformMethod.pushOnNotificationTap, message);
        });
        return false;
    }

    private void handleRemoteMessageIntent(Intent intent, RemoteMessageCallback callback) {
        Bundle extras = intent.getExtras();
        if (extras == null) {
            return;
        }
        final RemoteMessage message = new RemoteMessage(intent.getExtras());
        if (message.getData().size() > 0) {
            callback.onReceive(message);
        }
    }
}
