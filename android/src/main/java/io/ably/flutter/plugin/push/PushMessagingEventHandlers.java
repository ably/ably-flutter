package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.generated.PlatformConstants.PlatformMethod.pushOnShowNotificationInForeground;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.util.NotificationUtilities;
import io.flutter.plugin.common.MethodChannel;

final public class PushMessagingEventHandlers {
  private static final String TAG = PushMessagingEventHandlers.class.getName();
  public static final String PUSH_ON_MESSAGE_RECEIVED = "io.ably.ably_flutter.PUSH_ON_MESSAGE_RECEIVED";
  public static final String PUSH_ON_BACKGROUND_MESSAGE_RECEIVED = "io.ably.ably_flutter.PUSH_ON_BACKGROUND_MESSAGE_RECEIVED";
  public static final String PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE = "io.ably.ably_flutter.PUSH_ON_BACKGROUND_MESSAGE_COMPLETE";
  static PushMessagingEventHandlers instance;

  public static void instantiate(Context context, MethodChannel methodChannel) {
    if (instance == null) {
      instance = new PushMessagingEventHandlers(context, methodChannel);
    }
  }

  private PushMessagingEventHandlers(Context context, MethodChannel methodChannel) {
    new BroadcastReceiver(context, methodChannel);
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

    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      Bundle intentExtras = intent.getExtras();
      RemoteMessage message = new RemoteMessage(intent.getExtras());
      switch (action) {
        case PUSH_ON_MESSAGE_RECEIVED:
          sendRemoteMessageToDartSide(PlatformConstants.PlatformMethod.pushOnMessage,
              message,
              () -> displayForegroundNotification(context, intentExtras, () -> finish(context)));
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

    private void displayForegroundNotification(Context context, Bundle intentExtras, Runnable finish) {
      RemoteMessage message = new RemoteMessage(intentExtras);
      if (message.getNotification() == null) {
        return;
      }

      methodChannel.invokeMethod(pushOnShowNotificationInForeground, message, new MethodChannel.Result() {
        @Override
        public void success(@Nullable Object result) {
          Boolean willShowNotification = (Boolean) result;
          RemoteMessage.Notification notification = message.getNotification();
          assert (notification != null);
          if (willShowNotification) {
            NotificationUtilities.showNotification(context, message, intentExtras);
          }
          finish.run();
        }

        @Override
        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
          System.out.printf("`pushOnShowNotificationInForeground` failed: %s%n", errorMessage);
          finish.run();
        }

        @Override
        public void notImplemented() {
          System.out.println("`pushOnShowNotificationInForeground` not implemented.");
          finish.run();
        }
      });
    }

    // Used to send the RemoteMessage, which may (or may not) contain Data and RemoteMessage.Notification
    private void sendRemoteMessageToDartSide(String methodName, RemoteMessage remoteMessage, Runnable callback) {
      this.methodChannel.invokeMethod(methodName, remoteMessage, new MethodChannel.Result() {
        @Override
        public void success(@Nullable Object result) {
          if (callback != null) {
            callback.run();
          }
        }

        @Override
        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
          if (callback != null) {
            callback.run();
          }
        }

        @Override
        public void notImplemented() {
          System.out.printf("`%s` platform method not implemented. %n", methodName);
          if (callback != null) {
            callback.run();
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
