package io.ably.flutter.plugin_example;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import io.ably.lib.push.ActivationContext;
import io.ably.lib.types.RegistrationToken;

/// This service will only be listening/ launched in response to broadcast intents if it is
/// declared in the AndroidManifest.xml, and is present in the final merged manifest of the app.
public class PushMessagingService extends FirebaseMessagingService {
  public static final String PUSH_NOTIFICATION_ACTION = "io.ably.flutter.plugin_example.PUSH_NOTIFICATION_MESSAGE";
  public static final String PUSH_DATA_ACTION = "io.ably.broadcast.PUSH_DATA_MESSAGE";

  // This method is called when either:
  //   - `notification` is *not* set in the message, OR
  //   - App is in foreground
  // To just show a basic notification (title & text) to the user, just  send the `notification`
  //   key in the push payload, we don't need to anything in this method.
  // To create enhanced notifications (e.g. with buttons, text entry), users should send a
  // data message (without `notification` payload) and then create a notification locally here.
  @Override
  public void onMessageReceived(@NonNull RemoteMessage message) {
    RemoteMessage.Notification messageNotification = message.getNotification();
    if (messageNotification != null) {
      Intent intent = new Intent(PUSH_NOTIFICATION_ACTION);
      intent.putExtra("remoteMessage", message);
      LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
    } else {
      Intent intent = new Intent(PUSH_DATA_ACTION);
      intent.putExtra("remoteMessage", message);
      LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
    }
  }

  @Override
  public void onNewToken(@NonNull String registrationToken) {
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, registrationToken);
    super.onNewToken(registrationToken);
  }
}
