package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import io.ably.flutter.plugin.gen.PlatformConstants;
import io.ably.lib.realtime.ChannelStateListener;
import io.ably.lib.realtime.ConnectionStateListener;
import io.flutter.plugin.common.EventChannel;


/**
 * Dart side can listen to Event Streams by pushing data to eventSink available in onListen method.
 * Event listening can be cancelled when stream subscription is cancelled on dart side
 *
 * ref: https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.StreamHandler.html
 * */
public class AblyEventStreamHandler implements EventChannel.StreamHandler {
    private final AblyMethodCallHandler methodCallHandler;

    /**
     * Constructor requiring methodCallHandler, as it is a singleton and has all instances stored
     * Event listening can be started on an instance picked from the stored instances
     * */
    AblyEventStreamHandler(AblyMethodCallHandler methodCallHandler){
        this.methodCallHandler = methodCallHandler;
    }

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
        public void endOfStream() {
            //TODO work on this if required, or remove this TODO once all features are covered
        }
    }

    // Listeners
    private PluginConnectionStateListener connectionStateListener;
    private PluginChannelStateListener channelStateListener;

    private class Listener{
        EventChannel.EventSink eventSink;
        Listener(EventChannel.EventSink eventSink){ this.eventSink = eventSink; }
    }

    private class PluginConnectionStateListener extends Listener implements ConnectionStateListener {
        PluginConnectionStateListener(EventChannel.EventSink eventSink){super(eventSink);}
        public void onConnectionStateChanged(ConnectionStateChange stateChange){
            eventSink.success(stateChange);
        }
    }

    private class PluginChannelStateListener extends Listener implements ChannelStateListener {
        PluginChannelStateListener(EventChannel.EventSink eventSink){super(eventSink);}
        public void onChannelStateChanged(io.ably.lib.realtime.ChannelStateListener.ChannelStateChange stateChange){
            eventSink.success(stateChange);
        }
    }

    @Override
    public void onListen(Object object, EventChannel.EventSink uiThreadEventSink) {
        MainThreadEventSink eventSink = new MainThreadEventSink(uiThreadEventSink);
        methodCallHandler.<AblyFlutterMessage<String>>ablyDo((AblyFlutterMessage)object, (ablyLibrary, message) -> {
            String eventName = message.message;
            switch(eventName) {
                case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                    connectionStateListener = new PluginConnectionStateListener(eventSink);
                    ablyLibrary.getRealtime(message.handle).connection.on(connectionStateListener);
                    return;
                case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
                    // channelStateListener = new PluginChannelStateListener(eventSink);
                    // ablyLibrary.getRealtime(message.handle).connection.on(channelStateListener);
                    // return;
                default:
                    eventSink.error("unhandled event", null, null);
            }
        });
    }

    @Override
    public void onCancel(Object object) {
        if(object==null){
            System.out.println("Cannot process null input on cancel");
            return;
        }
        methodCallHandler.<AblyFlutterMessage<String>>ablyDo((AblyFlutterMessage)object, (ablyLibrary, message) -> {
            String eventName = message.message;
            switch (eventName) {
                case PlatformConstants.PlatformMethod.onRealtimeConnectionStateChanged:
                    ablyLibrary.getRealtime(message.handle).connection.off(connectionStateListener);
                case PlatformConstants.PlatformMethod.onRealtimeChannelStateChanged:
                    // ablyLibrary.getRealtime(handle).connection.off(connectionStateListener);
            }
        });
    }

}
