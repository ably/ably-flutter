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
import java.util.function.BiConsumer;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.flutter.plugin.push.PushActivationEventHandlers;
import io.ably.flutter.plugin.push.PushBackgroundIsolateRunner;
import io.ably.flutter.plugin.types.PlatformClientOptions;
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
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AblyMethodCallHandler implements MethodChannel.MethodCallHandler {
  private Context applicationContext;

  public interface HotRestartCallback {
    // Called on every fresh start and on every hot restart
    void on();
  }

  private final MethodChannel channel;
  private final HotRestartCallback hotRestartCallback;
  private final Map<String, BiConsumer<MethodCall, MethodChannel.Result>> _map;
  private final AblyClientStore ablyClientStore;
  @Nullable
  private RemoteMessage remoteMessageFromUserTapLaunchesApp;

  public AblyMethodCallHandler(final MethodChannel channel,
                               final HotRestartCallback hotRestartCallback,
                               final Context applicationContext) {
    this.channel = channel;
    this.applicationContext = applicationContext;
    this.hotRestartCallback = hotRestartCallback;
    this.ablyClientStore = AblyClientStore.getInstance(applicationContext);
    _map = new HashMap<>();
    _map.put(PlatformConstants.PlatformMethod.getPlatformVersion, this::getPlatformVersion);
    _map.put(PlatformConstants.PlatformMethod.getVersion, this::getVersion);
    _map.put(PlatformConstants.PlatformMethod.registerAbly, this::register);

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
    _map.put(PlatformConstants.PlatformMethod.pushSetOnBackgroundMessage, this::pushSetOnBackgroundMessage);

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

  private void register(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    System.out.println("Registering library instance to clean up any existing instances");
    hotRestartCallback.on();
    ablyClientStore.dispose();
    result.success(null);
  }

  private void createRestWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<PlatformClientOptions> message = (AblyFlutterMessage<PlatformClientOptions>) call.arguments;

    final PlatformClientOptions clientOptions = message.message;
    try {
      final long handle = ablyClientStore.getCurrentHandle();
      if (clientOptions.hasAuthCallback) {
        clientOptions.options.authCallback = (Auth.TokenParams params) -> {
          Object token = ablyClientStore.getRestToken(handle);
          if (token != null) return token;

          final CountDownLatch latch = new CountDownLatch(1);
          new Handler(Looper.getMainLooper()).post(() -> {
            AblyFlutterMessage<Auth.TokenParams> channelMessage = new AblyFlutterMessage<>(params, handle);
            channel.invokeMethod(PlatformConstants.PlatformMethod.authCallback, channelMessage, new MethodChannel.Result() {
              @Override
              public void success(@Nullable Object result) {
                ablyClientStore.setRestToken(handle, result);
                latch.countDown();
              }

              @Override
              public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                System.out.println(errorDetails);
                if (errorMessage != null) {
                  result.error("40000", String.format("Error from authCallback: %s", errorMessage), errorDetails);
                }
                latch.countDown();
              }

              @Override
              public void notImplemented() {
                System.out.println("`authCallback` Method not implemented on dart side");
              }
            });
          });

          try {
            latch.await();
          } catch (InterruptedException e) {
            throw AblyException.fromErrorInfo(e, new ErrorInfo("Exception while waiting for authCallback to return", 400, 40000));
          }

          return ablyClientStore.getRestToken(handle);
        };
      }
      result.success(ablyClientStore.createRest(clientOptions.options));
    } catch (final AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void setRestChannelOptions(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    // setOptions is not supported on a rest instance directly
    // Track @ https://github.com/ably/ably-flutter/issues/14
    // An alternative is to use the side effect of get channel
    // with options which updates passed channel options.
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    final ChannelOptions channelOptions = (ChannelOptions) map.get(PlatformConstants.TxTransportKeys.options);
    try {
      ablyClientStore.getRest(message.handle).channels.get(channelName, channelOptions);
    } catch (AblyException ae) {
      handleAblyException(result, ae);
    }
  }

  private void publishRestMessage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    final ArrayList<Message> channelMessages = (ArrayList<Message>) map.get(PlatformConstants.TxTransportKeys.messages);
    if (channelMessages == null) {
      result.error("Messages cannot be null", null, null);
      return;
    }
    Message[] messages = new Message[channelMessages.size()];
    messages = channelMessages.toArray(messages);
    ablyClientStore.getRest(message.handle).channels.get(channelName).publishAsync(messages, handleCompletionWithListener(result));
  }

  private void releaseRestChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message;
    ablyClientStore.getRest(message.handle).channels.release(channelName);
    result.success(null);
  }

  private <T> Callback<AsyncPaginatedResult<T>> paginatedResponseHandler(@NonNull MethodChannel.Result result, Integer handle) {
    return new Callback<AsyncPaginatedResult<T>>() {
      @Override
      public void onSuccess(AsyncPaginatedResult<T> paginatedResult) {
        long paginatedResultHandle = ablyClientStore.setPaginatedResult(paginatedResult, handle);
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
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    ablyClientStore
        .getRest(message.handle)
        .channels.get(channelName)
        .historyAsync(params, this.paginatedResponseHandler(result, null));
  }

  private void getRestPresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    ablyClientStore
        .getRest(message.handle)
        .channels.get(channelName)
        .presence.getAsync(params, this.paginatedResponseHandler(result, null));
  }

  private void getRestPresenceHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    ablyClientStore
        .getRest(message.handle)
        .channels.get(channelName)
        .presence.historyAsync(params, this.paginatedResponseHandler(result, null));
  }

  private void getRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    try {
      result.success(
          Arrays.asList(
              ablyClientStore
                  .getRealtime(message.handle)
                  .channels.get(channelName)
                  .presence.get(params)
          )
      );
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void getRealtimePresenceHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    ablyClientStore
        .getRealtime(message.handle)
        .channels.get(channelName)
        .presence.historyAsync(params, this.paginatedResponseHandler(result, null));
  }

  private void enterRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
    final Object data = map.get(PlatformConstants.TxTransportKeys.data);
    final Presence presence = ablyClientStore
        .getRealtime(message.handle)
        .channels
        .get(channelName)
        .presence;
    try {
      presence.enterClient(clientId, data, handleCompletionWithListener(result));
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void updateRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
      final Map<String, Object> map = (Map<String, Object>) message.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
      final Object data = map.get(PlatformConstants.TxTransportKeys.data);
      final Presence presence = ablyClientStore
          .getRealtime(message.handle)
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
  }

  private void leaveRealtimePresence(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
      final Map<String, Object> map = (Map<String, Object>) message.message;
      final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
      final String clientId = (String) map.get(PlatformConstants.TxTransportKeys.clientId);
      final Object data = map.get(PlatformConstants.TxTransportKeys.data);
      final Presence presence = ablyClientStore
          .getRealtime(message.handle)
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
  }

  private void createRealtimeWithOptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<PlatformClientOptions> message = (AblyFlutterMessage<PlatformClientOptions>) call.arguments;
    final PlatformClientOptions clientOptions = message.message;
    try {
      final long handle = ablyClientStore.getCurrentHandle();
      if (clientOptions.hasAuthCallback) {
        clientOptions.options.authCallback = (Auth.TokenParams params) -> {
          Object token = ablyClientStore.getRealtimeToken(handle);
          if (token != null) return token;

          final CountDownLatch latch = new CountDownLatch(1);
          new Handler(Looper.getMainLooper()).post(() -> {
            AblyFlutterMessage<Auth.TokenParams> channelMessage = new AblyFlutterMessage<>(params, handle);
            channel.invokeMethod(PlatformConstants.PlatformMethod.realtimeAuthCallback, channelMessage, new MethodChannel.Result() {
              @Override
              public void success(@Nullable Object result) {
                if (result != null) {
                  ablyClientStore.setRealtimeToken(handle, result);
                  latch.countDown();
                }
              }

              @Override
              public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                System.out.println(errorDetails);
                if (errorMessage != null) {
                  result.error("40000", String.format("Error from authCallback: %s", errorMessage), errorDetails);
                }
                latch.countDown();
              }

              @Override
              public void notImplemented() {
                System.out.println("`authCallback` Method not implemented on dart side");
              }
            });
          });

          try {
            latch.await();
          } catch (InterruptedException e) {
            throw AblyException.fromErrorInfo(e, new ErrorInfo("Exception while waiting for authCallback to return", 400, 40000));
          }

          return ablyClientStore.getRealtimeToken(handle);
        };
      }
      result.success(ablyClientStore.createRealtime(clientOptions.options));
    } catch (final AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void connectRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    // Using Number (the superclass of both Long and Integer) because Flutter could send us
    // either depending on how big the value is.
    // See: https://flutter.dev/docs/development/platform-integration/platform-channels#codec
    ablyClientStore.getRealtime(message.handle.longValue()).connect();
    result.success(null);
  }

  private void attachRealtimeChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> data = (Map<String, Object>) message.message;
    final String channelName = (String) data.get(PlatformConstants.TxTransportKeys.channelName);
    try {
      ablyClientStore
          .getRealtime(message.handle)
          .channels
          .get(channelName)
          .attach(handleCompletionWithListener(result));
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void detachRealtimeChannel(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> data = (Map<String, Object>) message.message;
    try {
      final String channelName = (String) data.get(PlatformConstants.TxTransportKeys.channelName);
      ablyClientStore
          .getRealtime(message.handle)
          .channels
          .get(channelName)
          .detach(handleCompletionWithListener(result));
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void setRealtimeChannelOptions(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    try {
      final Map<String, Object> data = (Map<String, Object>) message.message;
      final String channelName = (String) data.get(PlatformConstants.TxTransportKeys.channelName);
      final ChannelOptions channelOptions = (ChannelOptions) data.get(PlatformConstants.TxTransportKeys.options);
      ablyClientStore
          .getRealtime(message.handle)
          .channels
          .get(channelName)
          .setOptions(channelOptions);
      result.success(null);
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void publishRealtimeChannelMessage(
      @NonNull MethodCall call, @NonNull MethodChannel.Result result
  ) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> data = (Map<String, Object>) message.message;
    try {
      final String channelName = (String) data.get(PlatformConstants.TxTransportKeys.channelName);
      final Channel channel = ablyClientStore
          .getRealtime(message.handle)
          .channels
          .get(channelName);

      final ArrayList<Message> channelMessages = (ArrayList<Message>) data.get(PlatformConstants.TxTransportKeys.messages);
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
  }

  private void releaseRealtimeChannel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message;
    ablyClientStore.getRealtime(message.handle).channels.release(channelName);
    result.success(null);
  }

  private void getRealtimeHistory(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Map<String, Object> map = (Map<String, Object>) message.message;
    final String channelName = (String) map.get(PlatformConstants.TxTransportKeys.channelName);
    Param[] params = (Param[]) map.get(PlatformConstants.TxTransportKeys.params);
    if (params == null) {
      params = new Param[0];
    }
    ablyClientStore
        .getRealtime(message.handle)
        .channels.get(channelName)
        .historyAsync(params, this.paginatedResponseHandler(result, null));
  }

  private void closeRealtime(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    ablyClientStore.getRealtime(message.handle).close();
    result.success(null);
  }

  private void pushActivate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    try {
      PushActivationEventHandlers.setResultForActivate(result);
      ablyClientStore.getPush(message.handle).activate();
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void pushDeactivate(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    try {
      PushActivationEventHandlers.setResultForDeactivate(result);
      ablyClientStore.getPush(message.handle).deactivate();
    } catch (AblyException e) {
      handleAblyException(result, e);
    }
  }

  private void pushSubscribeDevice(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Map<String, Object>> message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message.get(PlatformConstants.TxTransportKeys.channelName);
    ablyClientStore.getPushChannel(message.handle, channelName)
        .subscribeDeviceAsync(handleCompletionWithListener(result));
  }

  private void pushUnsubscribeDevice(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Map<String, Object>> message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message.get(PlatformConstants.TxTransportKeys.channelName);
    ablyClientStore.getPushChannel(message.handle, channelName)
        .unsubscribeDeviceAsync(handleCompletionWithListener(result));
  }

  private void pushSubscribeClient(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Map<String, Object>> message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message.get(PlatformConstants.TxTransportKeys.channelName);
    ablyClientStore.getPushChannel(message.handle, channelName)
        .subscribeClientAsync(handleCompletionWithListener(result));
  }

  private void pushUnsubscribeClient(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Map<String, Object>> message = (AblyFlutterMessage) call.arguments;
    final String channelName = (String) message.message.get(PlatformConstants.TxTransportKeys.channelName);
    ablyClientStore.getPushChannel(message.handle, channelName)
        .unsubscribeClientAsync(handleCompletionWithListener(result));
  }

  private void pushListSubscriptions(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Map<String, Object>> message = (AblyFlutterMessage<Map<String, Object>>) call.arguments;
    final String channelName = (String) message.message.get(PlatformConstants.TxTransportKeys.channelName);
    final Map<String, Object> paramsMap = (Map<String, Object>) message.message.get(PlatformConstants.TxTransportKeys.params);
    ablyClientStore.getPushChannel(message.handle, channelName).listSubscriptionsAsync(createParamsArrayFromMap(paramsMap), this.paginatedResponseHandler(result, null));
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
    try {
      AblyRealtime realtime = ablyClientStore.getRealtime(message.handle);
      if (realtime != null) {
        result.success(realtime.device());
        return;
      }

      AblyRest rest = ablyClientStore.getRest(message.handle);
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

  private void pushSetOnBackgroundMessage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    Long backgroundMessageHandlerHandle = (Long) call.arguments;
    PushBackgroundIsolateRunner.setBackgroundMessageHandler(applicationContext, backgroundMessageHandlerHandle);
  }

  private void getNextPage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage message = (AblyFlutterMessage) call.arguments;
    final Integer pageHandle = (Integer) message.message;
    ablyClientStore.getPaginatedResult(pageHandle).next(this.paginatedResponseHandler(result, pageHandle));
  }

  private void getFirstPage(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    final AblyFlutterMessage<Integer> message = (AblyFlutterMessage<Integer>) call.arguments;
    Integer pageHandle = message.message;
    ablyClientStore.getPaginatedResult(pageHandle).first(this.paginatedResponseHandler(result, pageHandle));
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

  private void getPlatformVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.success("Android " + android.os.Build.VERSION.RELEASE);
  }

  private void getVersion(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    result.success(Defaults.ABLY_AGENT_VERSION);
  }
}
