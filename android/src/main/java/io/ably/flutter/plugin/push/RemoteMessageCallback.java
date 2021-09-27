package io.ably.flutter.plugin.push;

import com.google.firebase.messaging.RemoteMessage;

public interface RemoteMessageCallback {
  void onRemoteMessage(RemoteMessage message);
}
