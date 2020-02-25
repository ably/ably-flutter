package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.function.BiConsumer;
import java.util.function.Consumer;

import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ClientOptions;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
    private static AblyMethodCallHandler _instance;

    static synchronized AblyMethodCallHandler getInstance() {
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
        _map.put("getPlatformVersion", this::getPlatformVersion);
        _map.put("getVersion", this::getVersion);
        _map.put("register", this::register);
        _map.put("createRealtimeWithOptions", this::createRealtimeWithOptions);
        _map.put("connectRealtime", this::connectRealtime);
        _map.put("createListener", this::createListener);
        _map.put("eventOnce", this::eventOnce);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
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

    private void createListener(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<AblyFlutterMessage>ablyDo(message, (ablyLibrary, innerMessage) -> {
            final Object resultValue;
            final int type = ((Number)innerMessage.message).intValue();
            switch (type) {
                case 1: // connection
                    resultValue = ablyLibrary.createConnectionListener(ablyLibrary.getRealtime(innerMessage.handle));
                    break;
                default:
                    result.error("unhandled type", null, null);
                    return;
            }
            result.success(resultValue);
        });
    }

    // https://flutter.dev/docs/development/platform-integration/platform-channels#jumping-to-the-ui-thread-in-android
    private final Handler androidMainMessageQueue = new Handler(Looper.getMainLooper());

    private void eventOnce(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage)call.arguments;
        this.<Number>ablyDo(message, (ablyLibrary, listenerHandle) -> {
            // TODO actually, the argument could be an AblyFlutterMessage if the user specifies the
            // specific event they want to listen for. Either that needs refactor or we need to
            // handle it here.
            ablyLibrary.getConnectionListener(listenerHandle.longValue()).listen().thenAcceptAsync(connectionStateChange -> androidMainMessageQueue.post(new Runnable() {
                @Override
                public void run() {
                    // TODO consider serialising numerically - perhaps supporting this type in the codec
                    result.success(connectionStateChange.current.toString());
                }
            }));
        });
    }

    private <Arguments> void ablyDo(final AblyFlutterMessage message, final BiConsumer<AblyLibrary, Arguments> consumer) {
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