package io.ably.flutter.plugin;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.messaging.RemoteMessage;

import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.push.PushActivationEventHandlers;
import io.ably.flutter.plugin.push.PushMessagingEventHandlers;
import io.ably.flutter.plugin.types.PlatformClientOptions;
import io.ably.flutter.plugin.util.BiConsumer;
import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.realtime.Channel;
import io.ably.lib.realtime.CompletionListener;
import io.ably.lib.realtime.Presence;
import io.ably.lib.rest.AblyRest;
import io.ably.lib.rest.Auth;
import io.ably.lib.transport.Defaults;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.AsyncPaginatedResult;
import io.ably.lib.types.Callback;
import io.ably.lib.types.ChannelOptions;
import io.ably.lib.types.ErrorInfo;
import io.ably.lib.types.Message;
import io.ably.lib.types.Param;
import io.ably.lib.util.Base64Coder;
import io.ably.lib.util.Crypto;
import io.ably.lib.util.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
  private static final String TAG = AblyMethodCallHandler.class.getName();

  public interface ResetAblyClientsCallback {
    void run();
  }

  private final MethodChannel channel;
  private final ResetAblyClientsCallback resetAblyClientsCallback;
  private final Map<String, BiConsumer<MethodCall, MethodChannel.Result>> _map;
  private final AblyLibrary _ably;
  @Nullable
  private RemoteMessage remoteMessageFromUserTapLaunchesApp;

  public AblyMethodCallHandler(final MethodChannel channel,
                               final ResetAblyClientsCallback resetAblyClientsCallback,
                               final Context applicationContext) {
    this.channel = channel;
    this.resetAblyClientsCallback = resetAblyClientsCallback;
    this._ably = AblyLibrary.getInstance(applicationContext);
    _map = new HashMap<>();
    _map.put(PlatformConstants.PlatformMethod.getPlatformVersion, this::getPlatformVersion);
    _map.put(PlatformConstants.PlatformMethod.getVersion, this::getVersion);
    _map.put(PlatformConstants.PlatformMethod.resetAblyClients, this::resetAblyClients);

    // Rest
    _map.put(PlatformConstants.PlatformMethod.createRestWithOptions, this::createRestWithOptions);
    _map.put(PlatformConstants.PlatformMethod.setRestChannelOptions, this::setRestChannelOptions);
    _map.put(PlatformConstants.PlatformMethod.publish, this::publishRestMessage);
    _map.put(PlatformConstants.PlatformMethod.restHistory, this::getRestHistory);
    _map.put(PlatformConstants.PlatformMethod.restPresenceGet, this::getRestPresence);
    _map.put(PlatformConstants.PlatformMethod.restPresenceHistory, this::getRestPresenceHistory);
    _map.put(PlatformConstants.PlatformMethod.releaseRestChannel, this::releaseRestChannel);

    //Realtime
    _map.put(PlatformConstants.PlatformMethod.createRealtimeWithOptions, this::createRealtimeWithOptions);
    _map.put(PlatformConstants.PlatformMethod.connectRealtime, this::connectRealtime);
    _map.put(PlatformConstants.PlatformMethod.closeRealtime, this::closeRealtime);
    _map.put(PlatformConstants.PlatformMethod.attachRealtimeChannel, this::attachRealtimeChannel);
    _map.put(PlatformConstants.PlatformMethod.detachRealtimeChannel, this::detachRealtimeChannel);
    _map.put(PlatformConstants.PlatformMethod.setRealtimeChannelOptions, this::setRealtimeChannelOptions);
    _map.put(PlatformConstants.PlatformMethod.publishRealtimeChannelMessage, this::publishRealtimeChannelMessage);
    _map.put(PlatformConstants.PlatformMethod.realtimeHistory, this::getRealtimeHistory);
    _map.put(PlatformConstants.PlatformMethod.realtimePresenceGet, this::getRealtimePresence);
    _map.put(PlatformConstants.PlatformMethod.realtimePresenceHistory, this::getRealtimePresenceHistory);
    _map.put(PlatformConstants.PlatformMethod.realtimePresenceEnter, this::enterRealtimePresence);
    _map.put(PlatformConstants.PlatformMethod.realtimePresenceUpdate, this::updateRealtimePresence);
    _map.put(PlatformConstants.PlatformMethod.realtimePresenceLeave, this::leaveRealtimePresence);
    _map.put(PlatformConstants.PlatformMethod.releaseRealtimeChannel, this::releaseRealtimeChannel);

    // Push Notifications
    _map.put(PlatformConstants.PlatformMethod.pushActivate, this::pushActivate);
    _map.put(PlatformConstants.PlatformMethod.pushDeactivate, this::pushDeactivate);
    _map.put(PlatformConstants.PlatformMethod.pushSubscribeDevice, this::pushSubscribeDevice);
    _map.put(PlatformConstants.PlatformMethod.pushUnsubscribeDevice, this::pushUnsubscribeDevice);
    _map.put(PlatformConstants.PlatformMethod.pushSubscribeClient, this::pushSubscribeClient);
    _map.put(PlatformConstants.PlatformMethod.pushUnsubscribeClient, this::pushUnsubscribeClient);
    _map.put(PlatformConstants.PlatformMethod.pushListSubscriptions, this::pushListSubscriptions);
    _map.put(PlatformConstants.PlatformMethod.pushDevice, this::pushDevice);
    _map.put(PlatformConstants.PlatformMethod.pushNotificationTapLaunchedAppFromTerminated, this::pushNotificationTapLaunchedAppFromTerminated);

    // paginated results
    _map.put(PlatformConstants.PlatformMethod.nextPage, this::getNextPage);
    _map.put(PlatformConstants.PlatformMethod.firstPage, this::getFirstPage);

    // Encryption
    _map.put(PlatformConstants.PlatformMethod.cryptoGetParams, this::cryptoGetParams);
    _map.put(PlatformConstants.PlatformMethod.cryptoGenerateRandomKey, this::cryptoGenerateRandomKey);
  }

  // MethodChannel.Result wrapper that responds on the platform thread.
  //
  // Plugins crash with "Methods marked with @UiThread must be executed on the main thread."
  // This happens while making network calls in thread other than main thread
  //
  // https://github.com/flutter/flutter/issues/34993#issue-459900986
  // https://github.com/aloisdeniel/flutter_geocoder/commit/bc34cfe473bfd1934fe098bb7053248b75200241
  private static class MethodResultWrapper implements MethodChannel.Result {
    private final MethodChannel.Result methodResult;
    private final Handler handler;

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
      handler.post(methodResult::notImplemented);
    }
  }

  private void handleAblyException(@NonNull MethodChannel.Result result, @NonNull AblyException e) {
    result.error(Integer.toString(e.errorInfo.code), e.getMessage(), e.errorInfo);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result rawResult) {
    final MethodChannel.Result result = new MethodResultWrapper(rawResult);
    Log.v(TAG, String.format("onMethodCall: Ably Flutter platform method \"%s\" invoked.", call.method));
    final BiConsumer<MethodCall, MethodChannel.Result> handler = _map.get(call.method);
    if (null == handler) {
      // We don't have a handler for a method with this name so tell the caller.
      result.notImplemented();
    } else {
      // We have a handler for a method with this name so delegate to it.
      handler.accept(call, result);
    }
  }

  private CompletionListener handleCompletionWithListener(@NonNull MethodChannel.Result result) {
    return new CompletionListener() {
      @Override
      public void onSuccess() {
        result.success(null);
      }

      @Override
      public void onError(ErrorInfo reason) {
        handleAblyException(result, AblyException.fromErrorInfo(reason));
      }
    };
  }

  private void resetAblyClients(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    _ably.dispose();
    resetAblyClientsCallback.run();
    result.success(null);
  }

  private void createRestWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<PlatformClientOptions> message = (AblyFlutterMessage<PlatformClientOptions>) call.arguments;
    this.<PlatformClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
      try {
        final long handle = ablyLibrary.getCurrentHandle();
        if (clientOptions.hasAuthCallback) {
          clientOptions.options.authCallback = (Auth.TokenParams params) -> {
            Object token = ablyLibrary.getRestToken(handle);
            if (token != null) return token;

            final CountDownLatch latch = new CountDownLatch(1);
            new Handler(Looper.getMainLooper()).post(() -> {
              AblyFlutterMessage<Auth.TokenParams> channelMessage = new AblyFlutterMessage<>(params, handle);
              channel.invokeMethod(PlatformConstants.PlatformMethod.authCallback, channelMessage, new MethodChannel.Result() {
                @Override
                public void success(@Nullable Object result) {
                  ablyLibrary.setRestToken(handle, result);
                  latch.countDown();
                }

                @Override
                public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                  Log.w(TAG, String.format("\"%s\" platform method received error from Dart side: %s", PlatformConstants.PlatformMethod.authCallback, errorMessage));
                  latch.countDown();
                }

                @Override
                public void notImplemented() {
                  Log.w(TAG, String.format("\"%s\" platform method not implemented on Dart side: %s", PlatformConstants.PlatformMethod.authCallback));
                }
              });
            });

            try {
              latch.await();
            } catch (InterruptedException e) {
              throw AblyException.fromErrorInfo(e, new ErrorInfo("Exception while waiting for authCallback to return", 400, 40000));
            }

            return ablyLibrary.getRestToken(handle);
          };
        }
        result.success(ablyLibrary.createRest(clientOptions.options));
      } catch (final AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void setRestChannelOptions(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    // setOptions is not supported on a rest instance directly
    // Track @ https://github.com/ably/ably-flutter/issues/14
    // An alternative is to use the side effect of get channel
    // with options which updates passed channel options.
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final ChannelOptions channelOptions = (ChannelOptions) map.get(PlatformConstants.TxTransportKeys.options);
      try {
        ablyLibrary.getRest(messageData.handle).channels.get(channelName, channelOptions);
        result.success(null);
      } catch (AblyException ae) {
        handleAblyException(result, ae);
      }
    });
  }

  private void publishRestMessage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final ArrayList<Message> channelMessages = (ArrayList<Message>) map.get(PlatformConstants.TxTransportKeys.messages);
      if (channelMessages == null) {
        result.error("Messages cannot be null", null, null);
        return;
      }
      Message[] messages = new Message[channelMessages.size()];
      messages = channelMessages.toArray(messages);
      ablyLibrary.getRest(messageData.handle).channels.get(channelName).publishAsync(messages, handleCompletionWithListener(result));
    });
  }

  private void releaseRestChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<String>>ablyDo(message, (ablyLibrary, messageData) -> {
      final String channelName = messageData.message;
      ablyLibrary.getRest(messageData.handle).channels.release(channelName);
      result.success(null);
    });
  }

  private <T> Callback<AsyncPaginatedResult<T>> paginatedResponseHandler(@NonNull MethodChannel.Result result, Integer handle) {
    return new Callback<AsyncPaginatedResult<T>>() {
      @Override
      public void onSuccess(AsyncPaginatedResult<T> paginatedResult) {
        long paginatedResultHandle = _ably.setPaginatedResult(paginatedResult, handle);
        result.success(new AblyFlutterMessage<>(paginatedResult, paginatedResultHandle));
      }

      @Override
      public void onError(ErrorInfo reason) {
        handleAblyException(result, AblyException.fromErrorInfo(reason));
      }
    };
  }

  private void getRestHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      ablyLibrary
          .getRest(messageData.handle)
          .channels.get(channelName)
          .historyAsync(params, this.paginatedResponseHandler(result, null));
    });
  }

  private void getRestPresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      ablyLibrary
          .getRest(messageData.handle)
          .channels.get(channelName)
          .presence.getAsync(params, this.paginatedResponseHandler(result, null));
    });
  }

  private void getRestPresenceHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      ablyLibrary
          .getRest(messageData.handle)
          .channels.get(channelName)
          .presence.historyAsync(params, this.paginatedResponseHandler(result, null));
    });
  }

  private void getRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      try {
        result.success(
            Arrays.asList(
                ablyLibrary
                    .getRealtime(messageData.handle)
                    .channels.get(channelName)
                    .presence.get(params)
            )
        );
      } catch (AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void getRealtimePresenceHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      ablyLibrary
          .getRealtime(messageData.handle)
          .channels.get(channelName)
          .presence.historyAsync(params, this.paginatedResponseHandler(result, null));
    });
  }

  private void enterRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
      final Object data = map.get(PlatformConstants.TxTransportKeys.data);
      final Presence presence = ablyLibrary
          .getRealtime(messageData.handle)
          .channels
          .get(channelName)
          .presence;
      try {
        presence.enterClient(clientId, data, handleCompletionWithListener(result));
      } catch (AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void updateRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
      final Object data = map.get(PlatformConstants.TxTransportKeys.data);
      final Presence presence = ablyLibrary
          .getRealtime(messageData.handle)
          .channels
          .get(channelName)
          .presence;
      try {
        if (clientId != null) {
          presence.updateClient(clientId, data, handleCompletionWithListener(result));
        } else {
          presence.update(data, handleCompletionWithListener(result));
        }
      } catch (AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void leaveRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
      final Object data = map.get(PlatformConstants.TxTransportKeys.data);
      final Presence presence = ablyLibrary
          .getRealtime(messageData.handle)
          .channels
          .get(channelName)
          .presence;
      try {
        if (clientId != null) {
          presence.leaveClient(clientId, data, handleCompletionWithListener(result));
        } else {
          presence.leave(data, handleCompletionWithListener(result));
        }
      } catch (AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<PlatformClientOptions> message = (AblyFlutterMessage<PlatformClientOptions>) call.arguments;
    this.<PlatformClientOptions>ablyDo(message, (ablyLibrary, clientOptions) -> {
      try {
        final long handle = ablyLibrary.getCurrentHandle();
        if (clientOptions.hasAuthCallback) {
          clientOptions.options.authCallback = (Auth.TokenParams params) -> {
            Object token = ablyLibrary.getRealtimeToken(handle);
            if (token != null) return token;

            final CountDownLatch latch = new CountDownLatch(1);
            new Handler(Looper.getMainLooper()).post(() -> {
              AblyFlutterMessage<Auth.TokenParams> channelMessage = new AblyFlutterMessage<>(params, handle);
              channel.invokeMethod(PlatformConstants.PlatformMethod.realtimeAuthCallback, channelMessage, new MethodChannel.Result() {
                @Override
                public void success(@Nullable Object result) {
                  if (result != null) {
                    ablyLibrary.setRealtimeToken(handle, result);
                    latch.countDown();
                  }
                }

                @Override
                public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                  Log.w(TAG, String.format("\"%s\" platform method received error from Dart side: %s", PlatformConstants.PlatformMethod.realtimeAuthCallback, errorMessage));
                  latch.countDown();
                }

                @Override
                public void notImplemented() {
                  Log.w(TAG, String.format("\"%s\" platform method not implemented on Dart side: %s", PlatformConstants.PlatformMethod.realtimeAuthCallback));
                }
              });
            });

            try {
              latch.await();
            } catch (InterruptedException e) {
              throw AblyException.fromErrorInfo(e, new ErrorInfo("Exception while waiting for authCallback to return", 400, 40000));
            }

            return ablyLibrary.getRealtimeToken(handle);
          };
        }
        result.success(ablyLibrary.createRealtime(clientOptions.options));
      } catch (final AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void connectRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (call.arguments instanceof Integer) {
      final Integer realtimeHandle = (Integer) call.arguments;
      _ably.getRealtime(realtimeHandle.longValue()).connect();
    } else {
      // Using Number (the superclass of both Long and Integer) because Flutter could send us
      // either depending on how big the value is.
      // See: https://flutter.dev/docs/development/platform-integration/platform-channels#codec
      final AblyFlutterMessage<Integer> message = (AblyFlutterMessage<Integer>) call.arguments;
      final Integer realtimeHandle = message.message;
      _ably.getRealtime(realtimeHandle.longValue()).connect();
    }
    result.success(null);
  }

  private void attachRealtimeChannel(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, ablyMessage) -> {
      try {
        final String channelName = (String) ablyMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
        ablyLibrary
            .getRealtime(ablyMessage.handle)
            .channels
            .get(channelName)
            .attach(handleCompletionWithListener(result));
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
        final String channelName = (String) ablyMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
        ablyLibrary
            .getRealtime(ablyMessage.handle)
            .channels
            .get(channelName)
            .detach(handleCompletionWithListener(result));
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
        final String channelName = (String) ablyMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
        final ChannelOptions channelOptions = (ChannelOptions) ablyMessage.message.get(PlatformConstants.TxTransportKeys.options);
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
        final String channelName = (String) ablyMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
        final Channel channel = ablyLibrary
            .getRealtime(ablyMessage.handle)
            .channels
            .get(channelName);

        final ArrayList<Message> channelMessages = (ArrayList<Message>) ablyMessage.message.get(PlatformConstants.TxTransportKeys.messages);
        if (channelMessages == null) {
          result.error("Messages cannot be null", null, null);
          return;
        }
        Message[] messages = new Message[channelMessages.size()];
        messages = channelMessages.toArray(messages);
        channel.publish(messages, handleCompletionWithListener(result));
      } catch (AblyException e) {
        handleAblyException(result, e);
      }
    });
  }

  private void releaseRealtimeChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<String>>ablyDo(message, (ablyLibrary, messageData) -> {
      final String channelName = messageData.message;
      ablyLibrary.getRealtime(messageData.handle).channels.release(channelName);
      result.success(null);
    });
  }

  private void getRealtimeHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<AblyFlutterMessage<Map<String, Object>>>ablyDo(message, (ablyLibrary, messageData) -> {
      final Map<String, Object> map = messageData.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
      if (params == null) {
        params = new Param[0];
      }
      ablyLibrary
          .getRealtime(messageData.handle)
          .channels.get(channelName)
          .historyAsync(params, this.paginatedResponseHandler(result, null));
    });
  }

  private void closeRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<Number>ablyDo(message, (ablyLibrary, realtimeHandle) -> {
      ablyLibrary.getRealtime(realtimeHandle.longValue()).close();
      result.success(null);
    });
  }

  private void pushActivate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    try {
      Integer handle = (Integer) message.message;
      PushActivationEventHandlers.setResultForActivate(result);
      _ably.getPush(handle).activate();
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void pushDeactivate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    try {
      Integer handle = (Integer) message.message;
      PushActivationEventHandlers.setResultForDeactivate(result);
      _ably.getPush(handle).deactivate();
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void pushSubscribeDevice(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>> message = (AblyFlutterMessage) call.arguments;
    AblyFlutterMessage<Map<String, Object>> nestedMessage = message.message;
    final String channelName = (String) nestedMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
    _ably.getPushChannel(nestedMessage.handle, channelName)
        .subscribeDeviceAsync(handleCompletionWithListener(result));
  }

  private void pushUnsubscribeDevice(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>> message = (AblyFlutterMessage) call.arguments;
    AblyFlutterMessage<Map<String, Object>> nestedMessage = message.message;
    final String channelName = (String) nestedMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
    _ably.getPushChannel(nestedMessage.handle, channelName)
        .unsubscribeDeviceAsync(handleCompletionWithListener(result));
  }

  private void pushSubscribeClient(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>> message = (AblyFlutterMessage) call.arguments;
    AblyFlutterMessage<Map<String, Object>> nestedMessage = message.message;
    final String channelName = (String) nestedMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
    _ably.getPushChannel(nestedMessage.handle, channelName)
        .subscribeClientAsync(handleCompletionWithListener(result));
  }

  private void pushUnsubscribeClient(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>> message = (AblyFlutterMessage) call.arguments;
    AblyFlutterMessage<Map<String, Object>> nestedMessage = message.message;
    final String channelName = (String) nestedMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
    _ably.getPushChannel(nestedMessage.handle, channelName)
        .unsubscribeClientAsync(handleCompletionWithListener(result));
  }

  private void pushListSubscriptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>> message = (AblyFlutterMessage<AblyFlutterMessage<Map<String, Object>>>) call.arguments;
    AblyFlutterMessage<Map<String, Object>> nestedMessage = message.message;
    final String channelName = (String) nestedMessage.message.get(PlatformConstants.TxTransportKeys.channelName);
    final Map<String, Object> paramsMap = (Map<String, Object>) nestedMessage.message.get(PlatformConstants.TxTransportKeys.params);
    _ably.getPushChannel(nestedMessage.handle, channelName).listSubscriptionsAsync(createParamsArrayFromMap(paramsMap), this.paginatedResponseHandler(result, null));
  }

  private Param[] createParamsArrayFromMap(@Nullable Map<String, Object> paramsMap) {
    if (paramsMap == null) {
      return new Param[0];
    }
    Param[] params = new Param[paramsMap.size()];
    int paramsSize = 0;
    for (Map.Entry<String, Object> entry : paramsMap.entrySet()) {
      Param param = new Param(entry.getKey(), entry.getValue());
      params[paramsSize] = param;
      paramsSize += 1;
    }
    return params;
  }

  private void pushDevice(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Integer> message = (AblyFlutterMessage<Integer>) call.arguments;
    long handle = message.message;
    try {
      AblyRealtime realtime = _ably.getRealtime(handle);
      if (realtime != null) {
        result.success(realtime.device());
        return;
      }

      AblyRest rest = _ably.getRest(handle);
      if (rest != null) {
        result.success(rest.device());
        return;
      }

      throw AblyException.fromErrorInfo(new ErrorInfo("No Ably client exists", 400, 40000));
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  public void setRemoteMessageFromUserTapLaunchesApp(@Nullable RemoteMessage message) {
    remoteMessageFromUserTapLaunchesApp = message;
  }

  private void pushNotificationTapLaunchedAppFromTerminated(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.success(remoteMessageFromUserTapLaunchesApp);
    remoteMessageFromUserTapLaunchesApp = null;
  }

  private void getNextPage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    this.<Integer>ablyDo(
        message,
        (ablyLibrary, pageHandle) -> ablyLibrary
            .getPaginatedResult(pageHandle)
            .next(this.paginatedResponseHandler(result, pageHandle)));
  }

  private void getFirstPage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<AblyFlutterMessage<Integer>> message = (AblyFlutterMessage<AblyFlutterMessage<Integer>>) call.arguments;
    Integer pageHandle = message.message.message;
    _ably.getPaginatedResult(pageHandle).first(this.paginatedResponseHandler(result, pageHandle));
  }

  private void cryptoGetParams(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final Map<String, Object> message = (Map<String, Object>) call.arguments;
    final String algorithm = (String) message.get(PlatformConstants.TxCryptoGetParams.algorithm);
    final byte[] keyData = getKeyData(message.get(PlatformConstants.TxCryptoGetParams.key));
    if (keyData == null) {
      result.error("40000", "A key must be set for encryption, being either a base64 encoded key, or a byte array.", null);
      return;
    }

    try {
      result.success(Crypto.getParams(algorithm, keyData));
    } catch (NoSuchAlgorithmException e) {
      result.error("40000", "cryptoGetParams: No algorithm found. " + e, e);
    }
  }

  private byte[] getKeyData(Object key) {
    if (key == null) {
      return null;
    }
    if (key instanceof String) {
      return Base64Coder.decode((String) key);
    } else if (key instanceof byte[]) {
      return (byte[]) key;
    } else {
      return null;
    }
  }

  private void cryptoGenerateRandomKey(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final Integer keyLength = (Integer) call.arguments;
    result.success(Crypto.generateRandomKey(keyLength));
  }

  // Extracts the message from an AblyFlutterMessage.
  //
  // It also passed the ablyLibrary argument, which you can just get with _ably without using this method
  // The benefit of using this method is questionable: it allows you to reduce manually casting.
  <T> void ablyDo(final AblyFlutterMessage message, final BiConsumer<AblyLibrary, T> consumer) {
    consumer.accept(_ably, (T) message.message);
  }

  private void getPlatformVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.success("Android " + android.os.Build.VERSION.RELEASE);
  }

  private void getVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.success(Defaults.ABLY_AGENT_VERSION);
  }
}
