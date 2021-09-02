package io.ably.flutter.plugin.push;

import static io.ably.flutter.plugin.push.PushNotificationEventHandlers.PUSH_ON_MESSAGE_RECEIVED;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

public class AblyFlutterMessagingReceiver extends BroadcastReceiver {
  // TODO save the message, for reading once the application is launched.

  @Override
  public void onReceive(Context context, Intent intent) {
    // Send to Flutter application
    Intent onMessageReceivedIntent = new Intent(PUSH_ON_MESSAGE_RECEIVED);
    LocalBroadcastManager.getInstance(context).sendBroadcast(onMessageReceivedIntent);
  }
}
