package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import java.util.Map;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.realtime.Channel;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionStateListener;
import io.ably.lib.types.AblyException;
import io.ably.lib.types.ChannelOptions;
import io.flutter.plugin.common.EventChannel;


/**
 * Dart side can listen to Event Streams by pushing data to eventSink available in onListen method.
 * Event listening can be cancelled when stream subscription is cancelled on dart side
 *
 * ref: https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.StreamHandler.html
 * */
public class AblyEventStreamHandler implements EventChannel.StreamHandler {

    /**
     * Creating an ablyLibrary instance.
     * As ablyLibrary is a singleton,
     * all ably object instance will be accessible
     * */
    private final AblyLibrary ablyLibrary = AblyLibrary.getInstance();

    /**
     * Refer to the comments on AblyMethodCallHandler.MethodResultWrapper
     * on why this customized EventSink is required
     * */
    private static class MainThreadEventSink implements EventChannel.EventSink {
        private EventChannel.EventSink eventSink;
        private Handler handler;

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
        public void endOfStream() {}
    }

    // Listeners
    private PluginConnectionStateListener connectionStateListener;
    private PluginChannelStateListener channelStateListener;

    private class Listener{
        EventChannel.EventSink eventSink;
        Listener(EventChannel.EventSink eventSink){ this.eventSink = eventSink; }
    }

    private class PluginConnectionStateListener extends Listener implements ConnectionStateListener {

        PluginConnectionStateListener(EventChannel.EventSink eventSink){
            super(eventSink);
        }

        public void onConnectionStateChanged(ConnectionStateChange stateChange){
            eventSink.success(stateChange);
        }

    }

    private class PluginChannelStateListener extends Listener implements ChannelStateListener {

        PluginChannelStateListener(EventChannel.EventSink eventSink){
            super(eventSink);
        }

        public void onChannelStateChanged(ChannelStateChange stateChange){
            eventSink.success(stateChange);
        }

    }

    // Casting stream creation arguments from `Object` into `AblyMessage`
    private AblyFlutterMessage<AblyEventMessage<Object>> getMessage(Object message){
        return (AblyFlutterMessage<AblyEventMessage<Object>>)message;
    }

    @Override
    public void onListen(Object object, EventChannel.EventSink uiThreadEventSink) {
        MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
        AblyFlutterMessage<AblyEventMessage<Object>> ablyMessage = getMessage(object);
        AblyEventMessage<Object> eventMessage = ablyMessage.message;
        String eventName = eventMessage.eventName;
        try {
            switch (eventName) {
                case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                    connectionStateListener = new PluginConnectionStateListener(eventSink);
                    ablyLibrary.getRealtime(ablyMessage.handle).connection.on(connectionStateListener);
                    break;
                case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
                    assert eventMessage.message!=null : "event message is missing";
                    Map<String, Object> eventPayload = (Map<String, Object>) eventMessage.message;
                    String channelName = (String) eventPayload.get("channel");
                    ChannelOptions channelOptions = (ChannelOptions) eventPayload.get("options");
                    try {
                        Channel channel = ablyLibrary.getRealtime(ablyMessage.handle).channels.get(channelName, channelOptions);
                        channelStateListener = new PluginChannelStateListener(eventSink);
                        channel.on(channelStateListener);
                    } catch (AblyException ablyException) {
                        eventSink.error("unhandled event", null, ablyException.errorInfo);
                    }
                    break;
                default:
                    eventSink.error("unhandled event", eventName, null);
            }
        } catch(AssertionError assertionError) {
            eventSink.error(assertionError.getMessage(), null, null);
        }
    }

    @Override
    public void onCancel(Object object) {
        if(object==null){
            System.out.println("Cannot process null input on cancel");
            return;
        }
        AblyFlutterMessage<AblyEventMessage<Object>> ablyMessage = getMessage(object);
        AblyEventMessage<Object> eventMessage = ablyMessage.message;
        String eventName = eventMessage.eventName;
        switch (eventName) {
            case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                ablyLibrary.getRealtime(ablyMessage.handle).connection.off(connectionStateListener);
                break;
            case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
                // Note: this and all other assert statements in this onCancel method are
                // left as is as there is no way of propagating this error to flutter side
                assert eventMessage.message!=null : "event message is missing";
                Map<String, Object> eventPayload = (Map<String, Object>) eventMessage.message;
                String channelName = (String) eventPayload.get("channel");
                ablyLibrary.getRealtime(ablyMessage.handle).channels.get(channelName).off(channelStateListener);
                break;
        }
    }

}
