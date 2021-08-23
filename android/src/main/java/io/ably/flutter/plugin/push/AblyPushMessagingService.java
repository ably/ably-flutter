package io.ably.flutter.plugin.push;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.HashMap;
import java.util.Map;

import io.ably.lib.push.ActivationContext;
import io.ably.lib.types.RegistrationToken;
import io.ably.lib.util.Log;

public class AblyPushMessagingService extends FirebaseMessagingService {
  private static final String TAG = AblyPushMessagingService.class.getName();
  public static final String PUSH_NOTIFICATION_ACTION = TAG + ".PUSH_NOTIFICATION_MESSAGE";
  public static final String PUSH_DATA_ACTION = TAG + ".PUSH_DATA_MESSAGE";

  // This method is called when either:
  //   - `notification` is *not* set in the message, OR
  //   - App is in foreground
  // To just show a basic notification (title & text) to the user, just  send the `notification`
  //   key in the push payload, we don't need to anything in this method.
  // To create enhanced notifications (e.g. with buttons, text entry), users should send a
  // data message (without `notification` payload) and then create a notification locally here.
  @Override
  public void onMessageReceived(@NonNull RemoteMessage message) {
    Intent intent = new Intent(PUSH_NOTIFICATION_ACTION);
    intent.putExtra("remoteMessage", message);
    LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
    // TODO Implement Push Notifications listener https://github.com/ably/ably-flutter/issues/141
    // One approach: Listen for `PUSH_NOTIFICATION_ACTION` using a broadcast receiver and there, call the Ably dart side.

    Map<String, String> messageData = message.getData();
    // TODO are they doing this to turn map into hashmap, is there a better way?
    if(messageData.isEmpty()) { return; }
    HashMap<String, String> serialisableData = new HashMap<>();
    serialisableData.putAll(messageData);

    // TODO listen to the broadcasted intent
    RemoteMessage.Notification messageNotification = message.getNotification();
    if(messageNotification != null) {
      Log.i(TAG, "Received message notification: title = " + messageNotification.getTitle() + "; body = " + messageNotification.getBody());
      serialisableData.put("title", messageNotification.getTitle());
      serialisableData.put("body", messageNotification.getBody());
      broadcastIntent(PUSH_NOTIFICATION_ACTION, serialisableData);
    } else {
      Log.i(TAG, "Received data message");
      broadcastIntent(PUSH_DATA_ACTION, serialisableData);
    }
  }

  private void broadcastIntent(String action, HashMap<String, String> data) {
    Intent intent = new Intent();
    intent.setAction(action);
    intent.putExtra("data", data);
    LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
  }

  @Override
  public void onNewToken(@NonNull String registrationToken) {
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, registrationToken);
    super.onNewToken(registrationToken);
  }
}
