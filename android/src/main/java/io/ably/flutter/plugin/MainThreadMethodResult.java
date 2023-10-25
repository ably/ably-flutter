package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

// MethodChannel.Result wrapper that responds on the platform thread.
//
// Plugins crash with "Methods marked with @UiThread must be executed on the main thread."
// This happens while making network calls in thread other than main thread
//
// https://github.com/flutter/flutter/issues/34993#issue-459900986
// https://github.com/aloisdeniel/flutter_geocoder/commit/bc34cfe473bfd1934fe098bb7053248b75200241
public class MainThreadMethodResult implements MethodChannel.Result {
    private final MethodChannel.Result methodResult;
    private final Handler handler;

    MainThreadMethodResult(MethodChannel.Result result) {
        methodResult = result;
        handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
        handler.post(() -> methodResult.success(result));
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
        handler.post(() -> methodResult.error(errorCode, errorMessage, errorDetails));
    }

    @Override
    public void notImplemented() {
        handler.post(methodResult::notImplemented);
    }
}
