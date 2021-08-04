package io.ably.flutter.plugin.push;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import io.ably.lib.push.ActivationContext;
import io.ably.lib.types.RegistrationToken;

public class AblyPushNotificationService extends FirebaseMessagingService {
  public static final String PUSH_NOTIFICATION_ACTION = AblyPushNotificationService.class.getName() + ".PUSH_NOTIFICATION_MESSAGE";

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
  }

  @Override
  public void onNewToken(@NonNull String s) {
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, s);
    super.onNewToken(s);
  }
}
 