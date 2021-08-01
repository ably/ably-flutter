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

  @Override
  public void onMessageReceived(@NonNull RemoteMessage message) {
    Intent intent = new Intent(PUSH_NOTIFICATION_ACTION);
    LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
    // TODO Implement Push Notifications listener https://github.com/ably/ably-flutter/issues/141
    // Call a callback in dart side so the user can handle it.
    // TODO Listen for `PUSH_NOTIFICATION_ACTION` and there, perform your own logic.
  }

  @Override
  public void onNewToken(@NonNull String s) {
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, s);
    super.onNewToken(s);
  }
}
 