package io.ably.flutter.plugin.push;

import androidx.annotation.NonNull;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import io.ably.lib.push.ActivationContext;
import io.ably.lib.types.RegistrationToken;

// This service exists to update Ably with the latest FCM registration token, and not
// to listen to any messages from FCM.
//
// We listen to the message using a broadcast receiver (`AblyFlutterMessagingReceiver`)
// instead of this/ a service because multiple broadcast listeners can be called
// in response to an intent filter, but only 1 activity/ service can be called. This means
// we won't conflict with other packages/ plugins and will be more reliable.
// See `android:permission` on `<receiver>`
// [docs](https://developer.android.com/guide/topics/manifest/receiver-element#prmsn) for more
// information.
public class PushMessagingService extends FirebaseMessagingService {
  @Override
  public void onNewToken(@NonNull String registrationToken) {
    ActivationContext.getActivationContext(this)
        .onNewRegistrationToken(RegistrationToken.Type.FCM, registrationToken);
    super.onNewToken(registrationToken);
  }

  @Override
  public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
    // This class does not do anything in onMessageReceived, since [AblyFlutterMessagingReceiver]
    // listens to `com.google.android.c2dm.intent.RECEIVE` declared in the manifest.
  }
}
