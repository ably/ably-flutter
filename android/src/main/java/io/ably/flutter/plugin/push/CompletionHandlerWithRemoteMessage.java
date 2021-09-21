package io.ably.flutter.plugin.push;

import com.google.firebase.messaging.RemoteMessage;

public interface CompletionHandlerWithRemoteMessage {
  void onRemoteMessage(RemoteMessage message);
}
