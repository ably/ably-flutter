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
    //FCM data is received here.
    // TODO Listen for `PUSH_NOTIFICATION_ACTION` in the flutterActivity? and there, call the callback set by the user dart-side?
    Intent intent = new Intent(PUSH_NOTIFICATION_ACTION);
    LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
  }

  @Override
  public void onNewToken(@NonNull String s) {
    super.onNewToken(s);
    //Store token in Ably
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, s);
  }
}
