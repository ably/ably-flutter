package io.ably.flutter.plugin.push;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.messaging.RemoteMessage;

import io.flutter.plugin.common.MethodChannel;

public class PushNotificationEventHandlers {
  private static final String TAG = PushNotificationEventHandlers.class.getName();
  public static final String PUSH_ON_MESSAGE_RECEIVED = "io.ably.ably_flutter.PUSH_ON_MESSAGE_RECEIVED";

  static PushNotificationEventHandlers instance;
  final private MethodChannel methodChannel;
  final private PushNotificationEventHandlers.BroadcastReceiver broadcastReceiver;

  public static void instantiate(Context context, MethodChannel methodChannel) {
    if (instance == null) {
      instance = new PushNotificationEventHandlers(context, methodChannel);
    }
  }

  PushNotificationEventHandlers(Context context, MethodChannel methodChannel) {
    this.methodChannel = methodChannel;
    broadcastReceiver = new PushNotificationEventHandlers.BroadcastReceiver(context);
  }

  void sendRemoteMessageToDartSide(RemoteMessage remoteMessage) {

  }

  class BroadcastReceiver extends android.content.BroadcastReceiver {
    BroadcastReceiver(Context context) {
      register(context);
    }

    private void register(Context context) {
      IntentFilter filter = new IntentFilter();
      filter.addAction(PUSH_ON_MESSAGE_RECEIVED);
      LocalBroadcastManager.getInstance(context).registerReceiver(this, filter);
    }

    @Override
    public void onReceive(Context context, Intent intent) {
      String action = intent.getAction();
      intent.getExtras();
      switch (action) {
        case PUSH_ON_MESSAGE_RECEIVED:
          sendRemoteMessageToDartSide(remoteMessage);
          break;
        default:
          Log.e(TAG, String.format("Received unknown intent action: %s", action));
          break;
      }
    }
  }


}
