package io.ably.flutter.plugin.push;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;

import io.ably.lib.push.ActivationContext;
import io.ably.lib.types.RegistrationToken;

// We listen to the message using a broadcast receiver (`AblyFlutterMessagingReceiver`)
// instead of a Service (`AblyFlutterMessagingService`) because multiple broadcast
// listeners can be called in response to an intent filter, but only 1 activity/ service
// can be called. See `android:permission` on `<receiver>`
// [docs](https://developer.android.com/guide/topics/manifest/receiver-element#prmsn) for more information.
//
// This broadcast receiver is static (declared in  `AndroidManifest.xml`)
public class AblyFlutterMessagingService extends FirebaseMessagingService {
  @Override
  public void onNewToken(@NonNull String registrationToken) {
    ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, registrationToken);
    super.onNewToken(registrationToken);
  }

  // This class does not override onMessageReceived, since [AblyFlutterMessagingService] will
  // listen to `com.google.android.c2dm.intent.RECEIVE`.
}
