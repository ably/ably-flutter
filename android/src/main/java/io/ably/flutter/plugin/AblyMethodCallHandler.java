package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

import io.ably.lib.realtime.CompletionListener;
import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.ErrorInfo;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.ably.flutter.plugin.gen.PlatformConstants;

public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
    private static AblyMethodCallHandler _instance;

    static synchronized AblyMethodCallHandler getInstance() {
        // TODO decide why singleton instance is required!
        if (null == _instance) {
            _instance = new AblyMethodCallHandler();
        }
        return _instance;
    }

    private final Map<String, BiConsumer<MethodCall, MethodChannel.Result>> _map;
    private AblyLibrary _ably;
    private Long _ablyHandle;
    private long _nextRegistration = 1;

    private AblyMethodCallHandler() {
        _map = new HashMap<>();
        _map.put(PlatformConstants.PlatformMethod.getPlatformVersion, this::getPlatformVersion);
        _map.put(PlatformConstants.PlatformMethod.getVersion, this::getVersion);
        _map.put(PlatformConstants.PlatformMethod.registerAbly, this::register);

        // Rest
        _map.put(PlatformConstants.PlatformMethod.createRestWithOptions, this::createRestWithOptions);
        _map.put(PlatformConstants.PlatformMethod.publish, this::publishRestMessage);

        //Realtime
        _map.put(PlatformConstants.PlatformMethod.createRealtimeWithOptions, this::createRealtimeWithOptions);
        _map.put(PlatformConstants.PlatformMethod.connectRealtime, this::connectRealtime);
        _map.put(PlatformConstants.PlatformMethod.closeRealtime, this::closeRealtime);

    }

    // MethodChannel.Result wrapper that responds on the platform thread.
    //
    // Plugins crash with "Methods marked with @UiThread must be executed on the main thread."
    // This happens while making network calls in thread other than main thread
    //
    // https://github.com/flutter/flutter/issues/34993#issue-459900986
    // https://github.com/aloisdeniel/flutter_geocoder/commit/bc34cfe473bfd1934fe098bb7053248b75200241
    private static class MethodResultWrapper implements MethodChannel.Result {
        private MethodChannel.Result methodResult;
        private Handler handler;

        MethodResultWrapper(MethodChannel.Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.success(result);
                        }
                    });
        }

        @Override
        public void error(
                final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.error(errorCode, errorMessage, errorDetails);
                        }
                    });
        }

        @Override
        public void notImplemented() {
            handler.post(
                    new Runnable() {
                        @Override
                        public void run() {
                            methodResult.notImplemented();
                        }
                    });
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result rawResult) {
        MethodChannel.Result result = new MethodResultWrapper(rawResult);
        System.out.println("Ably Plugin handle: " + call.method);
        final BiConsumer<MethodCall, MethodChannel.Result> handler = _map.get(call.method);
        if (null == handler) {
            // We don't have a handler for a method with this name so tell the caller.
            result.notImplemented();
        } else {
            // We have a handler for a method with this name so delegate to it.
            handler.accept(call, result);
        }
    }

    private void register(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final Long handle = _nextRegistration++;

        if (null != _ablyHandle) {
            System.out.println("Disposing of previous Ably instance (# " + _ablyHandle + ").");
        }

        // Setting _ablyHandle to null when _ably is not null indicates that we're in the process
        // of asynchronously disposing of the old instance.
        _ablyHandle = null;

        // TODO actually do this next bit asynchronously like we do for iOS
        if (null != _ably) {
            _ably.dispose();
        }

        System.out.println("Creating new Ably instance (# " + handle + ").");
        _ably = new AblyLibrary();
        _ablyHandle = handle;

        result.success(handle);
    }

    private void createRestWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<ClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
            try {
                result.success(ablyLibrary.createRest(clientOptions));
            } catch (final AblyException e) {
                result.error(Integer.toString(e.errorInfo.code), e.getMessage(), null);
            }
        });
    }

    private void publishRestMessage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
            Map<String, Object> map = messageData.message;
            String channelName = (String)map.get("channel");
            String name = (String)map.get("name");
            Object data = map.get("message");
            System.out.println("pushing... NAME " + name + ", DATA " + ((data==null)?"-":data.toString()));
            ablyLibrary.getRest(messageData.handle).channels.get(channelName).publishAsync(name, data, new CompletionListener() {
                @Override
                public void onSuccess() {
                    result.success(null);
                }

                @Override
                public void onError(ErrorInfo reason) {
                    result.error(Integer.toString(reason.code), "Unable to publish message to Ably server; err = " + reason.message, reason);
                }
            });
        });
    }

    private void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<ClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
            try {
                result.success(ablyLibrary.createRealtime(clientOptions));
            } catch (final AblyException e) {
                result.error(Integer.toString(e.errorInfo.code), e.getMessage(), null);
            }
        });
    }

    private void connectRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        // Using Number (the superclass of both Long and Integer) because Flutter could send us
        // either depending on how big the value is.
        // See: https://flutter.dev/docs/development/platform-integration/platform-channels#codec
        this.<Number>ablyDo(message, (ablyLibrary, realtimeHandle) -> {
            ablyLibrary.getRealtime(realtimeHandle.longValue()).connect();
            result.success(null);
        });
    }

    private void closeRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<Number>ablyDo(message, (ablyLibrary, realtimeHandle) -> {
            ablyLibrary.getRealtime(realtimeHandle.longValue()).close();
            result.success(null);
        });
    }

    public <Arguments> void ablyDo(final AblyFlutterMessage message, final BiConsumer<AblyLibrary, Arguments> consumer) {
        if (!message.handle.equals(_ablyHandle)) {
            // TODO an error response, perhaps? or allow Dart side to understand null response?
            return;
        }
        consumer.accept(_ably, (Arguments)message.message);
    }

    private void getPlatformVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    private void getVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success(Defaults.ABLY_LIB_VERSION);
    }
}