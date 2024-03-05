package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import java.util.Map;

import io.ably.flutter.plugin.dto.EnrichedConnectionStateChange;
import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.realtime.AblyRealtime;
import io.ably.lib.realtime.Channel;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionStateListener;
import io.ably.lib.realtime.Presence;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.Message;
import io.ably.lib.types.PresenceMessage;
import io.ably.lib.util.Log;
import io.flutter.plugin.common.EventChannel;


/**
 * Dart side can listen to Event Streams by pushing data to eventSink available in onListen method.
 * Event listening can be cancelled when stream subscription is cancelled on dart side
 * <p>
 * ref: https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.StreamHandler.html
 */
public class AblyEventStreamHandler implements EventChannel.StreamHandler {

  private static final String TAG = AblyEventStreamHandler.class.getName();
  private final AblyInstanceStore instanceStore = AblyInstanceStore.getInstance();

  /**
   * Refer to the comments on AblyMethodCallHandler.MethodResultWrapper
   * on why this customized EventSink is required
   */
  private static class MainThreadEventSink implements EventChannel.EventSink {
    private final EventChannel.EventSink eventSink;
    private final Handler handler;

    MainThreadEventSink(EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object o) {
      handler.post(() -> eventSink.success(o));   //lambda for new Runnable
    }

    @Override
    public void error(final String s, final String s1, final Object o) {
      handler.post(() -> eventSink.error(s, s1, o));
    }

    @Override
    public void endOfStream() {
    }
  }

  // Listeners
  private PluginConnectionStateListener connectionStateListener;
  private PluginChannelStateListener channelStateListener;
  private PluginChannelMessageListener channelMessageListener;
  private PluginChannelPresenceMessageListener channelPresenceMessageListener;

  void handleAblyException(EventChannel.EventSink eventSink, AblyException ablyException) {
    eventSink.error(ablyException.errorInfo.message, null, ablyException.errorInfo);
  }

  static private class Listener {
    EventChannel.EventSink eventSink;

    Listener(EventChannel.EventSink eventSink) {
      this.eventSink = eventSink;
    }
  }

  static private class PluginConnectionStateListener extends Listener implements ConnectionStateListener {

    private final AblyRealtime realtime;

    PluginConnectionStateListener(EventChannel.EventSink eventSink, AblyRealtime realtime) {
      super(eventSink);
      this.realtime = realtime;
    }

    public void onConnectionStateChanged(ConnectionStateChange stateChange) {
      eventSink.success(new EnrichedConnectionStateChange(stateChange, realtime.connection.id, realtime.connection.key));
    }

  }

  static private class PluginChannelStateListener extends Listener implements ChannelStateListener {

    PluginChannelStateListener(EventChannel.EventSink eventSink) {
      super(eventSink);
    }

    public void onChannelStateChanged(ChannelStateChange stateChange) {
      eventSink.success(stateChange);
    }

  }

  static private class PluginChannelMessageListener extends Listener implements Channel.MessageListener {

    PluginChannelMessageListener(EventChannel.EventSink eventSink) {
      super(eventSink);
    }

    public void onMessage(Message message) {
      eventSink.success(message);
    }

  }

  static private class PluginChannelPresenceMessageListener extends Listener implements Presence.PresenceListener {

    PluginChannelPresenceMessageListener(EventChannel.EventSink eventSink) {
      super(eventSink);
    }

    public void onPresenceMessage(PresenceMessage message) {
      eventSink.success(message);
    }

  }

  @Override
  public void onListen(Object object, EventChannel.EventSink uiThreadEventSink) {
    MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
    final AblyFlutterMessage<AblyEventMessage<Object>> ablyMessage = (AblyFlutterMessage<AblyEventMessage<Object>>) object;
    final AblyEventMessage<Object> eventMessage = ablyMessage.message;
    final String eventName = eventMessage.eventName;
    final Map<String, Object> eventPayload = (eventMessage.message == null) ? null : (Map<String, Object>) eventMessage.message;
    try {
      switch (eventName) {
        case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
          final AblyRealtime realtime = instanceStore.getRealtime(ablyMessage.handle);
          connectionStateListener = new PluginConnectionStateListener(eventSink, realtime);
          realtime.connection.on(connectionStateListener);
          break;
        case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
          assert eventPayload != null : "onRealtimeChannelStateChanged: event message is missing";
          channelStateListener = new PluginChannelStateListener(eventSink);
          instanceStore
              .getRealtime(ablyMessage.handle)
              .channels
              .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
              .on(channelStateListener);
          break;
        case PlatformConstants.PlatformMethod.onRealtimeChannelMessage:
          assert eventPayload != null : "onRealtimeChannelMessage: event message is missing";
          try {
            channelMessageListener = new PluginChannelMessageListener(eventSink);
            instanceStore
                .getRealtime(ablyMessage.handle)
                .channels
                .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
                .subscribe(channelMessageListener);
          } catch (AblyException ablyException) {
            handleAblyException(eventSink, ablyException);
          }
          break;
        case PlatformConstants.PlatformMethod.onRealtimePresenceMessage:
          assert eventPayload != null : "onRealtimePresenceMessage: event message is missing";
          try {
            channelPresenceMessageListener = new PluginChannelPresenceMessageListener(eventSink);
            instanceStore
                .getRealtime(ablyMessage.handle)
                .channels
                .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
                .presence.subscribe(channelPresenceMessageListener);
          } catch (AblyException ablyException) {
            handleAblyException(eventSink, ablyException);
          }
          break;
        default:
          eventSink.error("unhandled event", eventName, null);
      }
    } catch (AssertionError assertionError) {
      eventSink.error(assertionError.getMessage(), null, null);
    }
  }

  @Override
  public void onCancel(Object object) {
    if (object == null) {
      Log.w(TAG, "onCancel cannot decode null");
      return;
    }
    final AblyFlutterMessage<AblyEventMessage<Object>> ablyMessage = (AblyFlutterMessage<AblyEventMessage<Object>>) object;
    final AblyEventMessage<Object> eventMessage = ablyMessage.message;
    final String eventName = eventMessage.eventName;
    final Map<String, Object> eventPayload = (eventMessage.message == null) ? null : (Map<String, Object>) eventMessage.message;
    switch (eventName) {
      case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
        instanceStore.getRealtime(ablyMessage.handle).connection.off(connectionStateListener);
        break;
      case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
        // Note: this and all other assert statements in this onCancel method are
        // left as is as there is no way of propagating this error to flutter side
        assert eventPayload != null : "onRealtimeChannelStateChanged: event message is missing";
        instanceStore
            .getRealtime(ablyMessage.handle)
            .channels
            .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
            .off(channelStateListener);
        break;
      case PlatformConstants.PlatformMethod.onRealtimeChannelMessage:
        assert eventPayload != null : "onRealtimeChannelMessage: event message is missing";
        instanceStore
            .getRealtime(ablyMessage.handle)
            .channels
            .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
            .unsubscribe(channelMessageListener);
        break;
      case PlatformConstants.PlatformMethod.onRealtimePresenceMessage:
        assert eventPayload != null : "onRealtimePresenceMessage: event message is missing";
        instanceStore
            .getRealtime(ablyMessage.handle)
            .channels
            .get((String) eventPayload.get(PlatformConstants.TxTransportKeys.channelName))
            .presence
            .unsubscribe(channelPresenceMessageListener);
        break;
    }
  }

}
