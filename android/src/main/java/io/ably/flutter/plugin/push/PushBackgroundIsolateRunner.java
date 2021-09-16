package io.ably.flutter.plugin.push;

import static android.content.Context.MODE_PRIVATE;
import static io.ably.flutter.plugin.generated.PlatformConstants.PlatformMethod.pushOnBackgroundMessage;
import static io.ably.flutter.plugin.generated.PlatformConstants.PlatformMethod.pushSetOnBackgroundMessage;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.messaging.RemoteMessage;

import io.ably.flutter.plugin.AblyMessageCodec;
import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMethodCodec;

public class PushBackgroundIsolateRunner implements MethodChannel.MethodCallHandler {
  private static final String TAG = PushBackgroundIsolateRunner.class.getName();
  private static final String SHARED_PREFERENCES_KEY = "io.ably.flutter.plugin.push.PushBackgroundIsolate.SHARED_PREFERENCES_KEY";
  private static final String BACKGROUND_MESSAGE_HANDLE_KEY = "BACKGROUND_MESSAGE_HANDLE_KEY";
  private static final String DART_ENTRYPOINT_HANDLE_KEY = "DART_ENTRYPOINT_HANDLE_KEY";
  @Nullable
  private FlutterEngine flutterEngine;

  private final BroadcastReceiver.PendingResult asyncCompletionHandlerPendingResult;
  private final RemoteMessage remoteMessage;
  private MethodChannel backgroundMethodChannel;

  // TODO confirm this is called on main thread
  public PushBackgroundIsolateRunner(Context context, BroadcastReceiver.PendingResult asyncCompletionHandlerPendingResult, RemoteMessage message) {
    this.asyncCompletionHandlerPendingResult = asyncCompletionHandlerPendingResult;
    this.remoteMessage = message;

    FlutterLoader flutterLoader = FlutterInjector.instance().flutterLoader();
    flutterLoader.startInitialization(context); // Starts initialization when Dart VM is not yet running, e.g. The main app is terminated.
    flutterLoader.ensureInitializationComplete(context, null); // Blocks the thread so we can be sure the future methods will be fine. This is probably optional.
    flutterEngine = new FlutterEngine(context, null);
    DartExecutor executor = flutterEngine.getDartExecutor();
    backgroundMethodChannel = new MethodChannel(executor.getBinaryMessenger(), "io.ably.flutter.plugin.background", new StandardMethodCodec(new AblyMessageCodec()));
    backgroundMethodChannel.setMethodCallHandler(this);
    // Get and launch the users app isolate manually:
    DartExecutor.DartEntrypoint appEntrypoint = DartExecutor.DartEntrypoint.createDefault();
    executor.executeDartEntrypoint(appEntrypoint);
  }

  /**
   * This method is called when the main app is running and the user sets the background handler.
   *
   * @param backgroundMessageHandlerHandle
   */
  public static void setBackgroundMessageHandler(Context context, Long backgroundMessageHandlerHandle) {
    SharedPreferences preferences = context.getApplicationContext().getSharedPreferences(SHARED_PREFERENCES_KEY, MODE_PRIVATE);
    preferences.edit().putLong(BACKGROUND_MESSAGE_HANDLE_KEY, backgroundMessageHandlerHandle).apply();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals("onFinish")) {
      asyncCompletionHandlerPendingResult.finish();
      result.success(true);
    } else if (call.method.equals(pushSetOnBackgroundMessage)) {
      // This signals that the manually spawned app is ready to receive a message to handle.
      // We ask the user to set the background message handler early on.
      backgroundMethodChannel.invokeMethod(pushOnBackgroundMessage, remoteMessage, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
              finish();
            }

            @Override
            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
              Log.e(TAG, String.format("pushOnBackgroundMessage method call from Java to Dart returned error.\n " +
                  "errorCode: %s\n" +
                  "errorMessage: %s\n" +
                  "errorDetails: %s\n", errorCode, errorMessage, errorDetails));
              finish();
            }

            @Override
            public void notImplemented() {
              Log.e(TAG, "Method: pushOnBackgroundMessage did not receive message on dart side. " +
                  "Either the binding has not been initialized or the method call handler was not registered to receive this method.");
              finish();
            }
          }
      );
    } else {
      result.notImplemented();
    }
  }

  private void finish() {
    assert flutterEngine != null;
    flutterEngine.destroy();
    asyncCompletionHandlerPendingResult.finish();
    flutterEngine = null;
  }
}
