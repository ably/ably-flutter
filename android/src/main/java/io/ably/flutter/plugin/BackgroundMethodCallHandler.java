package io.ably.flutter.plugin;

import static io.ably.flutter.plugin.generated.PlatformConstants.PlatformMethod.pushBackgroundFlutterApplicationReadyOnAndroid;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;

/**
 * Receives method calls on the background method channel from the Dart side's
 * BackgroundIsolateAndroidPlatform to avoid exceptions being thrown in the case
 * where an Isolate doesn't need to be manually launched (App is already running),
 * so `pushBackgroundFlutterApplicationReadyOnAndroid` platform method call doesn't need to be called.
 */
public class BackgroundMethodCallHandler implements MethodChannel.MethodCallHandler {
  private static final String TAG = AblyFlutterPlugin.class.getName();
  private static final String CHANNEL_NAME = "io.ably.flutter.plugin.background";
  public BackgroundMethodCallHandler(BinaryMessenger messenger, MethodCodec codec) {
    MethodChannel methodChannel = new MethodChannel(messenger, CHANNEL_NAME, codec);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.method.equals(pushBackgroundFlutterApplicationReadyOnAndroid)) {
    Log.v(TAG, "Ignoring pushBackgroundFlutterApplicationReadyOnAndroid because it doesn't need to be called, " +
        "since the user's Flutter app (default DartEntrypoint) is already running.");
    } else {
      result.notImplemented();
    }
  }
}
