package io.ably.flutter.plugin.push;

import com.google.firebase.messaging.RemoteMessage;

public interface RemoteMessageCallback {
    void onReceive(RemoteMessage message);
}
