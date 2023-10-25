package io.ably.flutter.plugin;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.plugin.common.MethodChannel;

/**
 * Prevents multiple MethodChannel.Result invocation, because it leads to app crash
 * @link https://github.com/flutter/flutter/issues/29092
 */
public class SingleTimeMethodResult implements MethodChannel.Result {
    private final MethodChannel.Result methodChannelResultInstance;
    private final AtomicInteger invocationsCount = new AtomicInteger(0);

    public SingleTimeMethodResult(MethodChannel.Result methodChannelResultInstance) {
        this.methodChannelResultInstance = methodChannelResultInstance;
    }

    @Override
    public void success(@Nullable Object result) {
        if (invocationsCount.getAndIncrement() == 0) {
            methodChannelResultInstance.success(result);
        } else {
            throw new IllegalStateException("Result shouldn't be called more than once");
        }
    }

    @Override
    public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        if (invocationsCount.getAndIncrement() == 0) {
            methodChannelResultInstance.error(errorCode, errorMessage, errorDetails);
        } else {
            throw new IllegalStateException("Result shouldn't be called more than once");
        }
    }

    @Override
    public void notImplemented() {
        if (invocationsCount.getAndIncrement() == 0) {
            methodChannelResultInstance.notImplemented();
        } else {
            throw new IllegalStateException("Result shouldn't be called more than once");
        }
    }
}
