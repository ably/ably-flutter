package io.ably.flutter.plugin.push;

import static android.content.Context.MODE_PRIVATE;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.AssetManager;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.RemoteMessage;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterCallbackInformation;

public class PushBackgroundIsolateService implements MethodChannel.MethodCallHandler {
  private static final String TAG = PushBackgroundIsolateService.class.getName();
  private static final String SHARED_PREFERENCES_KEY = "io.ably.flutter.plugin.push.PushBackgroundIsolate.SHARED_PREFERENCES_KEY";
  private static final String BACKGROUND_MESSAGE_KEY = "BACKGROUND_MESSAGE_KEY";

  private final Context context;
  private final Long backgroundMessageHandlerHandle;
  private final BroadcastReceiver.PendingResult asyncCompletionHandlerPendingResult;
  private final RemoteMessage remoteMessage;
  private MethodChannel backgroundMethodChannel;

  /**
   * This method is called when the main app is running and the user sets the background handler.
   *
   * @param context
   * @param backgroundMessageHandlerHandle
   */
  public static void setBackgroundMessageHandler(Context context, Long backgroundMessageHandlerHandle) {
    SharedPreferences preferences = context.getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_KEY, MODE_PRIVATE);
    preferences.edit().putLong(BACKGROUND_MESSAGE_KEY, backgroundMessageHandlerHandle).apply();
  }

  // TODO confirm this is called on main thread
  public PushBackgroundIsolateService(Context context, BroadcastReceiver.PendingResult asyncCompletionHandlerPendingResult, RemoteMessage message) {
    backgroundMessageHandlerHandle = getBackgroundMessageHandler(context);
    this.context = context;
    this.asyncCompletionHandlerPendingResult = asyncCompletionHandlerPendingResult;
    this.remoteMessage = message;

    FlutterLoader flutterLoader = FlutterInjector.instance().flutterLoader();
    // TODO are these 2 method calls below necessary?
    flutterLoader.startInitialization(context);
    flutterLoader.ensureInitializationComplete(context, null);
    AssetManager assetManager = context.getApplicationContext().getAssets();
    String appBundlePath = flutterLoader.findAppBundlePath();

    FlutterEngine flutterEngine = new FlutterEngine(context, null);
    DartExecutor executor = flutterEngine.getDartExecutor();
    FlutterCallbackInformation callbackInformation = FlutterCallbackInformation.lookupCallbackInformation(backgroundMessageHandlerHandle);
    backgroundMethodChannel = new MethodChannel(executor, "io.ably.flutter.plugin.background");
    backgroundMethodChannel.setMethodCallHandler(this);
    DartExecutor.DartCallback dartCallback = new DartExecutor.DartCallback(assetManager, appBundlePath, callbackInformation);
    executor.executeDartCallback(dartCallback);
  }

  /**
   * This method is called when this isolate is launching and the app may not be running,
   * to get the reference to the background message handler the user set on the dart side.
   *
   * @param context
   * @return
   */
  private Long getBackgroundMessageHandler(Context context) {
    SharedPreferences preferences = context.getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_KEY, MODE_PRIVATE);
    return preferences.getLong(BACKGROUND_MESSAGE_KEY, 0);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals("onReady")) {
      // TODO implement an entry point for the isolate
      // TODO handle the message on the dart side
      backgroundMethodChannel.invokeMethod("onStart", remoteMessage);
    } else if (call.method.equals("onFinish")) {
      asyncCompletionHandlerPendingResult.finish();
      result.success(true);
    } else {
      result.notImplemented();
    }
  }
}
