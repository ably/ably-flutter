package io.ably.flutter.plugin.util;

import static com.google.firebase.messaging.CommonNotificationBuilder.FCM_FALLBACK_NOTIFICATION_CHANNEL;
import static com.google.firebase.messaging.CommonNotificationBuilder.METADATA_DEFAULT_CHANNEL_ID;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.CommonNotificationBuilder;
import com.google.firebase.messaging.NotificationParams;
import com.google.firebase.messaging.RemoteMessage;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Date;

public class NotificationUtilities {
  private static final String TAG = NotificationUtilities.class.getName();

  /**
   * This method uses Firebase messaging's public `CommonNotificationBuilder.createNotificationInfo`
   * method (which probably wasn't meant to be public).
   *
   * @param context
   * @param remoteMessage
   * @param intentExtras
   */
  public static void showNotification(Context context, RemoteMessage remoteMessage, Bundle intentExtras) {
    RemoteMessage.Notification notification = remoteMessage.getNotification();
    Notification localNotification = NotificationUtilities.createLocalNotification(context, notification);
    Bundle manifestMetadata = getManifestMetadata(context.getPackageManager(), context.getPackageName());
    NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    // Create a unique notification ID so notifications don't share the same ID, as per https://stackoverflow.com/a/28251192/7365866
    int notificationId = (int) ((new Date().getTime() / 1000L) % Integer.MAX_VALUE);
    NotificationParams params = new NotificationParams(intentExtras);
    CommonNotificationBuilder.DisplayNotificationInfo notificationInfo = CommonNotificationBuilder.createNotificationInfo(
        context,
        context.getPackageName(),
        params,
        getOrCreateChannel(context, notification.getChannelId()),
        context.getResources(),
        context.getPackageManager(),
        manifestMetadata
        );
    notificationManager.notify(notificationInfo.tag, notificationInfo.id, notificationInfo.notificationBuilder.build());
    //    notificationManager.notify(notificationId, localNotification);
  }

  /**
   * The [firebase-android-sdk](https://github.com/firebase/firebase-android-sdk) only shows
   * notifications when the app is not in the foreground. iOS, this is configurable. To make
   * this behaviour consistent between Android and iOS, we allow users to configure notifications
   * when the app is in the foreground, by creating a notification for them, which closely mimics
   * what firebase-android-sdk creates when the app is not in the foreground.
   *
   * @param context
   * @param notification
   * @return
   */
  public static Notification createLocalNotification(Context context, RemoteMessage.Notification notification) {
    @Nullable String notificationChannelId = NotificationUtilities.getOrCreateChannel(context, notification.getChannelId());
    NotificationCompat.Builder builder = new NotificationCompat.Builder(context, notificationChannelId)
        .setContentTitle(notification.getTitle())
        .setContentText(notification.getBody())
        .setSmallIcon(context.getApplicationContext().getApplicationInfo().icon)
        .setPriority(NotificationCompat.PRIORITY_DEFAULT);
    if (notification.getImageUrl() != null) {
      downloadImage(notification.getImageUrl(), (bitmap) -> {
        builder.setLargeIcon(bitmap);
        builder.setStyle(new NotificationCompat.BigPictureStyle()
            .bigPicture(bitmap)
            .bigLargeIcon(null));
        builder.build();
      });
    }
    return builder.build();
  }


  private interface DownloadImageCallback {
    void finish(Bitmap bitmap);
  }

  private static void downloadImage(Uri imageUri, DownloadImageCallback callback) {
    try {
      InputStream in = new URL(imageUri.toString()).openStream();
      Bitmap bitmap = BitmapFactory.decodeStream(in);
      callback.finish(bitmap);
    } catch (IOException e) {
      Log.e(TAG, String.format("Failed to download image from imageUri: %s", imageUri), e);
    }
  }

  // Get the default one the user set in their manifest. We just use the same one as Firebase's default channel.
  // This method was adapted from [firebase-android-sdk's CommonNotificationBuilder.java](https://github.com/firebase/firebase-android-sdk/blob/master/firebase-messaging/src/main/java/com/google/firebase/messaging/CommonNotificationBuilder.java).
  private static String getOrCreateChannel(Context context, String channelId) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      return null;
    }
    Bundle manifestMetadata = getManifestMetadata(context.getPackageManager(), context.getPackageName());
    NotificationManager notificationManager = context.getSystemService(NotificationManager.class);

    // If the channel already exists, just return the channelID that was passed in.
    if (!TextUtils.isEmpty(channelId)) {
      if (notificationManager.getNotificationChannel(channelId) != null) {
        return channelId;
      } else {
        Log.w(
            TAG,
            "Notification Channel requested ("
                + channelId
                + ") has not been created by the app."
                + " Manifest configuration, or default, value will be used.");
      }
    }

    String manifestChannel = manifestMetadata.getString(METADATA_DEFAULT_CHANNEL_ID);
    if (!TextUtils.isEmpty(manifestChannel)) {
      if (notificationManager.getNotificationChannel(manifestChannel) != null) {
        return manifestChannel;
      } else {
        Log.w(
            TAG,
            "Notification Channel set in AndroidManifest.xml has not been"
                + " created by the app. Default value will be used.");
      }
    } else {
      Log.w(
          TAG,
          "Missing Default Notification Channel metadata in AndroidManifest."
              + " Default value will be used.");
    }

    // Create the default channel if it has not been created yet.
    if (notificationManager.getNotificationChannel(FCM_FALLBACK_NOTIFICATION_CHANNEL) == null) {
//       The Firebase SDK reads the "user visible name of the channel" from its string.xml using the code below.
//          int channelLabelResourceId = context.getResources().getIdentifier(
//                  FCM_FALLBACK_NOTIFICATION_CHANNEL_LABEL, "string", context.getPackageName());
//      String channelName = context.getString(channelLabelResourceId);
//      Instead, we just hardcode this as "Miscellaneous" below:

      notificationManager.createNotificationChannel(
          new NotificationChannel(
              // channel id
              FCM_FALLBACK_NOTIFICATION_CHANNEL,
              // user visible name of the channel
              "Miscellaneous",
              // shows everywhere, makes noise, but does not visually intrude.
              NotificationManager.IMPORTANCE_DEFAULT));
    }

    return FCM_FALLBACK_NOTIFICATION_CHANNEL;
  }

  private static Bundle getManifestMetadata(PackageManager packageManager, String packageName) {
    try {
      ApplicationInfo info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA);
      if (info != null && info.metaData != null) {
        return info.metaData;
      }
    } catch (PackageManager.NameNotFoundException e) {
      Log.w(TAG, "Couldn't get own application info: " + e);
    }

    return Bundle.EMPTY;
  }
}
