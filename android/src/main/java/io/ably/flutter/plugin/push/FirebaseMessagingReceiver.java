package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE;
import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_BACKGROUND_MESSAGE_RECEIVED;
import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_MESSAGE_RECEIVED;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import java.util.List;

import io.ably.flutter.plugin.AblyFlutterPlugin;

public class FirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = FirebaseMessagingReceiver.class.getName();

  @Nullable
  private PendingResult asyncProcessingPendingResult = null;

  @Nullable
  private BackgroundMessageProcessingCompleteReceiver backgroundMessageProcessingCompleteReceiver = null;

  @Override
  public void onReceive(Context context, Intent intent) {
    setupFlutterApplicationProcessingCompletionReceiver(context);
    sendMessageToFlutterApplication(context, intent);
  }

  /**
   * Launches a broadcast receiver ([BackgroundMessageProcessingCompleteReceiver]) so that the
   * enclosing receiver (FirebaseMessagingReceiver), can be informed when the Flutter
   * application completes. The Flutter application also has a receiver
   * (PushMessagingEventHandlers.BroadcastReceiver) to listen to messages from this receiver
   * (FirebaseMessagingReceiver).
   */
  private void setupFlutterApplicationProcessingCompletionReceiver(Context context) {
    // Wait for Flutter application to process message
    // At the end of the receiver's execution time (and user's application processing the message)
    // , Firebase messaging library will automatically create a notification.
    // On iOS, the notification may be shown before the  message is processed by the application.
    // goAsync() also increases the execution time from 10s/ 20s (depending on API level) to 30s
    if (backgroundMessageProcessingCompleteReceiver == null) {
      backgroundMessageProcessingCompleteReceiver = new BackgroundMessageProcessingCompleteReceiver(context);
      asyncProcessingPendingResult = goAsync();
    }
  }

  private void sendMessageToFlutterApplication(Context context, Intent intent) {
    final RemoteMessage message = new RemoteMessage(intent.getExtras());
    final Boolean isApplicationInForeground = isApplicationInForeground(context);

    if (isApplicationInForeground) {
      // Send message to Dart side app already running
      final Intent onMessageReceivedIntent = new Intent(PUSH_ON_MESSAGE_RECEIVED);
      onMessageReceivedIntent.putExtras(intent.getExtras());
      LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
    } else if (AblyFlutterPlugin.isMainActivityRunning) {
      // Flutter is already running, just send a background message to it.
      final Intent onMessageReceivedIntent = new Intent(PUSH_ON_BACKGROUND_MESSAGE_RECEIVED);
      onMessageReceivedIntent.putExtras(intent.getExtras());
      LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
    } else {
      // No existing Flutter Activity is running, create a FlutterEngine and pass it the RemoteMessage
      new PushBackgroundIsolateRunner(context, this, message);
    }

  }

  private Boolean isApplicationInForeground(final Context context) {
    final ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    // This only shows processes for the current android app.
    final List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();

    if (appProcesses == null) {
      // If no processes are running, appProcesses are null, not an empty list.
      // There is definitely not an application in foreground if no processes are running.
      return false;
    }

    for (ActivityManager.RunningAppProcessInfo process : appProcesses) {
      // Importance is IMPORTANCE_SERVICE (not IMPORTANCE_FOREGROUND)
      //  - when app was terminated, or
      //  - when app is in the background, or
      //  - when screen is locked, including when app was in foreground.
      if (process.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
        // App is in the foreground
        return true;
      }
    }

    return false;
  }

  /**
   * A dynamic broadcast receiver registered to listen to a `PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE`
   */
  class BackgroundMessageProcessingCompleteReceiver extends BroadcastReceiver {
    BackgroundMessageProcessingCompleteReceiver(final Context context) {
      final IntentFilter filter = new IntentFilter();
      filter.addAction(PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE);
      LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      if (backgroundMessageProcessingCompleteReceiver != null) {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(backgroundMessageProcessingCompleteReceiver);
        backgroundMessageProcessingCompleteReceiver = null;
      }

      String action = intent.getAction();
      if (action.equals(PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE)) {
        finish();
      } else {
        Log.e(TAG, String.format("Received unknown intent action: %s", action));
      }
    }
  }

  void finish() {
    if (asyncProcessingPendingResult != null) {
      asyncProcessingPendingResult.finish();
    }
  }
}
