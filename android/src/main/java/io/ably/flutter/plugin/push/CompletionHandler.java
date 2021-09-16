package io.ably.flutter.plugin.push;

import com.google.firebase.messaging.RemoteMessage;

interface CompletionHandler {
  void call();
}

