package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_BACKGROUND_MESSAGE_RECEIVED;
import static io.ably.flutter.plugin.push.PushMessagingEventHandlers.PUSH_ON_MESSAGE_RECEIVED;

import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import java.util.List;

import io.ably.flutter.plugin.AblyFlutterPlugin;
import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;

public class FirebaseMessagingReceiver extends BroadcastReceiver {
  private static final String TAG = FirebaseMessagingReceiver.class.getName();
  // When in the foreground, asyncCompletionHandlerPendingResult is needed because:
  // an image may be downloaded to show in the notification.
  // When in the background, asyncCompletionHandlerPendingResult is needed because:
  // A notification will be shown to the user immediately when this method completes if the
  // RemoteMessage contains a notification. To prevent this, goAsync is used, and completed
  // once the null result is returned from the dart side, to signal the user's background
  // handler has finished work.
  @Nullable
  public static PendingResult asyncCompletionHandlerPendingResult = null;
  // TODO save the message, for reading once the application is launched.

  // When in foreground: all called: notification, data, and both.
  // TODO When in background:
  // TODO When terminated:
  @Override
  public void onReceive(Context context, Intent intent) {
    Boolean isApplicationInForeground = isApplicationInForeground(context);
    RemoteMessage message = new RemoteMessage(intent.getExtras());
    RemoteMessage.Notification notification = message.getNotification();
    Boolean isNotificationMessage = notification != null;
    Boolean isDataMessage = !message.getData().isEmpty();
    asyncCompletionHandlerPendingResult = goAsync();

    FlutterLoader flutterLoader = FlutterInjector.instance().flutterLoader();
    Boolean isFlutterRunning = flutterLoader.initialized();

    if (isApplicationInForeground) {
      if (isNotificationMessage || isDataMessage) {
        // Send message to Dart side app already running
        Intent onMessageReceivedIntent = new Intent(PUSH_ON_MESSAGE_RECEIVED);
        onMessageReceivedIntent.putExtras(intent.getExtras());
        LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
      }
    } else if (AblyFlutterPlugin.isActivityRunning) {
      // Flutter is already running, just a background message to it.
      // TODO find a way to check if the app entry point is running. This might be a remnant Dart VM but the app isn't running
      // TODO investigate an issue where Dart VM was not running
      Intent onMessageReceivedIntent = new Intent(PUSH_ON_BACKGROUND_MESSAGE_RECEIVED);
      onMessageReceivedIntent.putExtras(intent.getExtras());
      LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
    } else {
      // If app in background or terminated, create a FlutterEngine and pass it the RemoteMessage:

      // We still create a separate isolate even if the FlutterEngine is running because the FlutterJNI might be detached. We could have tried to

      // It's not strictly necessary to create a FlutterEngine in all app-in-background cases.
      // However, it is much simpler to do so. Specifically, if the app is in the background
      // but not terminated, the FlutterEngine is still running, and the user defined dart callback
      // can be immediately called. However, if the application is terminated, then a FlutterEngine
      // is created. Programmatically checking if the application is in the background vs.
      // terminated is skipped for simplicity, and to avoid bumping the minSdkVersion to 21.
      // If we use minSdkVersion 21+, we can use getAppTasks. If the app was terminated, there are
      // no tasks.
        new PushBackgroundIsolateRunner(context, asyncCompletionHandlerPendingResult, message);

//       /** IF not terminated, but still in background **/
//      Intent onMessageReceivedIntent = new Intent(PUSH_ON_BACKGROUND_MESSAGE_RECEIVED);
//      onMessageReceivedIntent.putExtras(intent.getExtras());
//       LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);

      // Firebase messaging library will automatically create a notification.
    }
  }

  Boolean isApplicationInForeground(Context context) {
    ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
    // This only shows processes for the current android app.
    assert (appProcesses.size() == 1); // We have not tested multiple processes running on 1 app.

    for (ActivityManager.RunningAppProcessInfo process : appProcesses) {
      // Importance is IMPORTANCE_SERVICE (not IMPORTANCE_FOREGROUND)
      //  - when app was terminated, or
      //  - when app is in the background, or
      //  - when screen is locked, including when app was in foreground.
      if (process.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
        return true;
      }
    }

    return false;
  }
}
