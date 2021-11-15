package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.generated.PlatformConstants.PlatformMethod.pushOnShowNotificationInForeground;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.flutter.plugin.common.MethodChannel;

/**
 * This class is used when the application is in the **foreground** or **background**, but not when
 * **terminated**. See [PushTerminatedIsolateRunner.java] to see where push notifications being
 * handled whilst the app is terminated.
 */
final public class PushMessagingEventHandlers {
  private static final String TAG = PushMessagingEventHandlers.class.getName();
  public static final String PUSH_ON_MESSAGE_RECEIVED = "io.ably.ably_flutter.PUSH_ON_MESSAGE_RECEIVED";
  public static final String PUSH_ON_BACKGROUND_MESSAGE_RECEIVED = "io.ably.ably_flutter.PUSH_ON_BACKGROUND_MESSAGE_RECEIVED";
  public static final String PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE = "io.ably.ably_flutter.PUSH_ON_BACKGROUND_MESSAGE_COMPLETE";
  static PushMessagingEventHandlers instance;

  /**
   * Replaces the existing instance if required. this is because the latest methodChannel is the
   * most important because it is from the latest plugin registration.
   * @param context
   * @param methodChannel
   */
  public static void reset(Context context, MethodChannel methodChannel) {
    if (instance != null) {
      instance.close(context);
    }
    instance = new PushMessagingEventHandlers(context, methodChannel);
  }

  private void close(Context context) {
    this.broadcastReceiver.close(context);
  }

  private final BroadcastReceiver broadcastReceiver;
  private PushMessagingEventHandlers(Context context, MethodChannel methodChannel) {
    this.broadcastReceiver = new BroadcastReceiver(context, methodChannel);
  }

  // Send message to Dart side app already running
  public static void sendMessageToFlutterApp(@NonNull final Context context, @NonNull final Intent intent) {
    final Intent onMessageReceivedIntent = new Intent(PUSH_ON_MESSAGE_RECEIVED);
    onMessageReceivedIntent.putExtras(intent.getExtras());
    LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
  }

  // Flutter is already running, just send a background message to it.
  public static void sendBackgroundMessageToFlutterApp(Context context, Intent intent) {
    final Intent onMessageReceivedIntent = new Intent(PUSH_ON_BACKGROUND_MESSAGE_RECEIVED);
    onMessageReceivedIntent.putExtras(intent.getExtras());
    LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
  }

  private static class BroadcastReceiver extends android.content.BroadcastReceiver {
    MethodChannel methodChannel;

    BroadcastReceiver(Context context, MethodChannel methodChannel) {
      register(context);
      this.methodChannel = methodChannel;
    }

    private void register(Context context) {
      IntentFilter filter = new IntentFilter();
      filter.addAction(PUSH_ON_MESSAGE_RECEIVED);
      filter.addAction(PUSH_ON_BACKGROUND_MESSAGE_RECEIVED);
      LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    void close(Context context) {
      LocalBroadcastManager.getInstance(context).unregisterReceiver(this);
      this.methodChannel = null;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      RemoteMessage message = new RemoteMessage(intent.getExtras());
      switch (action) {
        case PUSH_ON_MESSAGE_RECEIVED:
          sendRemoteMessageToDartSide(PlatformConstants.PlatformMethod.pushOnMessage,
              message,
              () -> finish(context));
          break;
        case PUSH_ON_BACKGROUND_MESSAGE_RECEIVED:
          sendRemoteMessageToDartSide(PlatformConstants.PlatformMethod.pushOnBackgroundMessage,
              message,
              () -> finish(context));
          break;
        default:
          Log.e(TAG, String.format("Received unknown intent action: %s", action));
          break;
      }
    }

    private interface CompletionCallback {
      void onComplete();
    }

    // Used to send the RemoteMessage, which may (or may not) contain Data and RemoteMessage.Notification
    private void sendRemoteMessageToDartSide(String methodName, RemoteMessage remoteMessage, CompletionCallback callback) {
      this.methodChannel.invokeMethod(methodName, remoteMessage, new MethodChannel.Result() {
        @Override
        public void success(@Nullable Object result) {
          if (callback != null) {
            callback.onComplete();
          }
        }

        @Override
        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
          if (callback != null) {
            callback.onComplete();
          }
        }

        @Override
        public void notImplemented() {
          System.out.printf("`%s` platform method not implemented. %n", methodName);
          if (callback != null) {
            callback.onComplete();
          }
        }
      });
    }

    void finish(final Context context) {
      final Intent backgroundMessageCompleteIntent = new Intent(PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE);
      LocalBroadcastManager.getInstance(context).sendBroadcast(backgroundMessageCompleteIntent);
    }
  }
}
