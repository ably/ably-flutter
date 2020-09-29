package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonElement;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.function.BiConsumer;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.types.PlatformClientOptions;
import io.ably.lib.realtime.Channel;
import io.ably.lib.realtime.CompletionListener;
import io.ably.lib.rest.Auth;
import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ChannelOptions;
import io.ably.lib.types.ClientOptions;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.types.Message;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
    private static AblyMethodCallHandler _instance;

    public interface OnHotRestart {
        // this method will be called on every fresh start and on every hot restart
        void trigger();
    }

    static synchronized AblyMethodCallHandler getInstance(final MethodChannel channel, final OnHotRestart listener) {
        if (null == _instance) {
            _instance = new AblyMethodCallHandler(channel, listener);
        }
        return _instance;
    }

    private final MethodChannel channel;
    private final OnHotRestart onHotRestartListener;
    private final Map<String, BiConsumer<MethodCall, MethodChannel.Result>> _map;
    private AblyLibrary _ably = AblyLibrary.getInstance();

    private AblyMethodCallHandler(final MethodChannel channel, final OnHotRestart listener) {
        this.channel = channel;
        this.onHotRestartListener = listener;
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
        _map.put(PlatformConstants.PlatformMethod.attachRealtimeChannel, this::attachRealtimeChannel);
        _map.put(PlatformConstants.PlatformMethod.detachRealtimeChannel, this::detachRealtimeChannel);
        _map.put(PlatformConstants.PlatformMethod.setRealtimeChannelOptions, this::setRealtimeChannelOptions);
        _map.put(PlatformConstants.PlatformMethod.publishRealtimeChannelMessage, this::publishRealtimeChannelMessage);
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
            handler.post(() -> methodResult.success(result));
        }

        @Override
        public void error(
                final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(() -> methodResult.error(errorCode, errorMessage, errorDetails));
        }

        @Override
        public void notImplemented() {
            handler.post(() -> methodResult.notImplemented());
        }
    }

    private void handleAblyException(@NonNull MethodChannel.Result result, @NonNull AblyException e) {
        result.error(Integer.toString(e.errorInfo.code), e.getMessage(), e.errorInfo);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result rawResult) {
        final MethodChannel.Result result = new MethodResultWrapper(rawResult);
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
        System.out.println("Registering library instance to clean up any existing instances");
        onHotRestartListener.trigger();
        _ably.dispose();
        result.success(null);
    }

    private void createRestWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<PlatformClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
            try {
                final long handle = ablyLibrary.getCurrentHandle();
                if (clientOptions.hasAuthCallback) {
                    clientOptions.options.authCallback = (Auth.TokenParams params) -> {
                        Object token = ablyLibrary.getRestToken(handle);
                        if (token != null) return token;
                        new Handler(Looper.getMainLooper()).post(() -> {
                            AblyFlutterMessage channelMessage = new AblyFlutterMessage<>(params, handle);
                            channel.invokeMethod(PlatformConstants.PlatformMethod.authCallback, channelMessage, new MethodChannel.Result() {
                                @Override
                                public void success(@Nullable Object result) {
                                    ablyLibrary.setRestToken(handle, result);
                                }

                                @Override
                                public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                                    System.out.println(errorDetails);
                                    //Do nothing, let another request go to flutter side!
                                }

                                @Override
                                public void notImplemented() {
                                    System.out.println("`authCallback` Method not implemented on dart side");
                                }
                            });
                        });

                        return null;
                    };
                }
                result.success(ablyLibrary.createRest(clientOptions.options));
            } catch (final AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void publishRestMessage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
            final Map<String, Object> map = messageData.message;
            final String channelName = (String) map.get("channel");
            final String name = (String) map.get("name");
            final Object data = map.get("message");
            System.out.println("pushing... NAME " + name + ", DATA " + ((data == null) ? "-" : data.toString()));
            ablyLibrary.getRest(messageData.handle).channels.get(channelName).publishAsync(name, data, new CompletionListener() {
                @Override
                public void onSuccess() {
                    result.success(null);
                }

                @Override
                public void onError(ErrorInfo reason) {
                    handleAblyException(result, AblyException.fromErrorInfo(reason));
                }
            });
        });
    }

    private void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<PlatformClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
            try {
                result.success(ablyLibrary.createRealtime(clientOptions.options));
            } catch (final AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void connectRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        // Using Number (the superclass of both Long and Integer) because Flutter could send us
        // either depending on how big the value is.
        // See: https://flutter.dev/docs/development/platform-integration/platform-channels#codec
        this.<Number>ablyDo(message, (ablyLibrary, realtimeHandle) -> {
            ablyLibrary.getRealtime(realtimeHandle.longValue()).connect();
            result.success(null);
        });
    }

    private void attachRealtimeChannel(
            @NonNull MethodCall call, @NonNull MethodChannel.Result result
    ) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, ablyMessage) -> {
            try {
                final String channelName = (String) ablyMessage.message.get("channel");
                final ChannelOptions channelOptions = (ChannelOptions) ablyMessage.message.get("options");
                ablyLibrary
                        .getRealtime(ablyMessage.handle)
                        .channels
                        .get(channelName, channelOptions)
                        .attach(
                                new CompletionListener() {
                                    @Override
                                    public void onSuccess() {
                                        result.success(null);
                                    }

                                    @Override
                                    public void onError(ErrorInfo reason) {
                                        handleAblyException(result, AblyException.fromErrorInfo(reason));
                                    }
                                }
                        );
            } catch (AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void detachRealtimeChannel(
            @NonNull MethodCall call, @NonNull MethodChannel.Result result
    ) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, ablyMessage) -> {
            try {
                final String channelName = (String) ablyMessage.message.get("channel");
                final ChannelOptions channelOptions = (ChannelOptions) ablyMessage.message.get("options");
                ablyLibrary
                        .getRealtime(ablyMessage.handle)
                        .channels
                        .get(channelName, channelOptions)
                        .detach(
                                new CompletionListener() {
                                    @Override
                                    public void onSuccess() {
                                        result.success(null);
                                    }

                                    @Override
                                    public void onError(ErrorInfo reason) {
                                        handleAblyException(result, AblyException.fromErrorInfo(reason));
                                    }
                                }
                        );
            } catch (AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void setRealtimeChannelOptions(
            @NonNull MethodCall call, @NonNull MethodChannel.Result result
    ) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, ablyMessage) -> {
            try {
                final String channelName = (String) ablyMessage.message.get("channel");
                final ChannelOptions channelOptions = (ChannelOptions) ablyMessage.message.get("options");
                ablyLibrary
                        .getRealtime(ablyMessage.handle)
                        .channels
                        .get(channelName)
                        .setOptions(channelOptions);
                result.success(null);
            } catch (AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void publishRealtimeChannelMessage(
            @NonNull MethodCall call, @NonNull MethodChannel.Result result
    ) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, ablyMessage) -> {
            try {
                final String channelName = (String) ablyMessage.message.get("channel");
                final ChannelOptions channelOptions = (ChannelOptions) ablyMessage.message.get("options");
                final Channel channel = ablyLibrary
                        .getRealtime(ablyMessage.handle)
                        .channels
                        .get(channelName, channelOptions);

                final CompletionListener listener = new CompletionListener() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(ErrorInfo reason) {
                        handleAblyException(result, AblyException.fromErrorInfo(reason));
                    }
                };

                final ArrayList<Message> channelMessages = (ArrayList<Message>) ablyMessage.message.get("messages");
                if (channelMessages != null) {
                    Message[] messages = new Message[channelMessages.size()];
                    messages = channelMessages.toArray(messages);
                    channel.publish(messages, listener);
                } else {
                    final String name = (String) ablyMessage.message.get("name");
                    final Object data = ablyMessage.message.get("data");
                    final JsonElement json = (data == null) ? null : AblyMessageCodec.readValueAsJsonElement(data);
                    channel.publish(name, (json == null) ? data : json, listener);
                }
            } catch (AblyException e) {
                handleAblyException(result, e);
            }
        });
    }

    private void closeRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
        this.<Number>ablyDo(message, (ablyLibrary, realtimeHandle) -> {
            ablyLibrary.getRealtime(realtimeHandle.longValue()).close();
            result.success(null);
        });
    }

    <Arguments> void ablyDo(final AblyFlutterMessage message, final BiConsumer<AblyLibrary, Arguments> consumer) {
        consumer.accept(_ably, (Arguments) message.message);
    }

    private void getPlatformVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    private void getVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success(Defaults.ABLY_LIB_VERSION);
    }
}