package io.ably.flutter.plugin.push;

import com.google.firebase.messaging.RemoteMessage;

public interface CompletionHandlerWithRemoteMessage {
  void call(RemoteMessage message);
}