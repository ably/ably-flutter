package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.List;
import java.util.concurrent.Executors;

import io.ably.flutter.plugin.AblyFlutter;

public class FirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = FirebaseMessagingReceiver.class.getName();

  @Nullable
  private PendingResult asyncProcessingPendingResult = null;

  @Nullable
  private FlutterBackgroundMessageProcessingCompleteReceiver flutterBackgroundMessageProcessingCompleteReceiver = null;

  @Override
  public void onReceive(Context context, Intent intent) {
    listenForFlutterApplicationToFinishProcessingMessage(context);

    Executors.newSingleThreadExecutor().execute(() -> {
      sendMessageToFlutterApplication(context, intent);
    });
  }

  /**
   * Launches a broadcast receiver ([BackgroundMessageProcessingCompleteReceiver]) so that the
   * enclosing receiver (FirebaseMessagingReceiver), can be informed when the Flutter
   * application completes. The Flutter application also has a receiver
   * (PushMessagingEventHandlers.BroadcastReceiver) to listen to messages from this receiver
   * (FirebaseMessagingReceiver).
   */
  private void listenForFlutterApplicationToFinishProcessingMessage(Context context) {
    // Wait for Flutter application to process message
    // At the end of the receiver's execution time (and user's application processing the message)
    // , Firebase messaging library will automatically create a notification.
    // On iOS, the notification may be shown before the  message is processed by the application.
    // goAsync() also increases the execution time from 10s/ 20s (depending on API level) to 30s
    if (flutterBackgroundMessageProcessingCompleteReceiver == null) {
      flutterBackgroundMessageProcessingCompleteReceiver = new FlutterBackgroundMessageProcessingCompleteReceiver(context);
      asyncProcessingPendingResult = goAsync();
    }
  }

  private void sendMessageToFlutterApplication(@NonNull final Context context,
                                               @NonNull final Intent intent) {
    final Boolean isApplicationInForeground = isApplicationInForeground(context);

    if (isApplicationInForeground) {
      PushMessagingEventHandlers.sendMessageToFlutterApp(context, intent);
    } else if (AblyFlutter.isMainActivityRunning) {
      PushMessagingEventHandlers.sendBackgroundMessageToFlutterApp(context, intent);
    } else {
      new ManualFlutterApplicationRunner(context, this, intent);
    }
  }

  private Boolean isApplicationInForeground(@NonNull final Context context) {
    final ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    // This only shows processes for the current android app.
    final List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();

    if (appProcesses == null) {
      // If no processes are running, appProcesses are null, not an empty list.
      // The user's app is definitely not in the foreground if no processes are running.
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
  class FlutterBackgroundMessageProcessingCompleteReceiver extends BroadcastReceiver {
    FlutterBackgroundMessageProcessingCompleteReceiver(final Context context) {
      final IntentFilter filter = new IntentFilter();
      filter.addAction(PUSH_ON_BACKGROUND_MESSAGE_PROCESSING_COMPLETE);
      LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      if (flutterBackgroundMessageProcessingCompleteReceiver != null) {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(flutterBackgroundMessageProcessingCompleteReceiver);
        flutterBackgroundMessageProcessingCompleteReceiver = null;
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
      asyncProcessingPendingResult = null;
    }
  }
}
