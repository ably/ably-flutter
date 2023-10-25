package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import io.ably.lib.util.Log;
import io.flutter.plugin.common.MethodChannel;

// MethodChannel.Result wrapper that responds on the platform thread.
//
// Plugins crash with "Methods marked with @UiThread must be executed on the main thread."
// This happens while making network calls in thread other than main thread
//
// https://github.com/flutter/flutter/issues/34993#issue-459900986
// https://github.com/aloisdeniel/flutter_geocoder/commit/bc34cfe473bfd1934fe098bb7053248b75200241
public class MainThreadMethodResult implements MethodChannel.Result {
    private static final String TAG = MainThreadMethodResult.class.getName();
    private final String methodName;

    private final MethodChannel.Result methodResult;
    private final Handler handler;

    MainThreadMethodResult(String methodName, MethodChannel.Result result) {
        this.methodName = methodName;
        methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
        handler.post(() -> {
            try {
                methodResult.success(result);
            } catch (Exception e) {
                Log.e(TAG, String.format("\"%s\" platform method received error during invocation, caused by: %s", methodName, e.getMessage()), e);
            }
        });
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> {
            try {
                methodResult.error(errorCode, errorMessage, errorDetails);
            } catch (Exception e) {
                Log.e(TAG, String.format("\"%s\" platform method received error during invocation, caused by: %s", methodName, e.getMessage()), e);
            }
        });
    }

    @Override
    public void notImplemented() {
        handler.post(methodResult::notImplemented);
    }
}
